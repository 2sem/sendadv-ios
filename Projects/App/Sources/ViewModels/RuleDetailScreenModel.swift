//
//  RecipientFilterListScreenModel.swift
//  App
//
//  Created by 영준 이 on 8/6/25.
//

import SwiftUI
import SwiftData
import Contacts

/// State for the pinned recipient-count bar on `RuleDetailScreen`.
///
/// `.available` and `.permissionDenied` are rendered with dedicated UI. `.loading` and
/// `.failed` render nothing today - the loading and generic-failure treatments (tracked
/// separately) can be added later without reshaping this type.
enum RecipientCountState: Equatable {
	case loading
	case available(Int)
	case permissionDenied
	case failed
}

@MainActor
@Observable
class RuleDetailScreenModel {
	var rule: RecipientsRule?
	var title: String = ""
	var isSaved: Bool = false
	private(set) var recipientCountState: RecipientCountState = .loading

	private var cachedContacts: [CNContact]?
	private var recipientCountLoadTask: Task<Void, Never>?
	private var recipientCountDebounceTask: Task<Void, Never>?

	var hasChanges: Bool {
		title != (rule?.title ?? "");
	}

	init(rule: RecipientsRule?) {
		self.rule = rule;
		self.title = rule?.title ?? "";
	}

    func save(using context: ModelContext) {
        if rule?.modelContext == nil, let rule {
            context.insert(rule)
        }

        rule?.title = title
        try? context.save()
        isSaved = true
	}
    
    func rollback(withUndoManager undoManager: UndoManager) {
        undoManager.undo()
        while undoManager.canUndo {
            undoManager.undo()
//        undoManager.endUndoGrouping()
//        undoManager.undoNestedGroup()
        }
        print("Rule Detail is be rollbacked. is Main Thread: \(Thread.isMainThread)")
    }
	
	func getFilterText(for target: String) -> String {
		guard let rule = rule,
			  let filters = rule.filters else {
			return "All".localized()
		}
		
		let filter = filters.first { $0.target == target }
		
		if filter == nil || filter?.all == true {
			return "All".localized()
		}
		
		guard let includes = filter?.includes else {
			return "All".localized()
		}
		
		let keywords = includes.components(separatedBy: ",").filter { !$0.isEmpty }
		
		if keywords.isEmpty {
			return "All".localized()
		}
		
		if keywords.count == 1 {
			return keywords[0]
		}
		
		return keywords[0].localized() + String(format: " and %@ others".localized(), "\(keywords.count - 1)")
	}
	
	func getJobFilterText() -> String {
		return getFilterText(for: "job")
	}
	
	func getDepartmentFilterText() -> String {
		return getFilterText(for: "dept")
	}
	
	func getOrganizationFilterText() -> String {
		return getFilterText(for: "org")
	}
	
	func getOrCreateFilter(for target: String) -> RecipientsFilter {
		guard let rule = rule else {
            let filter = RecipientsFilter(target: .init(rawValue: target), includes: nil, excludes: nil, all: true)
			return filter
		}
		
		// Try to find existing filter
		if let existingFilter = rule.filters?.first(where: { $0.target == target }) {
			return existingFilter
		}
		
		// Create new filter if not found
		let newFilter = RecipientsFilter(target: .init(rawValue: target), includes: nil, excludes: nil, all: true)
		rule.filters?.append(newFilter)
		return newFilter
	}

	// MARK: - Recipient count preview

	/// Fetches the address book once (off the main actor) and computes the initial count.
	/// Safe to call repeatedly - after the first successful fetch this just recomputes in memory.
	func loadRecipientCountIfNeeded() {
		guard cachedContacts == nil else {
			recomputeRecipientCount()
			return
		}

		guard recipientCountLoadTask == nil else {
			return
		}

		recipientCountLoadTask = Task { [weak self] in
			guard let self else { return }
			await self.fetchAndComputeRecipientCount()
			self.recipientCountLoadTask = nil
		}
	}

	/// Resolves contacts authorization - requesting access if it hasn't been determined yet -
	/// then fetches and computes the count. Only a genuine authorization failure (`.denied` /
	/// `.restricted` status, a declined access request, or a `CNError.authorizationDenied` from
	/// the fetch itself) produces `.permissionDenied`. Any other failure produces `.failed` so
	/// it isn't mislabeled as a permission problem.
	private func fetchAndComputeRecipientCount() async {
		switch CNContactStore.authorizationStatus(for: .contacts) {
		case .denied, .restricted:
			recipientCountState = .permissionDenied
			return
		case .notDetermined:
			let granted = await SAContactController.Default.requestContactsAccess()
			guard !Task.isCancelled else { return }
			guard granted else {
				recipientCountState = .permissionDenied
				return
			}
		default:
			break
		}

		guard !Task.isCancelled else { return }

		do {
			let contacts = try await SAContactController.Default.loadAllContactsAsync()
			guard !Task.isCancelled else { return }
			cachedContacts = contacts
			recomputeRecipientCount()
		} catch {
			guard !Task.isCancelled else { return }
			recipientCountState = isAuthorizationFailure(error) ? .permissionDenied : .failed
		}
	}

	/// Distinguishes a genuine contacts-authorization failure from any other fetch error, so a
	/// transient or unexpected failure isn't surfaced to the user as "grant contacts access."
	private func isAuthorizationFailure(_ error: Error) -> Bool {
		if let cnError = error as? CNError, cnError.code == .authorizationDenied {
			return true
		}

		switch CNContactStore.authorizationStatus(for: .contacts) {
		case .denied, .restricted:
			return true
		default:
			return false
		}
	}

	/// Schedules an in-memory recount, coalescing calls that arrive within ~250ms. Filters are
	/// only mutated by `RuleFilterScreen`, so in practice this fires once per navigation return -
	/// the coalescing is just a safety net for rapid multi-select. Independent of
	/// `recipientCountLoadTask` so a recompute scheduled while the initial fetch is still in
	/// flight doesn't cancel that fetch.
	func scheduleRecipientCountRecompute() {
		recipientCountDebounceTask?.cancel()

		recipientCountDebounceTask = Task { [weak self] in
			try? await Task.sleep(for: .milliseconds(250))
			guard !Task.isCancelled else { return }
			self?.recomputeRecipientCount()
			self?.recipientCountDebounceTask = nil
		}
	}

	/// Cancels any in-flight fetch or coalesced recompute. Call from `onDisappear` so a slow
	/// contacts fetch or pending debounce doesn't outlive the screen.
	func cancelRecipientCountWork() {
		recipientCountLoadTask?.cancel()
		recipientCountLoadTask = nil
		recipientCountDebounceTask?.cancel()
		recipientCountDebounceTask = nil
	}

	/// Re-runs the (cheap, in-memory) match against the cached contacts. Never triggers a
	/// contacts fetch or a SwiftData save - reads whatever is currently on `rule.filters`,
	/// including in-progress, unsaved edits, and ignores `rule.enabled` since the preview
	/// must reflect the rule being edited regardless of its enabled state.
	private func recomputeRecipientCount() {
		guard let contacts = cachedContacts else { return }

		let filters = rule?.filters ?? []
		let count = SAContactController.Default.recipientCount(contacts: contacts, filters: filters)

		withAnimation {
			recipientCountState = .available(count)
		}
	}
}
