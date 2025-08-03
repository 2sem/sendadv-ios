//
//  GADInterstitial+.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 4. 12..
//  Copyright © 2017년 leesam. All rights reserved.
//

import Foundation
import GoogleMobileAds

/**
 GoogleADUnitID/{name}
 */
extension InterstitialAd {
    static func loadUnitId(name : String) -> String?{
        var value : String?;
        guard let unitList = Bundle.main.infoDictionary?["GoogleADUnitID"] as? [String : String] else{
            print("Add [String : String] Dictionary as 'GoogleADUnitID'");
            return value;
        }
        
        guard !unitList.isEmpty else{
            print("Add Unit into 'GoogleADUnitID'");
            return value;
        }
        
        value = unitList[name];
        guard value != nil else{
            print("Add unit \(name) into GoogleADUnitID");
            return value;
        }
        
        return value;
    }
    
    func isReady(for viewController: UIViewController? = nil) -> Bool{
        do{
            if let viewController = viewController ?? UIApplication.shared.windows.first?.rootViewController{
                try self.canPresent(from: viewController);
                return true;
            }
            return false
        }catch{}
        
        return false;
    }
}
