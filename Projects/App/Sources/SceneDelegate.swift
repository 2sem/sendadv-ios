import UIKit
import GoogleMobileAds
import Firebase
import StoreKit
import GADManager

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    enum GADUnitName : String{
        case full = "FullAd"
        case launch = "Launch"
    }
    static var sharedGADManager : GADManager<GADUnitName>?
    var rewardAd : GADRewardManager?
    var reviewManager : ReviewManager?
    let reviewInterval = 30
    var appPermissionRequested = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        MobileAds.shared.start { [weak self](status) in
            guard let self = self else { return }

            self.reviewManager = ReviewManager(self.window!, interval: 60.0 * 60 * 24 * 2)
            self.reviewManager?.delegate = self

            self.rewardAd = GADRewardManager(self.window!, unitId: InterstitialAd.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 24)
            self.rewardAd?.delegate = self

            let adManager = GADManager<GADUnitName>.init(self.window!)
            SceneDelegate.sharedGADManager = adManager
            adManager.delegate = self
            #if DEBUG
            adManager.prepare(interstitialUnit: .full, interval: 60.0)
            adManager.prepare(openingUnit: .launch, isTest: true, interval: 60.0)
            #else
            adManager.prepare(interstitialUnit: .full, interval: 60.0)
            adManager.prepare(openingUnit: .launch, interval: 60.0 * 5)
            #endif
            adManager.canShowFirstTime = true
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("scene become active")
        defer {
            LSDefaults.increaseLaunchCount()
        }
        guard LSDefaults.LaunchCount % reviewInterval > 0 else {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                self.reviewManager?.show()
            }
            return
        }
        #if DEBUG
        let test = true
        #else
        let test = false
        #endif

        appPermissionRequested = appPermissionRequested || LSDefaults.requestAppTrackingIfNeed()
        guard appPermissionRequested else {
            debugPrint("App doesn't allow launching Ads. appPermissionRequested[\(appPermissionRequested)]")
            return
        }
        SceneDelegate.sharedGADManager?.show(unit: .launch, isTest: test, completion: { (unit, ad, result) in })
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        guard LSDefaults.LaunchCount % reviewInterval != 0 else {
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
            LSDefaults.increaseLaunchCount()
            return
        }
    }
}

extension SceneDelegate : ReviewManagerDelegate{
    func reviewGetLastShowTime() -> Date {
        return LSDefaults.LastShareShown
    }
    func reviewUpdate(showTime: Date) {
        LSDefaults.LastShareShown = showTime
    }
}

extension SceneDelegate : GADRewardManagerDelegate{
    func GADRewardGetLastShowTime() -> Date {
        return LSDefaults.LastRewardShown
    }
    func GADRewardUserCompleted() {
        LSDefaults.LastRewardShown = Date()
    }
    func GADRewardUpdate(showTime: Date) {}
}

extension SceneDelegate : GADManagerDelegate{
    typealias E = GADUnitName
    func GAD<E>(manager: GADManager<E>, lastPreparedTimeForUnit unit: E) -> Date{
        let now = Date();
  //        if RSDefaults.LastOpeningAdPrepared > now{
  //            RSDefaults.LastOpeningAdPrepared = now;
  //        }

          return LSDefaults.LastOpeningAdPrepared;
          //Calendar.current.component(<#T##component: Calendar.Component##Calendar.Component#>, from: <#T##Date#>)
    }
    
    func GAD<E>(manager: GADManager<E>, updateLastPreparedTimeForUnit unit: E, preparedTime time: Date){
        LSDefaults.LastOpeningAdPrepared = time;
        
        //RNInfoTableViewController.shared?.needAds = false;
        //RNFavoriteTableViewController.shared?.needAds = false;
    }
    
    func GAD<E>(manager: GADManager<E>, lastShownTimeForUnit unit: E) -> Date{
        let now = Date();
        if LSDefaults.LastFullADShown > now{
            LSDefaults.LastFullADShown = now;
        }
        
        return LSDefaults.LastFullADShown;
        //Calendar.current.component(<#T##component: Calendar.Component##Calendar.Component#>, from: <#T##Date#>)
    }
    
    func GAD<E>(manager: GADManager<E>, updatShownTimeForUnit unit: E, showTime time: Date){
        LSDefaults.LastFullADShown = time;
        
        //RNInfoTableViewController.shared?.needAds = false;
        //RNFavoriteTableViewController.shared?.needAds = false;
    }
}
