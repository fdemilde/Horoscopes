//
//  SettingsTableCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit
class SettingsTableCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    var type : SettingsType!
    
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var nextImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(type: SettingsType){
        self.type = type
        if(self.type != SettingsType.Notification){
            timeLabel.hidden = true
            switchButton.hidden = true
        }
        if(self.type == SettingsType.ChangeName || self.type == SettingsType.ChangeDOB || self.type == SettingsType.BugsReport){
            nextImageView.hidden = false
        }
        switch(self.type!){
            case SettingsType.Notification:
                titleLabel.text = "Notify Everyday"
                break;
            case SettingsType.ChangeName:
                titleLabel.text = "Change Name"
                break;
            case SettingsType.ChangeDOB:
                titleLabel.text = "Change DOB"
                break;
            case SettingsType.BugsReport:
                titleLabel.text = "Bugs Report"
                break;
            case SettingsType.Logout:
                titleLabel.text = "Logout"
                break;
            default:
                break
        }
    }
}
