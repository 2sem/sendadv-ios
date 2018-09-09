//
//  SASendViewController.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 14..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import MessageUI
import Contacts
import ContactsUI
import MBProgressHUD
import LSExtensions

/**
 This is unusable
 This is view controller to input the message and the repeat count of sending
 Apple does not support sending message programatically on background.
 */
class SASendViewController: UIViewController, MFMessageComposeViewControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var countSlider: UISlider!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarStyle = .lightContent;
        
        self.messageTextView.delegate = self;
//        self.view.backgroundColor = UIColor.blue;
//        self.navigationController?.navigationBar.shadowImage = UIImage();
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);
//        self.navigationController?.navigationBar.backgroundColor = UIColor.black;
//        self.navigationController?.navigationBar.tintColor = UIColor.yellow;
//        self.navigationController?.navigationBar.barTintColor = UIColor.lightGray;
//        self.navigationController?.view.backgroundColor = UIColor.black;
        
        self.countLabel.text = "\(Int(self.countSlider.value))";
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClick_setttingsButton(_ button: UIBarButtonItem) {
        
    }
    @IBAction func onChanged_countSlider(_ slider: UISlider) {
        self.countLabel.text = "\(Int(slider.value))";
    }
    
    @IBAction func onClick_sendButton(_ sender: UIButton) {
        self.sendMessage();
    }
    
    @IBAction func onClick_resetButton(_ sender: UIButton) {
        self.messageTextView.text = "";
        self.countSlider.value = 10.0;
        self.onChanged_countSlider(self.countSlider);
    }
    
    func generateNumber(comparation: ((String) -> Bool)? = nil) -> String{
        var value : String = "";
        let comparation = comparation ?? {(number) -> Bool in
            return true;
        }
        
        while(true){
            let number = String(format: "010%04d%04d", arc4random_uniform(9999), arc4random_uniform(9999));
            if comparation(number){
                value = number;
                break;
            }
        }
            
        return value;
    }
    
    var messageController : MFMessageComposeViewController?;

    let contactStore = CNContactStore();
    func loadContacts() -> [String]{
        var value : [String] = []
        
        let containerID = self.contactStore.defaultContainerIdentifier();
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerID);
        
        do{
            CNContact.localizedString(forKey: CNLabelPhoneNumberMain);
            CNContact.localizedString(forKey: CNLabelPhoneNumberiPhone);
            CNContact.localizedString(forKey: CNLabelPhoneNumberMobile);
            
            //let target : CNMutableContact?;
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: [CNContactPhoneNumbersKey as CNKeyDescriptor]);
            
            NSLog("load contacts. count[\(contacts.count)]");
            for contact in contacts{
                for phone in contact.phoneNumbers{
                    let number = phone.value.stringValue;
                    guard number.hasPrefix("8210") || number.hasPrefix("8211") || number.hasPrefix("8216") || number.hasPrefix("8217") || number.hasPrefix("8218") || number.hasPrefix("8219") || number.hasPrefix("010") || number.hasPrefix("011") || number.hasPrefix("016") || number.hasPrefix("017") || number.hasPrefix("018") || number.hasPrefix("019") else{
                        continue;
                    }
                    
                    if !value.contains(number){
                        value.append(number);
                    }
                }
            }
            
//            self.generate(contacts);
            
        }catch(let error){
            NSLog("load contacts error[\(error)]");
        }
        
        return value;
    }
    
    func sendMessage(){
        guard self.messageController == nil else{
            return;
        }
        
        var list : [String] = [];
        
        var phones = self.loadContacts();
        
        guard phones.count > 0 else{
            self.openSettingsOrCancel(title: "연락처 접근 실패", msg: "수신자 목록 생성을 위해 연락처 접근 권한이 필요합니다", style: .alert, titleForOK: "확인", titleForSettings: "설정");
            return;
        }
        
        let max = Int(self.countSlider.value);
        for _ in 1...max{
            let index = Int(arc4random_uniform(UInt32(phones.count)));
            let phone = phones[index];
            list.append(phone);
            phones.remove(at: index);
//            list.append(self.generateNumber(comparation: { (number) -> Bool in
//                return !list.contains(number);
//            }));
        }
        
        let hub = MBProgressHUD.showAdded(to: self.view, animated: true);
        hub.mode = .indeterminate;
        hub.label.text = "수신자 목록 생성 중";
//        hub.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);
        hub.contentColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);
        
        DispatchQueue.main.async {
            //            for i in 1...1{
            self.messageController = MFMessageComposeViewController();
            guard self.messageController != nil else{
                return;
            }
            
            guard MFMessageComposeViewController.canSendText() else{
                print("sms is unavailable");
                return;
            }
            
            //        view.recipients = ["01068664119", "01022429111"];
            self.messageController?.recipients = list;
            self.messageController?.body = self.messageTextView.text;
            self.messageController?.messageComposeDelegate = self;
            
//            self.navigationController?.pushViewController(self.messageController!, animated: true);
            self.messageController?.view?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1);
            self.messageController?.view?.alpha = 0.1;
            
            self.present(self.messageController!, animated: true) {
                print("show message view controller");
                self.messageController?.view?.alpha = 1.0;
//                self.messageController?.view?.isHidden = false;
                MBProgressHUD.hide(for: self.view, animated: true);
            }
            //            }
        }
    }
    
    // MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        self.sendButton.isEnabled = !textView.text.isEmpty;
    }

    // MARK: MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true) {
            self.messageController = nil;
            //view next controller
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
