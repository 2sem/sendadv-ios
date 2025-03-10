//
//  SADefaults.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 4. 12..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class LSDefaults{
    static var Defaults : UserDefaults{
        get{
            return UserDefaults.standard;
        }
    }
    
    class Keys{
        static let LastFullADShown = "LastFullADShown";
        static let LastShareShown = "LastShareShown";
        static let LastRewardShown = "LastRewardShown";
        static let LastOpeningAdPrepared = "LastOpeningAdPrepared";
        
        static let LaunchCount = "LaunchCount";
        
        static let AdsShownCount = "AdsShownCount";
        static let AdsTrackingRequested = "AdsTrackingRequested";
    }
    
    static var LastFullADShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastFullADShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastFullADShown);
        }
    }
    
    static var LastShareShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastShareShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastShareShown);
        }
    }
    
    static var LastRewardShown : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastRewardShown);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastRewardShown);
        }
    }
    
    static var LastOpeningAdPrepared : Date{
        get{
            let seconds = Defaults.double(forKey: Keys.LastOpeningAdPrepared);
            return Date.init(timeIntervalSince1970: seconds);
        }
        
        set(value){
            Defaults.set(value.timeIntervalSince1970, forKey: Keys.LastOpeningAdPrepared);
        }
    }
    
    static func increaseLaunchCount(){
        self.LaunchCount = self.LaunchCount.advanced(by: 1);
    }
    
    static var LaunchCount : Int{
        get{
            //UIApplication.shared.version
            return Defaults.integer(forKey: Keys.LaunchCount);
        }
        
        set(value){
            Defaults.set(value, forKey: Keys.LaunchCount);
        }
    }
}

extension LSDefaults{
    static var AdsShownCount : Int{
        get{
            return Defaults.integer(forKey: Keys.AdsShownCount);
        }
        
        set{
            Defaults.set(newValue, forKey: Keys.AdsShownCount);
        }
    }
    
    static func increateAdsShownCount(){
        guard AdsShownCount < 3 else {
            return
        }
        
        AdsShownCount += 1;
        debugPrint("Ads Shown Count[\(AdsShownCount)]")
    }
    
    static var AdsTrackingRequested : Bool{
        get{
            return Defaults.bool(forKey: Keys.AdsTrackingRequested);
        }
        
        set{
            Defaults.set(newValue, forKey: Keys.AdsTrackingRequested);
        }
    }
    
    static func requestAppTrackingIfNeed() -> Bool{
        guard !AdsTrackingRequested else{
            debugPrint(#function, "Already requested")
            return false;
        }
        
        guard LaunchCount > 1 else{
//            AdsShownCount += 1;
            debugPrint(#function, "GAD requestPermission", "LaunchCount", LaunchCount)
            return false;
        }
        
        guard #available(iOS 14.0, *) else{
            debugPrint(#function, "OS Under 14")
            return false;
        }
        
        
        AppDelegate.sharedGADManager?.requestPermission(completion: { (result) in
            AdsTrackingRequested = true;
        })
        
        return true;
    }
}

