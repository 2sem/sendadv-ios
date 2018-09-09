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

class MainViewController: UIViewController, GADBannerViewDelegate, GADInterstialManagerDelegate, GADRewardManagerDelegate {
    
    var constraint_bottomBanner_Bottom : NSLayoutConstraint!;
    @IBOutlet weak var constraint_bottomBanner_Top: NSLayoutConstraint!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *){
            self.constraint_bottomBanner_Bottom = self.bannerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor);
        }else{
            self.constraint_bottomBanner_Bottom = self.bannerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor);
        }
        self.constraint_bottomBanner_Bottom.isActive = false;
        let req = GADRequest();
        //req.testDevices = ["5fb1f297b8eafe217348a756bdb2de56"];
        
        //self.bottomBannerView.delegate = self;
        
        GADInterstialManager.shared?.delegate = self;
        GADRewardManager.shared?.delegate = self;
        
        self.bannerView.isAutoloadEnabled = true;
        /*guard (GADRewardManager.shared?.canShow ?? false) && (GADInterstialManager.shared?.canShow ?? false) else{
         return;
         }*/
        self.bannerView?.load(req);
        
        self.bannerView?.adUnitID = "ca-app-pub-9684378399371172/4552094040";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    
    /// MARK: GADBannerViewDelegate
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        self.bannerView.layoutIfNeeded();
        self.showBanner(visible: true);
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        self.showBanner(visible: false);
    }
    
    // MARK: GADInterstialManagerDelegate
    func GADInterstialGetLastShowTime() -> Date {
        return SADefaults.LastFullADShown;
        //Calendar.current.component(, from: <#T##Date#>)
    }
    
    func GADInterstialUpdate(showTime: Date) {
        SADefaults.LastFullADShown = showTime;
        self.showBanner(visible: false);
    }
    
    // MARK: GADRewardManagerDelegate
    func GADRewardGetLastShowTime() -> Date {
        return SADefaults.LastRewardShown;
    }
    
    func GADRewardUpdate(showTime: Date) {
        SADefaults.LastRewardShown = showTime;
    }
    
    func GADRewardUserCompleted() {
        self.showBanner(visible: false);
    }
    
    var keyboardEnabled = false;
    @objc func keyboardWillShow(noti: Notification){
        print("keyboard will show move view to upper -- \(noti.object.debugDescription)");
        //        if self.nativeTextView.isFirstResponder {
        if !keyboardEnabled {
            keyboardEnabled = true;
            //            self.viewContainer.frame.origin.y -= 180;
            let frame = noti.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect;
            
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

