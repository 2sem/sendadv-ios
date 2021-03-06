//
//  GADBannerView+.swift
//  talktrans
//
//  Created by 영준 이 on 2016. 12. 11..
//  Copyright © 2016년 leesam. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension GADBannerView{
    func loadUnitId(name : String){
        guard let unitList = Bundle.main.infoDictionary?["GoogleADUnitID"] as? [String : String] else{
            print("Add [String : String] Dictionary as 'GoogleADUnitID'");
            return;
        }
        
        guard !unitList.isEmpty else{
            print("Add Unit into 'GoogleADUnitID'");
            return;
        }
        
        guard let unit = unitList[name] else{
            print("Add unit \(name) into GoogleADUnitID");
            return;
        }
        
        self.adUnitID = unit;
    }
}
