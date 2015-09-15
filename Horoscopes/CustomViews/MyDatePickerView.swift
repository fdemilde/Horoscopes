//
//  MyDatePickerView.swift
//  Horoscopes
//
//  Created by Binh Dang on 9/4/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

@objc protocol MyDatePickerViewDelegate {
    optional func didFinishPickingDate(dayString : String, monthString : String)
}

class MyDatePickerView : UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    var picker : UIPickerView!
    let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    let dayArray29 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29"]
    
    let dayArray30 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30"]
    
    let dayArray31 = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
    
    var dateArray = [String]()
    var selectedMonthIndex = 0
    var selectedDayIndex = 0
    var currentSignIndex = 0
    var selectedView : UIView!
    var oldView : UIView!
    var delegate : MyDatePickerViewDelegate!
    var yearArray : [String]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        picker = UIPickerView(frame: CGRectMake(5, -35, self.frame.width, self.frame.height))
        picker.dataSource = self
        picker.delegate = self
        self.addSubview(picker)
        self.clipsToBounds = true
        dateArray = dayArray31
        yearArray = setupYearArray()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupYearArray() -> [String]!{
        var result = [String]()
        for var index = 1930; index < 2050; ++index {
            result.append("\(index)")
        }
        return result
    }
    
    // MARK: Picker view datasource & Delegate
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        
        var pickerLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickerLabel = UILabel()
            pickerLabel.textAlignment = .Center
            
        }
        var string : String
        if(component == 0){
            string =  monthArray[row]
        } else if component == 1{
            string = dateArray[row]
        } else {
            string = yearArray[row]
        }
        var attString = NSAttributedString(string: string, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        pickerLabel!.attributedText = attString
        
        // change separator color to white
        var separator1 = pickerView.subviews[1] as! UIView
        separator1.backgroundColor = UIColor.whiteColor()
        var separator2 = pickerView.subviews[2] as! UIView
        separator2.backgroundColor = UIColor.whiteColor()
        return pickerLabel
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(component == 0){
            return monthArray.count
        } else if (component == 1){
            return dateArray.count
        } else {
            return yearArray.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(component == 0){
            dateArray = getDayArrayBaseOnMonthIndex(row)
            pickerView.reloadComponent(1)
            selectedMonthIndex = row
            if((selectedDayIndex + 1) > dateArray.count){
                selectedDayIndex = dateArray.count - 1
            }
            
        } else if(component == 1) {
            selectedDayIndex = row
        }
        delegate.didFinishPickingDate?(dateArray[selectedDayIndex], monthString: monthArray[selectedMonthIndex])
        
    }
    
    
    func setCurrentBirthday(birthday : NSDate){
        //        println("setCurrentBirthdaySign setCurrentBirthdaySign ")
        var dateArray = self.getMonthAndDayIndexByDate(birthday)
        picker.selectRow(dateArray[0], inComponent: 0, animated: false)
        picker.selectRow(dateArray[1], inComponent: 1, animated: false)
        selectedDayIndex = dateArray[1]
        selectedMonthIndex = dateArray[0]
        
    }
    
    // MARK: helpers
    
    // parse current birthday into array of Int as array[0] = month, array[1] = day
    func getMonthAndDayIndexByDate(date : NSDate) -> [Int]{
        var dateArray = [Int]()
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "M"
        dateArray.append(dateFormatter.stringFromDate(date).toInt()! - 1)
        dateFormatter.dateFormat = "d"
        dateArray.append(dateFormatter.stringFromDate(date).toInt()! - 1)
        return dateArray
    }
    
    func getDayArrayBaseOnMonthIndex(monthIndex : Int) -> [String]{
        if (monthIndex == 0 || monthIndex == 2 || monthIndex == 4 || monthIndex == 6 || monthIndex == 7 || monthIndex == 9 || monthIndex == 11 ){
            return dayArray31
        } else if (monthIndex == 3 || monthIndex == 5 || monthIndex == 8 || monthIndex == 10 ){
            return dayArray30
        } else {
            return dayArray29
        }
    }
}