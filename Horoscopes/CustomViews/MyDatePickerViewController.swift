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
    var parentVC : SettingsViewController!
//    var type : BirthdayParentViewControllerType!
    var birthday : NSDate!
    var selectedMonthIndex = 0
    var selectedDayIndex = 0
    var currentSignIndex = 0
    
    let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    let dayArray29 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29"]
    
    let dayArray30 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]
    
    let dayArray31 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    
    var dateArray = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dateArray = dayArray31
    }
    
    override func viewWillAppear(animated: Bool) {
        self.setCurrentBirthday()
    }
    
    func setupViewController(parent : SettingsViewController, currentSetupBirthday : NSDate?){
        self.parentVC = parent
        self.birthday = currentSetupBirthday
        
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
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var string : String
        if(component == 0){
            string =  monthArray[row]
        } else {
            string = dateArray[row]
        }
        let attDict = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName : UIFont.systemFontOfSize(18.0)]
        let attString = NSAttributedString(string: string, attributes: attDict)
        
        // change separator color to white
        let separator1 = pickerView.subviews[1] 
        separator1.backgroundColor = UIColor.blackColor()
        let separator2 = pickerView.subviews[2] 
        separator2.backgroundColor = UIColor.blackColor()
        return attString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            dateArray = getDayArrayBaseOnMonthIndex(row)
            pickerView.reloadComponent(1)
            selectedMonthIndex = row
            if((selectedDayIndex + 1) > dateArray.count){
                selectedDayIndex = dateArray.count - 1
            }
            
        } else {
            selectedDayIndex = row
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let dateString = String(format:"%@/%@",dateArray[selectedDayIndex],monthArray[selectedMonthIndex])
        let selectedDate = dateFormatter.dateFromString(dateString)
        if let selectedDate = selectedDate {
            
            parentVC.finishedSelectingBirthday(selectedDate)
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    // MARK: Helpers
    func getDayArrayBaseOnMonthIndex(monthIndex : Int) -> [String]{
        if (monthIndex == 0 || monthIndex == 2 || monthIndex == 4 || monthIndex == 6 || monthIndex == 7 || monthIndex == 9 || monthIndex == 11 ){
            return dayArray31
        } else if (monthIndex == 3 || monthIndex == 5 || monthIndex == 8 || monthIndex == 10 ){
            return dayArray30
        } else {
            return dayArray29
        }
    }
    
    
    func setCurrentBirthday(){
        var dateArray = [0, 0]
        if(birthday == nil){ // haven't selected burthday, show first row
            dateArray = self.getMonthAndDayIndexByDate(Utilities.getDefaultBirthday())
            
        } else {
            dateArray = self.getMonthAndDayIndexByDate(birthday)
        }
        picker.selectRow(dateArray[0], inComponent: 0, animated: false)
        picker.selectRow(dateArray[1], inComponent: 1, animated: false)
        selectedDayIndex = dateArray[1]
        selectedMonthIndex = dateArray[0]
    }
    
    // parse current birthday into array of Int as array[0] = month, array[1] = day
    func getMonthAndDayIndexByDate(date : NSDate) -> [Int]{
        var dateArray = [Int]()
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "M"
        dateArray.append(Int(dateFormatter.stringFromDate(date))! - 1)
        dateFormatter.dateFormat = "d"
        dateArray.append(Int(dateFormatter.stringFromDate(date))! - 1)
        return dateArray
    }
    
    // because server requires date should be in DAY/MONTH format
    func getDateStringInNumberFormat(date : NSDate) -> String{
        let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let comp = NSCalendar.currentCalendar().components(components, fromDate: date)
        let result = String(format:"%d/%02d", comp.day, comp.month)
        return result
    }
}