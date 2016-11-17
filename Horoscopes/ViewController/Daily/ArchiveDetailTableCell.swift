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
    func setUp(_ item : CollectedItem){
        layer.cornerRadius = 0
        clipsToBounds = true
        dayLabel.text = "Archive"
        textView.text = item.horoscope.horoscopes[0] as! String
        timeTag = item.collectedDate.timeIntervalSince1970
        dateLabel.text = Utilities.getDateStringFromTimestamp(timeTag, dateFormat: "MMM dd, yyyy")
        
        calendarButton.isHidden = false
        dayLabel.isHidden = true
        self.likedLabel.alpha = 0
        self.likedImageView.alpha = 0
        selectedSign = XAppDelegate.horoscopesManager.getSignIndexOfSignName(item.horoscope.sign)
        // BINH BINH: temporary fix
        let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.footer = Utilities.makeCornerRadius(self.footer, maskFrame: self.bounds, roundOptions: [.bottomLeft, .bottomRight], radius: 4.0)
        }
    }
}
