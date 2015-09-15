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
    @IBOutlet weak var timeUnderline: UIView!
    @IBOutlet weak var switchButton: UISwitch!
    
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var birthdayUnderline: UIView!
    
    var type : SettingsType!
    var parentVC : SettingsViewController!
    
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var nextImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(type: SettingsType){
        self.type = type
        
        if(self.type == SettingsType.Notification){
            timeLabel.hidden = false
            switchButton.hidden = false
            timeUnderline.hidden = false
            birthdayLabel.hidden = true
            birthdayUnderline.hidden = true
            switchButton.setOn(parentVC.isNotificationOn, animated: true)
            self.setupNotificationTime()
        } else if self.type == SettingsType.ChangeDOB {
            birthdayLabel.hidden = false
            birthdayUnderline.hidden = false
            timeLabel.hidden = true
            switchButton.hidden = true
            timeUnderline.hidden = true
            self.setupBirthday()
        } else {
            timeLabel.hidden = true
            switchButton.hidden = true
            timeUnderline.hidden = true
            birthdayLabel.hidden = true
            birthdayUnderline.hidden = true
        }
        switch(self.type!){
            case SettingsType.Notification:
                titleLabel.text = "Notify Everyday"
                break;
            case SettingsType.ChangeDOB:
                titleLabel.text = "DOB"
                break;
            case SettingsType.BugsReport:
                titleLabel.text = "Bugs Report"
                break;
            case SettingsType.Logout:
                titleLabel.text = "Logout"
                titleLabel.textColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
                break;
            default:
                break
        }
    }
    
    @IBAction func toogleNotification(sender: AnyObject) {
        var switchControl = sender as! UISwitch
        parentVC.isNotificationOn = switchControl.on
    }
    
    func setupNotificationTime(){
        timeLabel.text = parentVC.notificationFireTime
    }
    
    func setupBirthday(){
        var dateString = ""
        if let birthday = parentVC.birthday{
            dateString = Utilities.getBirthdayString(birthday)
        } else {
            dateString = Utilities.getBirthdayString(Utilities.getDefaultBirthday())
        }
        birthdayLabel.text = dateString
    }
}
