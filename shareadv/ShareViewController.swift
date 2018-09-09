//
//  ShareViewController.swift
//  shareadv
//
//  Created by 영준 이 on 2017. 1. 15..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        var  url = URL(string: "sendadv://home");
//
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: { (result) in
//            UIApplication.canOpenURL(<#T##UIApplication#>)
            var  url = URL(string: "sendadv://");
//            self.extensionContext?.open(url!, completionHandler: nil);
//            DispatchQueue.main.sync {
//                    self.extensionContext?.open(url!, completionHandler: nil);
//            }

        })
    }
    
    override func viewDidLoad() {
//        var  url = URL(string: "sendadv://");
//        self.extensionContext?.open(url!, completionHandler: nil);
    }
    
    override func cancel() {
        
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
