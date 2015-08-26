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
    @IBOutlet weak var likedImageView: UIImageView!
    @IBOutlet weak var likedLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
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
        likedImageView.alpha = 0.0
        likedLabel.alpha = 0.0
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
            if let dictionary = XAppDelegate.horoscopesManager.data["tomorrow"] as? [String: AnyObject] {
                if let string = dictionary["time_tag"] as? String {
                    timeTag = NSTimeInterval((string as NSString).doubleValue)
                    return Utilities.getDateStringFromTimestamp(timeTag, dateFormat: "MMM, dd YYYY")
                }
            }
        }
        return ""
    }
    
    func updateLikedLabel(votes : Int, likedPercentage: Int){
        
        var likedString = String(format :"%d%% liked it \u{00B7}", likedPercentage)
        var voteString = String(format :"%d votes", votes)
        
        var resultString = String(format : "%@ %@",likedString, voteString)
        
        var attString = NSMutableAttributedString(string: resultString)
        var likedStringLength = count(likedString)
        
        var voteStringLength = count(voteString)
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, likedStringLength))
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.darkGrayColor(), range: NSMakeRange(0, likedStringLength))
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(13.0), range: NSMakeRange(likedStringLength, (voteStringLength + 1))) // +1 for the space between
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightGrayColor(), range: NSMakeRange(likedStringLength, voteStringLength + 1))
        likedLabel.attributedText = attString
    }
    
    func updateLikedImageView(likedPercentage: Int) {
        let images = likedImageArrayForLikedPercentage(likedPercentage)
        likedImageView.image = images.last
        likedImageView.animationImages = images
        likedImageView.animationDuration = 1.0
        likedImageView.animationRepeatCount = 1
        likedImageView.startAnimating()
    }
    
    func likedImageArrayForLikedPercentage(likedPercentage : Int) -> [UIImage]{
        var result = [UIImage]()
        var lastImageNumber = 1
        
        if(likedPercentage >= 5 && likedPercentage < 23)  { lastImageNumber = 2 }
        if(likedPercentage >= 23 && likedPercentage < 41) { lastImageNumber = 3 }
        if(likedPercentage >= 41 && likedPercentage < 59) { lastImageNumber = 4 }
        if(likedPercentage >= 59 && likedPercentage < 77) { lastImageNumber = 5 }
        if(likedPercentage >= 77 && likedPercentage < 95) { lastImageNumber = 6 }
        if(likedPercentage >= 95 && likedPercentage < 100) { lastImageNumber = 7 }
        
        // add all 12 frame first
        for index in 1...12 {
            result.append(UIImage(named: String(format:"moon_ani_%02d.png",index))!)
        }
        
        // add more images based on like percentage
        for index in 1...lastImageNumber {
            result.append(UIImage(named: String(format:"moon_ani_%02d.png",index))!)
        }
        return result
    }
    
    func animateLike() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
//            self.likeButton.alpha = 0.0
//            self.dislikeButton.alpha = 0.0
            self.likedLabel.alpha = 1.0
            self.likedImageView.alpha = 1.0
        })
    }
    
    // MARK: - Convenience
    
    func updateLikedPercentage(vote: Int, likedPercentage: Int) {
        updateLikedLabel(vote, likedPercentage: likedPercentage)
        updateLikedImageView(likedPercentage)
        animateLike()
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
