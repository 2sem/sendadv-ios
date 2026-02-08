import SwiftUI
import SwiftData
import GoogleMobileAds
import Firebase
import StoreKit
import GADManager

@main
struct SendadvApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isSplashDone = false
    @State private var isSetupDone = false
    @State private var isFromBackground = false
    @Environment(\.scenePhase) private var scenePhase

    // SceneDelegate의 기능을 SwiftUI ObservableObject로 마이그레이션
    @StateObject private var adManager = SwiftUIAdManager()
    @StateObject private var reviewManager = ReviewManager()
    @StateObject private var rewardAd = SwiftUIRewardAdManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // 메인 화면 (루트)
                NavigationStack {
                    RecipientRuleListScreen()
                }
                .modelContainer(for: [RecipientsRule.self, RecipientsFilter.self], inMemory: false, isAutosaveEnabled: false, isUndoEnabled: true)
                
                // 스플래시 오버레이
                if !isSplashDone {
                    SplashScreen(isDone: $isSplashDone)
                        .transition(.opacity)
                }
            }
            .environmentObject(adManager)
            .environmentObject(reviewManager)
            .onAppear {
                setupAds()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(from: oldPhase, to: newPhase)
            }
        }
    }
    
    private func setupAds() {
        guard !isSetupDone else {
            return
        }
        
        MobileAds.shared.start { [weak adManager, weak rewardAd] status in
            guard let adManager = adManager,
                  let rewardAd = rewardAd else { return }
            
            rewardAd.setup(unitId: InterstitialAd.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 24)
            adManager.setup()
            
            MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["8a00796a760e384800262e0b7c3d08fe"]

            adManager.prepare(interstitialUnit: .full, interval: 60.0)
            #if DEBUG
            adManager.prepare(openingUnit: .launch, interval: 60.0)
            #else
            adManager.prepare(interstitialUnit: .full, interval: 60.0 * 60)
            adManager.prepare(openingUnit: .launch, interval: 60.0 * 5)
            #endif
            adManager.canShowFirstTime = true
        }
        
        isSetupDone = true
    }
    
    private func handleScenePhaseChange(from oldPhase: ScenePhase, to newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            handleAppDidBecomeActive()
        case .inactive:
            // 앱이 비활성화될 때의 처리
            break
        case .background:
            // 앱이 백그라운드로 갈 때의 처리
            isFromBackground = true
            break
        @unknown default:
            break
        }
    }
    
    private func handleAppDidBecomeActive() {
        print("scene become active")
        Task{
            defer {
                LSDefaults.increaseLaunchCount()
            }

            // 백그라운드에서 돌아온 경우에만 Launch Ad를 표시
            if isFromBackground {
                await adManager.show(unit: .launch)
                isFromBackground = false
            }
        }
    }
}

// MARK: - SwiftUI Ad Manager
class SwiftUIAdManager: NSObject, ObservableObject {
    enum GADUnitName: String {
        case full = "FullAd"
        case launch = "Launch"
        case native = "Native"
    }
    
#if DEBUG
    var testUnits: [GADUnitName] = [
        .full,
        .launch,
        .native,
    ]
#else
    var testUnits: [GADUnitName] = []
#endif
    
    private var gadManager: GADManager<GADUnitName>!
    var canShowFirstTime = true
    
    // 싱글톤 패턴으로 전역 접근 지원
    static var shared: SwiftUIAdManager?
    @Published var isReady: Bool = false
    
    func setup() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let adManager = GADManager<GADUnitName>(window)
        self.gadManager = adManager
        adManager.delegate = self
        
