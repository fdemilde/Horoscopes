//
//  DailyContentTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class DailyContentTableViewCell: UITableViewCell {
    
    let inset: CGFloat = 8
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    // MARK: - Helper
    
    func setUp(type: DailyHoroscopeType, selectedSign: Int) {
        if selectedSign != -1 {
            if type == DailyHoroscopeType.TodayHoroscope {
                dayLabel.text = "Today"
                if let content = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[0] as? String {
                    textView.text = content
                }
            } else {
                dayLabel.text = "Tomorrow"
                if let content = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[1] as? String {
                    textView.text = content
                }
            }
            dateLabel.text = dateStringForType(type)
        }
    }
    
    func dateStringForType(type: DailyHoroscopeType) -> String {
        if type == DailyHoroscopeType.TodayHoroscope {
            if let dictionary = XAppDelegate.horoscopesManager.data["today"] as? Dictionary<String, AnyObject> {
                if let string = dictionary["time_tag"] as? String {
                    let timeInterval = NSTimeInterval((string as NSString).doubleValue)
                    return Utilities.getDateStringFromTimestamp(timeInterval, dateFormat: "MMM, dd YYYY")
                }
            }
        } else {
            if let dictionary = XAppDelegate.horoscopesManager.data["tomorrow"] as? [String: AnyObject] {                if let string = dictionary["time_tag"] as? String {
                    let timeInterval = NSTimeInterval((string as NSString).doubleValue)
                    return Utilities.getDateStringFromTimestamp(timeInterval, dateFormat: "MMM, dd YYYY")
                }
            }
        }
        return ""
    }

}
