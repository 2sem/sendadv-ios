//
//  SAFilterTableViewController.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 31..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class SAFilterTableViewController: UITableViewController {
    let cell_id = "SAFilterTableViewCell";
    let header_id = "headerViewCell";

    var list : [String] = [];
    var includes : [String] = [];
    var filter : SAFilterRule!;
    var rule : SARecipientsRule!;

    let dataController = SAModelController.Default;
    class TransactionNames{
        static let Filter = "Filter";
    }
    var target = "";
    
    var toggleAllSwitch : UISwitch!{
        var value : UISwitch?;
        guard self.tableView != nil else{
            return value;
        }
        
        guard let header = self.tableView(self.tableView, viewForHeaderInSection: 0) as? UITableViewCell else{
            return value;
        }
        guard let toggleSwitch = header.accessoryView as? UISwitch else{
            return value;
        }
        value = toggleSwitch
        
        return value;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.hideExtraRows = true;
        
        assert(self.rule != nil, "Rule should be not nil")
        self.dataController.beginTransaction(transactionName: TransactionNames.Filter);
        
        //Finds filter by filter type
        let filters = self.rule?.filters?.allObjects as? [SAFilterRule];
        self.filter = [SAFilterRule](filters ?? []).first(where: { (f) -> Bool in
            return f.target == self.target;
        })
        
        //Creates filter if there is no filter for the target type
        if self.filter == nil{
            self.filter = SAModelController.Default.createFilterRule(target: self.target);
            self.filter?.all = true;
            self.rule?.addToFilters(self.filter);
            self.filter?.owner = self.rule;
        }else{
            //Split keyword1, keyword2, keyword3 to [keyword1, keyword2, keyword3]
            self.includes = (self.filter.includes ?? "").components(separatedBy: ",").filter({ (f) -> Bool in
                return !f.isEmpty;
            });
        }
        
        self.list = self.list.sorted();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.navigationBar.backItem?.title = ";;;";
        self.title = self.navigationItem.title;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dataController.endTransaction();
        if !self.isDone{
            self.dataController.undo();
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var isDone = false;
    @IBAction func onDone(_ button: UIBarButtonItem) {
        //merge keywords with , to store as Database
        self.filter.includes = self.includes.filter({ (f) -> Bool in
            return !f.isEmpty;
        }).joined(separator: ",");
        
        self.isDone = true;
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onToggleAll(_ control: UISwitch) {
        self.filter.all = control.isOn;
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        guard section > 0 else{
//            return 1;
//        }
        
        return self.list.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_id, for: indexPath) as? SAFilterTableViewCell;

        cell?.textLabel?.textColor = UIColor.white;
        let text = self.list[indexPath.row];
        //Shows activation state by setting accessoryView
        cell?.accessoryType = self.includes.contains(text) ? .checkmark : .none;
        cell?.textLabel?.text = text;
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SAFilterTableViewCell else{
            return;
        }
        
        switch cell.accessoryType{
            case .checkmark:
                cell.accessoryType = .none;
                let idx = self.includes.index(of: cell.textLabel?.text ?? "") ?? -1;
                if idx >= 0 {
                    self.includes.remove(at: idx);
                }
                break;
            case .none:
                cell.accessoryType = .checkmark;
                self.includes.append(cell.textLabel?.text ?? "");
                if self.filter.all {
                    self.filter.all = false
                    //self.toggleAllSwitch.isOn = ;
                    //self.toggleAllSwitch.setOn(false, animated: true);
                    tableView.reloadData();
                }
                self.dataController.saveChanges();
                break;
            default:
                break;
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: header_id);
        
        guard header != nil else{
            return header;
        }
        
        let control = header?.accessoryView as? UISwitch;
        control?.isOn = self.filter.all;
        
        control?.addTarget(self, action: #selector(onToggleAll(_:)), for: .valueChanged);
        
        control?.trailingAnchor.constraint(equalTo: header!.trailingAnchor, constant: -16).isActive = true;
        control?.centerYAnchor.constraint(equalTo: header!.centerYAnchor).isActive = true;
        
        return header;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44;
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
