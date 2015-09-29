//
//  ArchiveDetailTableCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 9/29/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class ArchiveDetailTableCell : DailyContentTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // setup for Archive View
    func setUp(item : CollectedItem){
        layer.cornerRadius = 0
        clipsToBounds = true
        dayLabel.text = "Archive"
        textView.text = item.horoscope.horoscopes[0] as! String
        timeTag = item.collectedDate.timeIntervalSince1970
        dateLabel.text = Utilities.getDateStringFromTimestamp(timeTag, dateFormat: "MMM dd, YYYY")
        
        calendarButton.hidden = false
        dayLabel.hidden = true
        self.likedLabel.alpha = 0
        self.likedImageView.alpha = 0
        selectedSign = XAppDelegate.horoscopesManager.getSignIndexOfSignName(item.horoscope.sign)
        // BINH BINH: temporary fix
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.footer = Utilities.makeCornerRadius(self.footer, maskFrame: self.bounds, roundOptions: [.BottomLeft, .BottomRight], radius: 4.0)
        }
    }
}