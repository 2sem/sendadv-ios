//
//  GADNativeTableViewCell.swift
//  sendadv
//
//  Created by 영준 이 on 2020/06/28.
//  Copyright © 2020 Y2KLab. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GADNativeTableViewCell: UITableViewCell {
    #if DEBUG
    let gadUnit : String = "ca-app-pub-3940256099942544/3986624511";
    #else
    let gadUnit : String = "ca-app-pub-9684378399371172/8770326405";
    #endif
    
    var rootViewController : UIViewController?;
    var gadLoader : GADAdLoader?;
    
    @IBOutlet weak var nativeAdView: GADNativeAdView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.loadDeveloper();
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadAds(){
        self.gadLoader = GADAdLoader(adUnitID: self.gadUnit,
                                     rootViewController: self.rootViewController,
                                     adTypes: [ .native ],
                                     options: []);
        self.gadLoader?.delegate = self;
        
        self.gadLoader?.load(GADRequest());
    }
    
    func loadDeveloper(){
        if let header = self.nativeAdView?.headlineView as? UILabel{
            header.text = "ads header".localized();
            header.isHidden = false;
        }
        if let advertiser = self.nativeAdView?.advertiserView as? UILabel{
            advertiser.text = "advertiser".localized();
            advertiser.isHidden = false;
        }
        //self.nativeAdView?.starRatingView?.isHidden = true;// nativeAd.starRating == nil;
        if let button = self.nativeAdView?.callToActionView as? UIButton{
            button.setTitle("ads action".localized(), for: .normal);
            button.isHidden = false;
        }
        if let imageView = self.nativeAdView?.iconView as? UIImageView{
            imageView.image = #imageLiteral(resourceName: "othreapp");
        }
        self.nativeAdView?.iconView?.isHidden = false;
        if let body = self.nativeAdView?.bodyView as? UILabel{
            body.text = "ads description".localized();
            body.isHidden = false;
        }
        
        self.nativeAdView?.isUserInteractionEnabled = false;
        //self.nativeAdView.isHidden = true;
    }
}

extension GADNativeTableViewCell : GADNativeAdLoaderDelegate{
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        print("\(#function)");
        self.nativeAdView?.nativeAd = nativeAd;
        
        if let header = nativeAdView.headlineView as? UILabel{
            header.text = nativeAd.headline;
        }
        if let advertiser = nativeAdView.advertiserView as? UILabel{
            advertiser.text = nativeAd.advertiser;
        }
        self.nativeAdView?.advertiserView?.isHidden = nativeAd.advertiser == nil;
        //self.nativeAdView?.starRatingView?.isHidden = true;// nativeAd.starRating == nil;
        if let button = nativeAdView.callToActionView as? UIButton{
            button.setTitle(nativeAd.callToAction, for: .normal);
        }
        self.nativeAdView?.callToActionView?.isHidden = nativeAd.callToAction == nil;
        if let imageView = nativeAdView.iconView as? UIImageView{
            imageView.image = nativeAd.icon?.image;
        }
        self.nativeAdView?.iconView?.isHidden = nativeAd.icon == nil;
        if let body = nativeAdView.bodyView as? UILabel{
            body.text = nativeAd.body;
        }
        self.nativeAdView.bodyView?.isHidden = nativeAd.body == nil;
        self.nativeAdView?.isUserInteractionEnabled = true;
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("\(#function) \(error)");
        self.loadDeveloper();
    }
    
    
}
