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
    
    func setupCell(_ type: SettingsType, title: String){
        self.type = type
        if(self.type == SettingsType.notification){
            timeLabel.isHidden = false
            switchButton.isHidden = false
            timeUnderline.isHidden = false
            birthdayLabel.isHidden = true
            birthdayUnderline.isHidden = true
            switchButton.setOn(XAppDelegate.userSettings.notifyOfNewHoroscope, animated: true)
            self.setupNotificationTime()
        } else if self.type == SettingsType.changeDOB {
            birthdayLabel.isHidden = false
            birthdayUnderline.isHidden = false
            timeLabel.isHidden = true
            switchButton.isHidden = true
            timeUnderline.isHidden = true
            separator.isHidden = true
            self.setupBirthday()
        } else if self.type == SettingsType.changeSign {
            birthdayLabel.isHidden = false
            birthdayUnderline.isHidden = false
            timeLabel.isHidden = true
            switchButton.isHidden = true
            timeUnderline.isHidden = true
            self.setupSign()
        }else {
            timeLabel.isHidden = true
            switchButton.isHidden = true
            timeUnderline.isHidden = true
            birthdayLabel.isHidden = true
            birthdayUnderline.isHidden = true
        }
        titleLabel.text = title
        if type == .logout {
            titleLabel.textColor = UIColor(red: 231.0/255.0, green: 76.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        }
        checkAndChangeSwitchColor()
        
    }
    
    @IBAction func toogleNotification(_ sender: AnyObject) {
        let switchControl = sender as! UISwitch
        checkAndChangeSwitchColor()
        XAppDelegate.userSettings.notifyOfNewHoroscope = switchControl.isOn
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
    
    func setupSign(){
        var sign = ""
        if let birthday = parentVC.birthday {
            sign = XAppDelegate.horoscopesManager.getSignNameOfDate(birthday)
        } else {
            sign = XAppDelegate.horoscopesManager.getSignNameOfDate(Utilities.getDefaultBirthday())
        }
        birthdayLabel.text = sign
    }
    
    func checkAndChangeSwitchColor(){
        if switchButton.isOn {
            switchButton.thumbTintColor = UIColor(red: 108.0/255.0, green: 105.0/255.0, blue: 153.0/255.0, alpha: 1)
        } else {
            switchButton.thumbTintColor = UIColor(red: 201/255.0, green: 201/255.0, blue: 201/255.0, alpha: 1)
        }
    }
}
