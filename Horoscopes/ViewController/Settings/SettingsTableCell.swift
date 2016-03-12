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
    
    func setupCell(type: SettingsType, title: String){
        self.type = type
        if(self.type == SettingsType.Notification){
            timeLabel.hidden = false
            switchButton.hidden = false
            timeUnderline.hidden = false
            birthdayLabel.hidden = true
            birthdayUnderline.hidden = true
            switchButton.setOn(XAppDelegate.userSettings.notifyOfNewHoroscope, animated: true)
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
        titleLabel.text = title
        if type == .Logout {
            titleLabel.textColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        }
        checkAndChangeSwitchColor()
        
    }
    
    @IBAction func toogleNotification(sender: AnyObject) {
        let switchControl = sender as! UISwitch
        checkAndChangeSwitchColor()
        XAppDelegate.userSettings.notifyOfNewHoroscope = switchControl.on
        parentVC.saveNotificationSetting()
    }
    
    func setupNotificationTime(){
        timeLabel.text = parentVC.notificationFireTime
    }
    
    func setupBirthday(){
        var dateString = ""
        if let birthday = parentVC.birthday{
            dateString = birthday.toStringWithDaySuffix()
        } else {
            dateString = Utilities.getDefaultBirthday().toStringWithDaySuffix()
        }
        birthdayLabel.text = dateString
    }
    
    func checkAndChangeSwitchColor(){
        if switchButton.on {
            switchButton.thumbTintColor = UIColor(red: 108.0/255.0, green: 105.0/255.0, blue: 153.0/255.0, alpha: 1)
        } else {
            switchButton.thumbTintColor = UIColor(red: 201/255.0, green: 201/255.0, blue: 201/255.0, alpha: 1)
        }
    }
}
