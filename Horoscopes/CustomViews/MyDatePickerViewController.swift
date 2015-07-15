//
//  MyDatePickerView.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/15/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class MyDatePickerViewController : UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet var picker : UIPickerView!
    var parentVC : LoginVC!
    var selectedMonthIndex = 0
    var selectedDayIndex = 0
    
    let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    let dayArray29 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
        "25", "26", "27", "28", "29"]
    
    let dayArray30 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
        "25", "26", "27", "28", "29", "30"]
    
    let dayArray31 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
        "25", "26", "27", "28", "29", "30", "31"]
    
    var dateArray = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateArray = dayArray31
    }
    
    // MARK: Picker view datasource & Delegate
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 2
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0){
            return monthArray.count
        } else {
            return dateArray.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if(component == 0){
            return monthArray[row]
        } else {
            return dateArray[row]
        }
       
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            dateArray = getDayArrayBaseOnMonthIndex(row)
            pickerView.reloadComponent(1)
            
            selectedMonthIndex = row
        } else {
            selectedDayIndex = row
        }
    }
    
    // MARK: helpers
    func getDayArrayBaseOnMonthIndex(monthIndex : Int) -> [String]{
        if (monthIndex == 0 || monthIndex == 2 || monthIndex == 4 || monthIndex == 6 || monthIndex == 7 || monthIndex == 9 || monthIndex == 11 ){
            return dayArray31
        } else if (monthIndex == 3 || monthIndex == 5 || monthIndex == 8 || monthIndex == 10 ){
            return dayArray30
        } else {
            return dayArray29
        }
    }
    
    // MARK: Button actions
    
    @IBAction func cancelTapped(sender: AnyObject) {
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "dd-MM"
        var dateString = String(format:"%@-%@",dateArray[selectedDayIndex],monthArray[selectedMonthIndex])
            var selectedDate = dateFormatter.dateFromString(dateString)
        self.parentVC.birthday = selectedDate
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (formsheetController) -> Void in
            self.parentVC.finishedSelectingBirthday()
        })
    }
    
    
}