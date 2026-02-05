//
//  GADRewardedAd+.swift
//  sendadv
//
//  Created by 영준 이 on 2021/10/04.
//  Copyright © 2021 Y2KLab. All rights reserved.
//

import Foundation
import GoogleMobileAds

extension RewardedAd{
    func isReady(for viewController: UIViewController? = nil) -> Bool{
        do{
            if let viewController = viewController ?? UIApplication.shared.topRootViewController {
                try self.canPresent(from: viewController);
                return true;
            }
            return false
        }catch{}
        
        return false;
    }
}
