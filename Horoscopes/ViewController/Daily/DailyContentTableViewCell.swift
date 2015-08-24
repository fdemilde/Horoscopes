//
//  DailyContentTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

protocol DailyContentTableViewCellDelegate {
    func didShare(horoscopeDescription: String, timeTag: NSTimeInterval)
}

class DailyContentTableViewCell: UITableViewCell {
    
    let inset: CGFloat = 8
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    var delegate: DailyContentTableViewCellDelegate!
    var timeTag = NSTimeInterval()
    var selectedSign: Int!
    
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
    
    // MARK: - Action
    
    @IBAction func share(sender: UIButton) {
        delegate.didShare(textView.text, timeTag: timeTag)
    }
    
    @IBAction func like(sender: UIButton) {
        Utilities.showHUD()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rateResultNotificationHandler:", name: NOTIFICATION_RATE_HOROSCOPE_RESULT, object: nil)
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("doRatingRequestWithRateValue:"), userInfo: NSNumber(int: Int32(5)), repeats: false)
    }
    
    @IBAction func dislike(sender: UIButton) {
        Utilities.showHUD()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rateResultNotificationHandler:", name: NOTIFICATION_RATE_HOROSCOPE_RESULT, object: nil)
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("doRatingRequestWithRateValue:"), userInfo: NSNumber(int: Int32(1)), repeats: false)
    }
    
    // MARK: - Helper
    
    func setUp(type: DailyHoroscopeType, selectedSign: Int) {
        if selectedSign != -1 {
            self.selectedSign = selectedSign
            if type == DailyHoroscopeType.TodayHoroscope {
                dayLabel.text = "Today"
                if let horoscopeDescription = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[0] as? String {
                    textView.text = horoscopeDescription
                }
            } else {
                dayLabel.text = "Tomorrow"
                if let horoscopeDescription = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[1] as? String {
                    textView.text = horoscopeDescription
                }
            }
            dateLabel.text = dateStringForType(type)
        }
    }
    
    func dateStringForType(type: DailyHoroscopeType) -> String {
        if type == DailyHoroscopeType.TodayHoroscope {
            if let dictionary = XAppDelegate.horoscopesManager.data["today"] as? Dictionary<String, AnyObject> {
                if let string = dictionary["time_tag"] as? String {
                    timeTag = NSTimeInterval((string as NSString).doubleValue)
                    return Utilities.getDateStringFromTimestamp(timeTag, dateFormat: "MMM, dd YYYY")
                }
            }
        } else {
            if let dictionary = XAppDelegate.horoscopesManager.data["tomorrow"] as? [String: AnyObject] {                if let string = dictionary["time_tag"] as? String {
                    timeTag = NSTimeInterval((string as NSString).doubleValue)
                    return Utilities.getDateStringFromTimestamp(timeTag, dateFormat: "MMM, dd YYYY")
                }
            }
        }
        return ""
    }
    
    func updateLikedPercentage(vote: Int, likedPercentage: Int) {
        // TODO: Update the moon image and the like label
    }
    
    // MARK: - Selector and handler
    
    func doRatingRequestWithRateValue(timer: NSTimer){
        var value = timer.userInfo as! NSNumber
        var time = timeTag as NSNumber
        XAppDelegate.horoscopesManager.sendRateRequestWithTimeTag(time.integerValue, signIndex: selectedSign, rating: value.integerValue)
    }
    
    func rateResultNotificationHandler(notif : NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_RATE_HOROSCOPE_RESULT, object: nil)
        let rateResultDictionary = notif.object as! [String: AnyObject]
        let vote = rateResultDictionary["total_rates"] as! Int
        let likedPercentage = rateResultDictionary["percent_liked"] as! Int
        Utilities.hideHUD()
        updateLikedPercentage(vote, likedPercentage: likedPercentage)
    }

}
