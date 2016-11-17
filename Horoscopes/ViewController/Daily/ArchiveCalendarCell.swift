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
    
    var todayDate = Date()
    var dateSelected : Date!
    var eventsByDate = [String]()
    
    let CALENDAR_ICON_SPACE_HEIGHT = 50 as CGFloat
    let CALENDAR_MENU_HEIGHT = 40 as CGFloat
    let MIN_CALENDAR_HEIGHT = 160 as CGFloat
    let FOOTER_HEIGHT = 44 as CGFloat
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
            frame.size.width = UIScreen.main.bounds.width - 2*inset
            super.frame = frame
        }
    }
    
    func setupCell(_ parentVC : ArchiveViewController){
        parentViewController = parentVC
        createEvents()
        setupCalendar()
        // BINH BINH: temporary fix 
        let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.footer = Utilities.makeCornerRadius(self.footer, maskFrame: self.bounds, roundOptions: [.bottomLeft, .bottomRight], radius: 4.0)
        }
        
        
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
        
        calendarManager.setDate(Date())
        calendarMenuView.frame = CGRect(x: 0, y: 0, width: Utilities.getScreenSize().width - PADDING * 2, height: CALENDAR_MENU_HEIGHT)
        let calendarHeight = max(self.getCalendarHeight(), MIN_CALENDAR_HEIGHT)
        calendarContentView.frame = CGRect(x: 0, y: calendarMenuView.frame.height, width: Utilities.getScreenSize().width - PADDING * 2, height: calendarHeight)
    }
    
    // MARK: Helpers
    
    func getCalendarHeight() -> CGFloat{
        return Utilities.getScreenSize().height - ADMOD_HEIGHT - NAVIGATION_BAR_HEIGHT - (inset * 2) - 150 - CALENDAR_MENU_HEIGHT - FOOTER_HEIGHT -  TABBAR_HEIGHT
    }
    
    // Used only to have a key for _eventsByDate
    func dateFormatter() -> DateFormatter
    {
        var dateFormatter : DateFormatter!
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter;
    }
    
    func haveEventForDay(_ date : Date) -> Bool{
        let key = self.dateFormatter().string(from: date)
        for dateString in eventsByDate {
            if key == dateString { return true }
        }
        
        return false
    }
    
    func createEvents(){
        // Generate 30 random dates between now and 60 days later
        for i in 0..<self.collectedHoroscopes.collectedData.count {
            let item = collectedHoroscopes.collectedData[i] as! CollectedItem
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd-MM-yyyy"
            dateformatter.locale = Locale(identifier: "en_US_POSIX")
            let date = item.collectedDate
            let dateString = self.dateFormatter().string(from: date!);
            if !eventsByDate.contains(dateString) {
                eventsByDate.append(dateString)
            }
        }
    }
    
    func getHoroscopesItemWithDate(_ date : Date) -> CollectedItem {
        for i in 0 ..< self.collectedHoroscopes.collectedData.count {
            let item = collectedHoroscopes.collectedData[i] as! CollectedItem
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd-MM-yyyy"
            dateformatter.locale = Locale(identifier: "en_US_POSIX")
            let collectDate = item.collectedDate
            let collectDateString = self.dateFormatter().string(from: collectDate!)
            let dateString = self.dateFormatter().string(from: date)
            
            if(dateString == collectDateString){ return item }
        }
        return CollectedItem()
    }
    
    // MARK: Calendar delegate
    
    func calendar(_ calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        
        if let dayView = dayView as? JTCalendarDayView { // casting
            // from now on, work with myDayView
            // Today
            if(calendarManager.dateHelper.date(Date(), isTheSameDayThan: dayView.date)){
                dayView.circleView.isHidden = false
                dayView.circleView.backgroundColor = UIColor(red: 255.0/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                dayView.dotView.backgroundColor = UIColor.white
                dayView.textLabel.textColor = UIColor.white
            }
                // Other month
            else if (!calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayView.date)){
                dayView.circleView.isHidden = true
                dayView.dotView.backgroundColor = UIColor(red: 255.0/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                dayView.textLabel.textColor = UIColor(red: 199/255.0, green: 199/255.0, blue: 199/255.0, alpha: 1)
            }
                // Another day of the current month
            else {
                dayView.circleView.isHidden = true
                dayView.dotView.backgroundColor = UIColor(red: 255.0/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
                dayView.textLabel.textColor = UIColor.black
            }
            
            if(self.haveEventForDay(dayView.date)){
                dayView.dotView.isHidden = false
            }
            else{
                dayView.dotView.isHidden = true
            }
            
        }
    }
    
    func calendar(_ calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        
        if let dayView = dayView as? JTCalendarDayView { // casting
            
            if(self.haveEventForDay(dayView.date)){
                let collectedItem = getHoroscopesItemWithDate(dayView.date)
                parentViewController.didTapOnArchiveDate(collectedItem)
            }
            
            // Load the previous or next page if touch a day from another month
            if(!(calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayView.date))){
                if(calendarContentView.date.compare(dayView.date) == ComparisonResult.orderedAscending){
                    (calendarContentView.loadNextPageWithAnimation())
                }
                else{
                    (calendarContentView.loadPreviousPageWithAnimation())
                }
            }
        }
    }
}
