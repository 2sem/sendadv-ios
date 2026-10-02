import Foundation
import XCTest
@testable import App

final class AppTests: XCTestCase {
    func test_twoPlusTwo_isFour() {
        XCTAssertEqual(2+2, 4)
    }
}

final class MessageTemplateRulesTests: XCTestCase {
	func test_estimatedBytes_asciiIsOneBytePerCharacter() {
		XCTAssertEqual(MessageTemplateRules.estimatedBytes("hello"), 5)
	}

	func test_estimatedBytes_nonAsciiIsTwoBytesPerCharacter() {
		XCTAssertEqual(MessageTemplateRules.estimatedBytes("안녕"), 4)
		XCTAssertEqual(MessageTemplateRules.estimatedBytes("a안b"), 4)
	}

	func test_lmsThreshold_boundary() {
		XCTAssertFalse(MessageTemplateRules.mayBeSentAsLMS(String(repeating: "a", count: 90)))
		XCTAssertTrue(MessageTemplateRules.mayBeSentAsLMS(String(repeating: "a", count: 91)))
		XCTAssertFalse(MessageTemplateRules.mayBeSentAsLMS(String(repeating: "가", count: 45)))
		XCTAssertTrue(MessageTemplateRules.mayBeSentAsLMS(String(repeating: "가", count: 46)))
	}

	func test_isValid_requiresTitleAndBodyAfterTrimming() {
		XCTAssertFalse(MessageTemplateRules.isValid(title: "", body: "body"))
		XCTAssertFalse(MessageTemplateRules.isValid(title: "title", body: ""))
		XCTAssertFalse(MessageTemplateRules.isValid(title: "  \n", body: "body"))
		XCTAssertFalse(MessageTemplateRules.isValid(title: "title", body: " \n\t "))
		XCTAssertTrue(MessageTemplateRules.isValid(title: "title", body: "body"))
	}

	func test_trimmed_keepsInternalNewlines() {
		XCTAssertEqual(MessageTemplateRules.trimmed("  a\nb \n"), "a\nb")
	}

	func test_clamped_enforcesLimits() {
		let longTitle = String(repeating: "t", count: 40)
		XCTAssertEqual(MessageTemplateRules.clamped(longTitle, limit: MessageTemplateRules.titleLimit).count, 30)
		let longBody = String(repeating: "가", count: 600)
		XCTAssertEqual(MessageTemplateRules.clamped(longBody, limit: MessageTemplateRules.bodyLimit).count, 500)
		XCTAssertEqual(MessageTemplateRules.clamped("short", limit: 30), "short")
	}
}
