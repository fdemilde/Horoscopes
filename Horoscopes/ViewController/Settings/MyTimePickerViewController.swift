//
//  MyTimePickerViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/23/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class MyTimePickerViewController : UIViewController{
    
    @IBOutlet var picker: UIDatePicker!
    var parentVC : SettingsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.datePickerMode = .time
        picker.backgroundColor = UIColor.clear
        if let parentVC = parentVC{
            let date = Utilities.getDateFromDateString(parentVC.lastSaveNotificationFireTime, format: NOTIFICATION_SETTING_DATE_FORMAT)
            picker.date = date
        }
        
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
   
    @IBAction func timeChange(_ sender: AnyObject) {
        parentVC.doneSelectingTime(picker.date)
    }
    
}
