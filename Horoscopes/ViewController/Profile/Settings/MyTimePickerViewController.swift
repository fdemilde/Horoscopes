//
//  MyTimePickerViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/23/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class MyTimePickerViewController : ViewControllerWithAds{
    
    @IBOutlet weak var picker: UIDatePicker!
    var parentVC : SettingsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        picker.date = Utilities.getDateFromDateString(parentVC.notificationFireTime, format: NOTIFICATION_SETTING_DATE_FORMAT)
        println("picker viewDidLoad == \(parentVC.notificationFireTime)")
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        parentVC.notificationFireTime = Utilities.getDateStringFromTimestamp(picker.date.timeIntervalSince1970, dateFormat: NOTIFICATION_SETTING_DATE_FORMAT)
        parentVC.doneSelectingTime()
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
    }
    
    
}
