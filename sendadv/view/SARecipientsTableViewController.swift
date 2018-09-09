//
//  SARuleTableViewController.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit
import MessageUI
import Contacts
import MBProgressHUD
import Material
import LSExtensions

class SARecipientsTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate  {
    let cell_id = "SARecipientsTableViewCell";
    var rules : [SARecipientsRule] = [];
    var dataController = SAModelController.Default;
    
    var sendButton : FABButton!;
    
    var indexPathForSelectedRow : IndexPath?;
    weak var sendButtonTrailingConstraint : NSLayoutConstraint!;
    weak var sendButtonBottomConstraint : NSLayoutConstraint!;
    
    override func viewWillAppear(_ animated: Bool) {
        let rules = self.dataController.loadRecipientsRules();
        
        // MARK: Applys new appended rule
        //If count of rule was changed
        if rules.count > self.rules.count{
            //Considers new rule is appended
            let indexPath = IndexPath(row: rules.count - 1, section: 0);
            self.rules = rules;
            //show new rule
            self.tableView.insertRows(at: [indexPath], with: .automatic);
        }else{
            guard let indexPath = self.indexPathForSelectedRow else{
                return;
            }
            //reload last selected rule
            self.tableView.reloadRows(at: [indexPath], with: .automatic);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.hideExtraRows = true;
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        self.editButtonItem.tintColor = UIColor.yellow;
        self.editButtonItem.possibleTitles = ["abc", "def"];
        
        // MARK: load all rules
        self.rules = self.dataController.loadRecipientsRules();
        
        // MARK: create send button
        self.sendButton = FABButton(image: Icon.cm.pen, tintColor: UIColor.black);
        self.sendButton.addTarget(self, action: #selector(onSendMessage(_:)), for: .touchUpInside);
        self.sendButton.backgroundColor = UIColor.yellow;
        self.sendButton.pulseColor = UIColor.yellow;
        
        self.view.addSubview(self.sendButton);
        self.sendButton.translatesAutoresizingMaskIntoConstraints = false;
        self.sendButton.widthAnchor.constraint(equalToConstant: 44).isActive = true;
        self.sendButton.heightAnchor.constraint(equalToConstant: 44).isActive = true;
        //self.sendButton.frame.size = CGSize(width: 44, height: 44);
        self.sendButton.frame.origin.x = self.view.frame.maxX - self.sendButton.frame.width - 16;
        self.sendButton.frame.origin.y = self.view.frame.maxY - self.sendButton.frame.width - 16;
        
        //self.view.layout(self.sendButton)
        //    .width(44)
        //    .width(44);
        
        /*self.sendButtonTrailingConstraint = self.sendButton.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor, constant: -16)
        self.sendButtonTrailingConstraint.isActive = true;
        self.sendButtonBottomConstraint = self.sendButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -self.sendButton.bounds.height * 0.5);
        self.sendButtonBottomConstraint.isActive = true;*/
        
        self.layoutSendButton();
        
        print("fab button frame[\(self.sendButton.frame)] view[\(self.view.frame)] constraint[\(self.sendButton.constraints)] -- [\(self.view.constraints)]");
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func layoutSendButton(){
        self.sendButton.frame.origin.x = self.view.bounds.maxX - self.sendButton.bounds.width - 16;
        self.sendButton.frame.origin.y = self.view.bounds.maxY - self.sendButton.bounds.height * 1.5;
    }
    
    override func viewDidLayoutSubviews() {
        self.layoutSendButton();
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.layoutSendButton();
        //+ scrollView.contentOffset.y;
        
    }
    
    //iOS native messaging UI
    var messageController : MFMessageComposeViewController?;

    //var recipientCount = 10;
    var message = "haha ggo text";
    @IBAction func onSendMessage(_ button: Any) {
        self._onSendMessage(allowAll: false);
    }
    
    func _onSendMessage(allowAll : Bool) {
        guard self.messageController == nil else{
            return;
        }
        
        //Checks if need to send to all or there is no rule to filter
        guard allowAll || self.rules.filter({ (rule) -> Bool in
            return rule.enabled == true;
        }).any else{
            // MARK: Warning to send to all, it will take long time to make list of all contacts
            let acts = [UIAlertAction(title: "Continue".localized(), style: .default, handler: { (act) in
                self._onSendMessage(allowAll: true);
            }),UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)]
            self.showAlert(title: "Warning".localized(), msg: "There is no activated Rules for Reciepients.\nAll Contacts will receive Message".localized(), actions: acts, style: .alert);
            return;
        }
        
        //Gets phone numbers from contracts filtered by rules
        let phones : [String]! = SAContactController.Default.loadContacts(rules: self.rules.filter({ (rule) -> Bool in
            return rule.enabled;
        }));
        
        guard phones != nil else{
            self.openSettingsOrCancel(title: "Failed to access contacts".localized(), msg: "Permission required to access contacts for creating recipients list", style: .alert, titleForOK: "OK".localized(), titleForSettings: "Setting".localized());
            return;
        }
        
        //There isn't any phone numbers filtered by rules.
        guard phones.count > 0 else{
            self.showAlert(title: "Failed to create recipients list".localized(), msg: "There is no contact matched to the enabled rules".localized(), actions: [UIAlertAction(title: "OK".localized(), style: .default, handler: nil)], style: .alert);
            return;
        }
        
        //Limits recipient count?
        /*var max = self.recipientCount;
        for n in 1...max{
            guard phones.count > 0 else {
                break;
            }
            
            var index = Int(arc4random_uniform(UInt32(phones.count)));
            var phone = phones[index];
            list.append(phone);
            phones.remove(at: index);
            //            list.append(self.generateNumber(comparation: { (number) -> Bool in
            //                return !list.contains(number);
            //            }));
        }*/
        
        //Shows progress until messageing ui appear
        let hub = MBProgressHUD.showAdded(to: self.view, animated: true);
        hub.mode = .indeterminate;
        hub.label.text = "Creating recipients list".localized();
        //        hub.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);
        hub.contentColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);
        
        self.showMessageView(phones);
    }
    
    func showMessageView(_ phones : [String]){
        self.messageController = MFMessageComposeViewController();
        guard self.messageController != nil else{
            self.messageController = nil;
            MBProgressHUD.hide(for: self.view, animated: true);
            return;
        }
        
        //Checks if this device can send message
        guard MFMessageComposeViewController.canSendText() else{
            print("sms is unavailable");
            self.messageController = nil;
            MBProgressHUD.hide(for: self.view, animated: true);
            return;
        }
        
        self.messageController?.recipients = phones;
        //self.messageController?.body = "...";
        self.messageController?.messageComposeDelegate = self;
        //self.messageController?.delegate = self;
        
        //self.navigationController?.pushViewController(self.messageController!, animated: true);
        self.messageController?.view?.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1);
        //self.messageController?.view?.backgroundColor = self.messageController?.view?.alpha = 0.1;
        self.messageController?.view?.isHidden = true;
        
        //Moves the progressing to message ui and changes the progressing message
        let hub = MBProgressHUD.showAdded(to: self.messageController!.view!, animated: true);
        hub.mode = .indeterminate;
        hub.label.text = "Getting started to write\nIt will take much longer for many recipients.".localized();
        hub.label.numberOfLines = 0;
        hub.label.sizeToFit()
        //hub.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);
        hub.contentColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1);
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(noti:)), name: .UIKeyboardWillShow, object: nil);
        self.present(self.messageController!, animated: true) {
            print("Presenting message view controller has been completed");
            
            self.messageController?.view?.alpha = 1.0;
            self.messageController?.view?.isHidden = false;
            self.messageController?.view?.isHidden = false;
            MBProgressHUD.hide(for: self.view, animated: true);
        }
    }
    
    @objc func keyboardWillShow(noti: Notification){
        MBProgressHUD.hide(for: self.messageController!.view, animated: true);
    }
    
    /*@IBAction func onBeginEdit(_ sender: UIBarButtonItem) {
        self.setEditing(true, animated: true);
        let cells = self.tableView.visibleCells;
        for cell in cells{
            cell.accessoryType = .disclosureIndicator;
        }
    }*/
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated);
        
        guard !editing else{
            return;
        }
        
        let indexPaths = self.tableView.indexPathsForVisibleRows ?? [];
        self.tableView.reloadRows(at: indexPaths, with: .automatic);
    }

    @objc func onToggleRuleSwitch(control : UISwitch){
        guard let cell = control.superview as? UITableViewCell else {
            return;
        }
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return;
        }
        
        //Applys the rule state by switching
        let rule = self.rules[indexPath.row];
        rule.enabled = control.isOn;
        self.dataController.saveChanges();
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.rules.count;
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as? SARecipientsTableViewCell;
        let rule = self.rules[indexPath.row];
        
        // Configure the cell...
        //Replaces empty rule title to default title
        cell?.titleLabel.text = (rule.title ?? "").isEmpty ? "Recipients Creation Rule".localized() : rule.title;
        
        //Hides rule detail if rule has title
        if !(cell?.titleLabel.text ?? "").isEmpty{
            cell?.includeLabel.isHidden = true;
            cell?.excludeLabel.isHidden = true;
        }else{
            //Shows rule detail if rule doesn't have title
            cell?.includeLabel.isHidden = false;
            cell?.excludeLabel.isHidden = false;
        }
        
        //Settings the switch to activate
        cell?.enableSwitch.isOn = rule.enabled;
        cell?.enableSwitch.addTarget(self, action: #selector(onToggleRuleSwitch(control:)), for: .valueChanged);

        return cell!;
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Deletes the row from the data source
            let rule = self.rules[indexPath.row];
            self.dataController.removeRecipientsRule(rule: rule);
            self.rules.remove(at: indexPath.row);
            self.dataController.saveChanges();
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: MFMessageComposeViewControllerDelegate
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil);
        controller.dismiss(animated: true) {
            //removes used messaging UI
            self.messageController = nil;
            //view next controller
        }
    }
    
    // MARK: UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
//        print("message view didShow. view[\(viewController)] state[\(viewController.is)]");
    }

    //MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        var value = true;
        guard !(self.navigationController?.topViewController is SARuleTableViewController) else{
            return false;
        }
        
        if identifier == "edit"{
            guard self.tableView.indexPathForSelectedRow != nil else{
                assertionFailure("Could not get selected rule and move to view for it.")
                value = false;
                return value;
            }
        }
        
        return value;
    }
    
    //In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         //Get the new view controller using segue.destinationViewController.
         //Pass the selected object to the new view controller.
        if let view = segue.destination as? SARuleTableViewController{
            self.indexPathForSelectedRow = self.tableView.indexPathForSelectedRow;
            
            if segue.identifier == "edit"{
                let rule = self.rules[self.indexPathForSelectedRow?.row ?? 0];
                view.rule = rule;
                view.navigationItem.title = "Edit Recipients Rule".localized();
            }else if segue.identifier == "add" {
                
            }
            
            if self.isEditing{
                self.setEditing(false, animated: false);
            }
        }
    }
}
