//
//  MyTimePickerViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/23/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class MyTimePickerView : UIView{
    
    var picker: UIDatePicker!
    var parentVC : SettingsViewController!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        picker = UIDatePicker(frame: CGRectMake(0, 0, frame.width - 20, frame.height))
        picker.datePickerMode = .Time
        self.addSubview(picker)
        picker.date = NSDate()
        picker.backgroundColor = UIColor.clearColor()
        self.backgroundColor = UIColor.whiteColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
//        self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        parentVC.notificationFireTime = Utilities.getDateStringFromTimestamp(picker.date.timeIntervalSince1970, dateFormat: NOTIFICATION_SETTING_DATE_FORMAT)
        parentVC.doneSelectingTime()
//        self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
    }
    
    
}
