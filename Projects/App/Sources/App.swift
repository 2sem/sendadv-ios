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
    @Environment(\.scenePhase) private var scenePhase
    
    // SceneDelegate의 기능을 SwiftUI ObservableObject로 마이그레이션
    @StateObject private var adManager = SwiftUIAdManager()
    @StateObject private var reviewManager = SwiftUIReviewManager()
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
            .onAppear {
                setupAds()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(from: oldPhase, to: newPhase)
            }
            .environmentObject(adManager)
        }
    }
    
    private func setupAds() {
        guard !isSetupDone else {
            return
        }
        
        MobileAds.shared.start { [weak adManager, weak reviewManager, weak rewardAd] status in
            guard let adManager = adManager,
                  let reviewManager = reviewManager,
                  let rewardAd = rewardAd else { return }
            
            reviewManager.setup(interval: 60.0 * 60 * 24 * 2)
            rewardAd.setup(unitId: InterstitialAd.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 24)
            adManager.setup()
            
            MobileAds.shared.requestConfiguration.testDeviceIdentifiers = ["8a00796a760e384800262e0b7c3d08fe"]
            
            #if DEBUG
            adManager.prepare(interstitialUnit: .full, interval: 60.0)
            adManager.prepare(openingUnit: .launch, isTest: true, interval: 60.0)
            #else
            adManager.prepare(interstitialUnit: .full, interval: 60.0)
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
            break
        @unknown default:
            break
        }
    }
    
    private func handleAppDidBecomeActive() {
        print("scene become active")
        defer {
            LSDefaults.increaseLaunchCount()
        }
        
        guard LSDefaults.LaunchCount % reviewManager.reviewInterval > 0 else {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                reviewManager.show()
            }
            return
        }
        
        #if DEBUG
        let test = true
        #else
        let test = false
        #endif
        
        reviewManager.appPermissionRequested = reviewManager.appPermissionRequested || LSDefaults.requestAppTrackingIfNeed()
        guard reviewManager.appPermissionRequested else {
            debugPrint("App doesn't allow launching Ads. appPermissionRequested[\(reviewManager.appPermissionRequested)]")
            return
        }
        
        adManager.show(unit: .launch, isTest: test, completion: { (unit, ad, result) in })
    }
}

// MARK: - SwiftUI Ad Manager
class SwiftUIAdManager: NSObject, ObservableObject {
    enum GADUnitName: String {
        case full = "FullAd"
        case launch = "Launch"
    }
    
    private var gadManager: GADManager<GADUnitName>?
    var canShowFirstTime = true
    
    // 싱글톤 패턴으로 전역 접근 지원
    static var shared: SwiftUIAdManager?
    
    func setup() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let adManager = GADManager<GADUnitName>(window)
        self.gadManager = adManager
        adManager.delegate = self
        
        // 싱글톤 인스턴스 설정
        SwiftUIAdManager.shared = self
    }
    
    func prepare(interstitialUnit: GADUnitName, interval: TimeInterval) {
        gadManager?.prepare(interstitialUnit: interstitialUnit, interval: interval)
    }
    
    func prepare(openingUnit: GADUnitName, isTest: Bool = false, interval: TimeInterval) {
        gadManager?.prepare(openingUnit: openingUnit, isTest: isTest, interval: interval)
    }
    
    func show(unit: GADUnitName, isTest: Bool = false, completion: @escaping (GADUnitName, Any?, Bool) -> Void) {
        gadManager?.show(unit: unit, isTest: isTest, completion: completion)
    }
    
    // 기존 코드 호환성을 위한 메서드
    func requestPermission(completion: @escaping (Bool) -> Void) {
        gadManager?.requestPermission { status in
            completion(status == .authorized)
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

// MARK: - SwiftUI Review Manager
class SwiftUIReviewManager: NSObject, ObservableObject {
    var reviewInterval = 30
    var appPermissionRequested = false
    
    func setup(interval: TimeInterval) {
        // ReviewManager 초기화 로직
    }
    
    func show() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        let reviewManager = ReviewManager(window, interval: 60.0 * 60 * 24 * 2)
        reviewManager.delegate = self
        reviewManager.show()
    }
}

extension SwiftUIReviewManager: ReviewManagerDelegate {
    func reviewGetLastShowTime() -> Date {
        return LSDefaults.LastShareShown
    }
    
    func reviewUpdate(showTime: Date) {
        LSDefaults.LastShareShown = showTime
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