        // 싱글톤 인스턴스 설정
        SwiftUIAdManager.shared = self
        self.isReady = true
    }
    
    func prepare(interstitialUnit unit: GADUnitName, interval: TimeInterval) {
        gadManager?.prepare(interstitialUnit: unit, isTesting: self.isTesting(unit: unit), interval: interval)
    }
    
    func prepare(openingUnit unit: GADUnitName, interval: TimeInterval) {
        gadManager?.prepare(openingUnit: unit, isTesting: self.isTesting(unit: unit), interval: interval)
    }
    
    /// Shows an ad for the specified unit.
    /// 
    /// Note: This method may cause undo/transaction issues in SwiftUI.
    /// To avoid potential problems, consider using `showDeferred(unit:)` which defers the call to the main queue and ensures proper transaction handling.
    @MainActor
    @discardableResult
    func show(unit: GADUnitName) async -> Bool {
        await withCheckedContinuation { continuation in
            guard let gadManager else {
                continuation.resume(returning: false)
                return
            }
            
            gadManager.show(unit: unit, isTesting: self.isTesting(unit: unit) ){ unit, _,result  in
                continuation.resume(returning: result)
            }
        }
    }
    
    func createAdLoader(forUnit unit: GADUnitName, options: [NativeAdViewAdOptions] = []) -> AdLoader? {
        return gadManager?.createNativeLoader(forAd: unit, isTesting: self.isTesting(unit: unit))
    }
    
    // MARK: - Testing Flags
    func isTesting(unit: GADUnitName) -> Bool {
        return testUnits.contains(unit)
    }
    
    // 기존 코드 호환성을 위한 메서드
    func requestPermission(completion: @escaping (Bool) -> Void) {
        guard let gadManager else {
            completion(false)
            return
        }
        
        gadManager.requestPermission { status in
            completion(status == .authorized)
        }
    }
    
    // 앱 추적 권한 요청 (필요한 경우에만)
    @discardableResult
    func requestAppTrackingIfNeed() async -> Bool {
        guard !LSDefaults.AdsTrackingRequested else {
            debugPrint(#function, "Already requested")
            return false
        }
        
        guard LSDefaults.LaunchCount > 1 else {
            debugPrint(#function, "GAD requestPermission", "LaunchCount", LSDefaults.LaunchCount)
            return false
        }
        
        return await withCheckedContinuation { continuation in
            self.requestPermission { granted in
                LSDefaults.AdsTrackingRequested = true
                continuation.resume(returning: granted)
            }
        }
    }
}

extension SwiftUIAdManager: GADManagerDelegate {
    typealias E = GADUnitName
    
    func GAD<E>(manager: GADManager<E>, lastPreparedTimeForUnit unit: E) -> Date {
        return LSDefaults.LastOpeningAdPrepared
    }
    
    func GAD<E>(manager: GADManager<E>, updateLastPreparedTimeForUnit unit: E, preparedTime time: Date) {
        LSDefaults.LastOpeningAdPrepared = time
    }
    
    func GAD<E>(manager: GADManager<E>, lastShownTimeForUnit unit: E) -> Date {
        let now = Date()
        if LSDefaults.LastFullADShown > now {
            LSDefaults.LastFullADShown = now
        }
        return LSDefaults.LastFullADShown
    }
    
    func GAD<E>(manager: GADManager<E>, updatShownTimeForUnit unit: E, showTime time: Date) {
        LSDefaults.LastFullADShown = time
    }
}

// MARK: - SwiftUI Reward Ad Manager
class SwiftUIRewardAdManager: NSObject, ObservableObject {
    private var rewardAd: GADRewardManager?
    
    func setup(unitId: String, interval: TimeInterval) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        self.rewardAd = GADRewardManager(window, unitId: unitId, interval: interval)
        self.rewardAd?.delegate = self
    }
    
    func show(force: Bool = false) {
        rewardAd?.show(force)
    }
}

extension SwiftUIRewardAdManager: GADRewardManagerDelegate {
    func GADRewardGetLastShowTime() -> Date {
        return LSDefaults.LastRewardShown
    }
    
    func GADRewardUserCompleted() {
        LSDefaults.LastRewardShown = Date()
    }
    
    func GADRewardUpdate(showTime: Date) {
        // 필요한 경우 추가 로직
    }
}

