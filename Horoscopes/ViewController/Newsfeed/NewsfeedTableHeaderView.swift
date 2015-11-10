//
//  NewsfeedTableHeaderView.swift
//  Horoscopes
//
//  Created by Binh Dang on 11/10/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class NewsfeedTableHeaderView : UIView {
    var dayLabel = UILabel()
    var monthYearLabel = UILabel()
    var dayOfWeekLabel = UILabel()
    
    let PADDING = 8 as CGFloat
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFont()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupFont(){
        if #available(iOS 8.2, *) {
            dayLabel.font = UIFont.systemFontOfSize(28, weight: UIFontWeightLight)
            monthYearLabel.font = UIFont.systemFontOfSize(11, weight: UIFontWeightMedium)
            dayOfWeekLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: 11)
        } else {
            dayLabel.font = UIFont(name: "HelveticaNeue-Light", size: 30)
            monthYearLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 11)
            dayOfWeekLabel.font = UIFont(name: "HelveticaNeue-LightItalic", size: 11)
        }
        dayLabel.textColor = UIColor.whiteColor()
        monthYearLabel.textColor = UIColor.whiteColor()
        dayOfWeekLabel.textColor = UIColor.whiteColor()
//        dayLabel.backgroundColor = UIColor.blueColor()
//        monthYearLabel.backgroundColor = UIColor.greenColor()
//        dayOfWeekLabel.backgroundColor = UIColor.blackColor()
        self.addSubview(dayLabel)
        self.addSubview(monthYearLabel)
        self.addSubview(dayOfWeekLabel)
    }
    
    func setupDate(date : NSDate){
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        dateFormatter.dateFormat = "dd"
        let day = dateFormatter.stringFromDate(date)
        
        
        dateFormatter.dateFormat = "MMMM YYYY"
        let monthYear = dateFormatter.stringFromDate(date)
        
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.stringFromDate(date)
        
        dayLabel.text = "\(day)"
        dayLabel.sizeToFit()
        
        monthYearLabel.text = "\(monthYear)"
        monthYearLabel.sizeToFit()
        
        dayOfWeekLabel.text = "\(weekDay)"
        dayOfWeekLabel.sizeToFit()
        
        
        dayLabel.frame = CGRectMake(0, 10, dayLabel.frame.width, dayLabel.frame.height)
        monthYearLabel.frame = CGRectMake(dayLabel.frame.width + PADDING, dayLabel.frame.origin.y + 3, monthYearLabel.frame.width, monthYearLabel.frame.height)
        dayOfWeekLabel.frame = CGRectMake(dayLabel.frame.width + PADDING, monthYearLabel.frame.origin.y + monthYearLabel.frame.height, dayOfWeekLabel.frame.width, dayOfWeekLabel.frame.height)
    }
    
}