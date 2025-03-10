//
//  ViewController.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 13..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import GoogleMobileAds
import LSExtensions
import FirebaseCrashlytics
import Material

class MainViewController: UIViewController {
    
//    var constraint_bottomBanner_Bottom : NSLayoutConstraint!;
    @IBOutlet weak var constraint_bottomBanner_Bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_bottomBanner_Top: NSLayoutConstraint!
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var reviewButton: IconButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let req = GADRequest();
        //req.testDevices = ["5fb1f297b8eafe217348a756bdb2de56"];
        
        //self.bottomBannerView.delegate = self;
        
        GADRewardManager.shared?.delegate = self;
        
        /*guard (GADRewardManager.shared?.canShow ?? false) && (GADInterstialManager.shared?.canShow ?? false) else{
         return;
         }*/
        #if targetEnvironment(simulator)
        self.bannerView?.isAutoloadEnabled = false;
        self.showBanner(visible: false);
        #else
        self.bannerView.isAutoloadEnabled = false;
//        self.bannerView?.load(req);
        //self.bannerView?.adUnitID = "ca-app-pub-9684378399371172/4552094040";
        #endif
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Crashlytics.sharedInstance().crash();
    }
    
    @IBAction func onReviewButton(_ sender: UIButton) {
        let name : String = UIApplication.shared.displayName ?? "";
        let acts = [UIAlertAction(title: String(format: "Review '%@'".localized(), name), style: .default) { (act) in
            
            UIApplication.shared.openReview();
            },
                    UIAlertAction(title: String(format: "Recommend '%@'".localized(), name), style: .default) { (act) in
                        self.share(["\(UIApplication.shared.urlForItunes.absoluteString)"]);
            },
                    UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)]
        self.showAlert(title: "App rating and recommendation".localized(), msg: String(format: "Please rate '%@' or recommend it to your friends.".localized(), name), actions: acts, style: .alert);
    }
    
    func toggleContraint(value : Bool, constraintOn : NSLayoutConstraint, constraintOff : NSLayoutConstraint){
        if constraintOn.isActive{
            constraintOn.isActive = value;
            constraintOff.isActive = !value;
            print("\(value) => \(constraintOn)###\(!value) => \(constraintOn)");
        }else{
            constraintOff.isActive = !value;
            constraintOn.isActive = value;
            print("\(!value) => \(constraintOn)###\(value) => \(constraintOn)");
            
        }
    }
    
    private func showBanner(visible: Bool){
        guard self.constraint_bottomBanner_Bottom != nil
            && self.constraint_bottomBanner_Top != nil else{
                return;
        }
        
        self.toggleContraint(value: visible, constraintOn: self.constraint_bottomBanner_Bottom, constraintOff: self.constraint_bottomBanner_Top);
        
        if visible{
            print("show banner. frame[\(self.bannerView.frame)]");
        }else{
            print("hide banner. frame[\(self.bannerView.frame)]");
        }
        self.bannerView.isHidden = !visible;
        self.reviewButton?.isHidden = !visible;
    }
    
    var keyboardEnabled = false;
    @objc func keyboardWillShow(noti: Notification){
        print("keyboard will show move view to upper -- \(noti.object.debugDescription)");
        //        if self.nativeTextView.isFirstResponder {
        if !keyboardEnabled {
            keyboardEnabled = true;
            //            self.viewContainer.frame.origin.y -= 180;
            let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect;
            
            // - self.bottomBannerView.frame.height
            if true{ //!self.isIPhone
                let remainHeight = (frame?.height ?? 0);//self.view.frame.height -
                //                var remainHeight : CGFloat = 100.0;
                self.constraint_bottomBanner_Top.constant = -remainHeight;
                self.constraint_bottomBanner_Bottom.constant = -remainHeight;
            }
            
            //            self.viewContainer.layoutIfNeeded();
        };
        //native y -= (keyboard height - bottom banner height)
        // keyboard top == native bottom
        //        }
    }
    
    @objc func keyboardWillHide(noti: Notification){
        print("keyboard will hide move view to lower -- \(noti.object.debugDescription)");
        //        if self.nativeTextView.isFirstResponder{
        
        //        }
        //&&
        if keyboardEnabled {
            keyboardEnabled = false;
            //            self.viewContainer.frame.origin.y += 180;
            
            self.constraint_bottomBanner_Top.constant = 0;
            self.constraint_bottomBanner_Bottom.constant = 0;
            //            self.viewContainer.layoutIfNeeded();
        };
    }
}

extension MainViewController: GADBannerViewDelegate{
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        //        self.bannerView.layoutIfNeeded();
        self.showBanner(visible: true);
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        self.showBanner(visible: false);
    }
}

extension MainViewController: GADRewardManagerDelegate{
    // MARK: GADRewardManagerDelegate
    func GADRewardGetLastShowTime() -> Date {
        return LSDefaults.LastRewardShown;
    }
    
    func GADRewardUpdate(showTime: Date) {
        LSDefaults.LastRewardShown = showTime;
    }
    
    func GADRewardUserCompleted() {
        self.showBanner(visible: false);
    }
}
