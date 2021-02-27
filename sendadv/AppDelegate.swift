//
//  AppDelegate.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 13..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import Firebase
import StoreKit
import GADManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, ReviewManagerDelegate, GADRewardManagerDelegate {

    var window: UIWindow?
    enum GADUnitName : String{
        case full = "FullAd"
        case launch = "Launch"
    }
    static var sharedGADManager : GADManager<GADUnitName>?;
    var rewardAd : GADRewardManager?;
    var reviewManager : ReviewManager?;
    let reviewInterval = 30;
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //GADMobileAds.configure(withApplicationID: "ca-app-pub-9684378399371172~3075360846");
        FirebaseApp.configure();
        
        GADMobileAds.sharedInstance().start { [weak self](status) in
            guard let self = self else{
                return;
            }
            
            self.reviewManager = ReviewManager(self.window!, interval: 60.0 * 60 * 24 * 2);
                self.reviewManager?.delegate = self;
                //self.reviewManager?.show(true);
                
                self.rewardAd = GADRewardManager(self.window!, unitId: GADInterstitial.loadUnitId(name: "RewardAd") ?? "", interval: 60.0 * 60.0 * 24); //
                self.rewardAd?.delegate = self;
                
                let adManager = GADManager<GADUnitName>.init(self.window!);
                AppDelegate.sharedGADManager = adManager;
                adManager.delegate = self;
            #if DEBUG
                adManager.prepare(interstitialUnit: .full, interval: 60.0);
                adManager.prepare(openingUnit: .launch, isTest: true, interval: 60.0); //
            #else
                adManager.prepare(interstitialUnit: .full, interval: 60.0);
                adManager.prepare(openingUnit: .launch, interval: 60.0 * 5); //
            #endif
                
                adManager.canShowFirstTime = true;
        }
        
        LSDefaults.increaseLaunchCount();

        
        return true;
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //group.com.credif.sendadv
        
        return true;
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        //self.fullAd?.show();
        guard LSDefaults.LaunchCount % reviewInterval != 0 else{
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            }
            LSDefaults.increaseLaunchCount();
            return;
        }
        
        /*guard self.reviewManager?.canShow ?? false else{
            return;
        }
        self.reviewManager?.show(true);*/
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("app become active");
        #if DEBUG
        let test = true;
        #else
        let test = false;
        #endif
        AppDelegate.sharedGADManager?.show(unit: .launch, isTest: test, completion: { (unit, ad, result) in
            
        })
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
    
    // MARK: ReviewManagerDelegate
    func reviewGetLastShowTime() -> Date {
        return LSDefaults.LastShareShown;
    }
    
    func reviewUpdate(showTime: Date) {
        LSDefaults.LastShareShown = showTime;
    }
    
    // MARK: GADRewardManagerDelegate
    func GADRewardGetLastShowTime() -> Date {
        return LSDefaults.LastRewardShown;
    }
    
    func GADRewardUserCompleted() {
        LSDefaults.LastRewardShown = Date();
    }
    
    func GADRewardUpdate(showTime: Date) {
        
    }
}

extension AppDelegate : GADManagerDelegate{
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

