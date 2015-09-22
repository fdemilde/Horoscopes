//
//  ArchiveCalendarCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 9/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class ArchiveCalendarCell : UITableViewCell, JTCalendarDelegate {
    
    @IBOutlet weak var calendarHolderView: UIView!
    let inset: CGFloat = 8
    var calendarMenuView : JTCalendarMenuView!
    var calendarContentView : JTHorizontalCalendarView!
    var calendarManager : JTCalendarManager!
    var collectedHoroscopes = CollectedHoroscope()
    var parentViewController : ArchiveViewController!
    
    @IBOutlet weak var footer: UIView!
    
    var todayDate = NSDate()
    var dateSelected : NSDate!
    var eventsByDate = [String]()
    
    let CALENDAR_ICON_SPACE_HEIGHT = 50 as CGFloat
    let CALENDAR_MENU_HEIGHT = 40 as CGFloat
    let CALENDAR_CONTENT_HEIGHT = 160 as CGFloat
    let PADDING = 10 as CGFloat
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x = inset
            frame.size.width = UIScreen.mainScreen().bounds.width - 2*inset
            super.frame = frame
        }
    }
    
    func setupCell(parentVC : ArchiveViewController){
        parentViewController = parentVC
        createEvents()
        setupCalendar()
        self.footer = Utilities.makeCornerRadius(self.footer, maskFrame: self.bounds, roundOptions: [.BottomLeft, .BottomRight], radius: 4.0)
        
    }
    
    // MARK: UI
    
    func setupCalendar(){
        calendarManager = JTCalendarManager()
        calendarMenuView = JTCalendarMenuView()
        calendarContentView = JTHorizontalCalendarView()
        calendarManager.delegate = self
        // Calendar menu view
        for view in self.calendarHolderView.subviews { // remove all subviews first
            view.removeFromSuperview()
        }
        calendarHolderView.addSubview(calendarMenuView)
        calendarManager.menuView = calendarMenuView
        calendarHolderView.addSubview(calendarContentView)
        calendarManager.contentView = calendarContentView
        
        calendarManager.setDate(NSDate())
        calendarMenuView.frame = CGRectMake(0, 0, Utilities.getScreenSize().width - PADDING * 2, CALENDAR_MENU_HEIGHT)
        calendarContentView.frame = CGRectMake(0, calendarMenuView.frame.height, Utilities.getScreenSize().width - PADDING * 2, CALENDAR_CONTENT_HEIGHT)
    }
    
    // MARK: Helpers
    
    // Used only to have a key for _eventsByDate
    func dateFormatter() -> NSDateFormatter
    {
        var dateFormatter : NSDateFormatter!
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter;
    }
    
    func haveEventForDay(date : NSDate) -> Bool{
        let key = self.dateFormatter().stringFromDate(date)
        for dateString in eventsByDate {
            if key == dateString { return true }
        }
        
        return false
    }
    
    func createEvents(){
        // Generate 30 random dates between now and 60 days later
        for (var i = 0; i < self.collectedHoroscopes.collectedData.count; ++i){
            let item = collectedHoroscopes.collectedData[i] as! CollectedItem
            let dateformatter = NSDateFormatter()
            dateformatter.dateFormat = "dd-MM-yyyy"
            dateformatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let date = item.collectedDate
            let dateString = self.dateFormatter().stringFromDate(date);
            if !eventsByDate.contains(dateString) {
                eventsByDate.append(dateString)
            }
        }
    }
    
    func getHoroscopesItemWithDate(date : NSDate) -> CollectedItem {
        for (var i = 0; i < self.collectedHoroscopes.collectedData.count; ++i){
            let item = collectedHoroscopes.collectedData[i] as! CollectedItem
            let dateformatter = NSDateFormatter()
            dateformatter.dateFormat = "dd-MM-yyyy"
            dateformatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
            let collectDate = item.collectedDate
            let collectDateString = self.dateFormatter().stringFromDate(collectDate)
            let dateString = self.dateFormatter().stringFromDate(date)
            if(dateString == collectDateString){ return item }
        }
        return CollectedItem()
    }
    
    // MARK: Calendar delegate
    
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        
        if let dayView = dayView as? JTCalendarDayView { // casting
            // from now on, work with myDayView
            // Today
            if(calendarManager.dateHelper.date(NSDate(), isTheSameDayThan: dayView.date)){
                dayView.circleView.hidden = false
                dayView.circleView.backgroundColor = UIColor(red: 255.0/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                dayView.dotView.backgroundColor = UIColor.whiteColor()
                dayView.textLabel.textColor = UIColor.whiteColor()
            }
                // Other month
            else if (!calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayView.date)){
                dayView.circleView.hidden = true
                dayView.dotView.backgroundColor = UIColor(red: 255.0/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                dayView.textLabel.textColor = UIColor(red: 199/255.0, green: 199/255.0, blue: 199/255.0, alpha: 1)
            }
                // Another day of the current month
            else {
                dayView.circleView.hidden = true
                dayView.dotView.backgroundColor = UIColor(red: 255.0/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                dayView.textLabel.textColor = UIColor.blackColor()
            }
            
            if(self.haveEventForDay(dayView.date)){
                dayView.dotView.hidden = false
            }
            else{
                dayView.dotView.hidden = true
            }
            
        }
    }
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        if let dayView = dayView as? JTCalendarDayView { // casting
            
            if(self.haveEventForDay(dayView.date)){
                let collectedItem = getHoroscopesItemWithDate(dayView.date)
                parentViewController.didTapOnArchiveDate(collectedItem)
            }
            
            // Load the previous or next page if touch a day from another month
            if(!(calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayView.date))){
                if(calendarContentView.date.compare(dayView.date) == NSComparisonResult.OrderedAscending){
                    (calendarContentView.loadNextPageWithAnimation())
                }
                else{
                    (calendarContentView.loadPreviousPageWithAnimation())
                }
            }
        }
    }
}