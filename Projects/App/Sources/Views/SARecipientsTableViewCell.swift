//
//  SARuleTableViewCell.swift
//  sendadv
//
//  Created by 영준 이 on 2017. 1. 27..
//  Copyright © 2017년 leesam. All rights reserved.
//

import UIKit

class SARecipientsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var includeLabel: UILabel!
    @IBOutlet weak var excludeLabel: UILabel!
    @IBOutlet weak var enableSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        //Hides the switch if this cell is editing
        if self.accessoryView === self.enableSwitch{
            if editing{
                self.enableSwitch.isHidden = true;
            }
        }
        
        super.setEditing(editing, animated: animated);
        
        if self.accessoryView === self.enableSwitch{
            if editing{
                self.accessoryType = .disclosureIndicator;
            }else{
                //Shows the switch again when the editing has been completed
                self.enableSwitch.isHidden = false;
                self.enableSwitch.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
                self.enableSwitch.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16).isActive = true;
            }
        }
    }

}
