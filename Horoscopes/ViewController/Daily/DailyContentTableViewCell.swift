//
//  DailyContentTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

@objc protocol DailyContentTableViewCellDelegate {
    func didShare(_ horoscopeDescription: String, timeTag: TimeInterval, shareUrl : String)
    @objc optional func didTapOnCalendar()
}

class DailyContentTableViewCell: UITableViewCell {
    
    let inset: CGFloat = 8
    let CALENDAR_BUTTON_SIZE = 18 as CGFloat
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var likedImageView: UIImageView!
    @IBOutlet weak var likedLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet var calendarButton : UIButton!
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var footer: UIView!
    
    var delegate: DailyContentTableViewCellDelegate!
    var timeTag = TimeInterval()
    var selectedSign: Int!
    var shareUrl = ""
    var parentViewController: UIViewController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 5
        clipsToBounds = true
        textView.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
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
            frame.size.width = UIScreen.main.bounds.width - 2*inset
            super.frame = frame
        }
    }
    
    // MARK: - Configuration
    
    func configureNumberOfLike(_ shouldHideIt: Bool) {
        if shouldHideIt {
            self.likedLabel.alpha = 0
            self.likedImageView.alpha = 0
        }
    }
    
    // MARK: - Action
    
    @IBAction func share(_ sender: UIButton) {
        delegate.didShare(textView.text, timeTag: timeTag, shareUrl: self.shareUrl)
    }
    
    @IBAction func like(_ sender: UIButton) {
        let df = DateFormatter()
        df.dateStyle = .full
        let date = Date(timeIntervalSince1970: timeTag)
        let dateString = df.string(from: date)
        let label = "type = horoscope, like = 1, info = " + dateString
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.like, label: label)
        if let controller = parentViewController as? DailyTableViewController {
            controller.shouldHideNumberOfLike = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(DailyContentTableViewCell.rateResultNotificationHandler(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_RATE_HOROSCOPE_RESULT), object: nil)
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(DailyContentTableViewCell.doRatingRequestWithRateValue(_:)), userInfo: NSNumber(value: Int32(5) as Int32), repeats: false)
    }
    
    @IBAction func dislike(_ sender: UIButton) {
        let df = DateFormatter()
        df.dateStyle = .full
        let date = Date(timeIntervalSince1970: timeTag)
        let dateString = df.string(from: date)
        let label = "type = horoscope, like = 0, info = " + dateString
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.like, label: label)
        if let controller = parentViewController as? DailyTableViewController {
            controller.shouldHideNumberOfLike = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(DailyContentTableViewCell.rateResultNotificationHandler(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_RATE_HOROSCOPE_RESULT), object: nil)
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(DailyContentTableViewCell.doRatingRequestWithRateValue(_:)), userInfo: NSNumber(value: Int32(1) as Int32), repeats: false)
    }
    
    @IBAction func calendarTapped(_ sender:UIButton)
    {
        delegate.didTapOnCalendar?()
    }
    
    // MARK: Link delegate, support Hyper link in textview
    
    func linkTextView(_ linkTextView: CCHLinkTextView!, didTapLinkWithValue value: AnyObject!) {
        print("Tapped to link = \(value)")
    }
    
    // MARK: - Helper
    
    func setUp(_ type: DailyHoroscopeType, selectedSign: Int, shareUrl : String, controller: UIViewController) {
        if selectedSign != -1 {
            self.selectedSign = selectedSign
            if type == DailyHoroscopeType.todayHoroscope {
                dayLabel.text = "Today"
            } else {
                dayLabel.text = "Tomorrow"
            }
            dateLabel.text = dateStringForType(type)
            self.shareUrl = shareUrl
        }
        parentViewController = controller
        if let dailyController = controller as? DailyTableViewController {
            configureNumberOfLike(dailyController.shouldHideNumberOfLike)
        }
    }
    
    func dateStringForType(_ type: DailyHoroscopeType) -> String {
        if type == DailyHoroscopeType.todayHoroscope {
            
            if let dictionary = XAppDelegate.horoscopesManager.data["today"] as? Dictionary<String, AnyObject> {
                if let string = dictionary["time_tag"] as? String {
                    timeTag = TimeInterval((string as NSString).doubleValue)
                }
            }

            return Utilities.getDateStringFromTimestamp(Date().timeIntervalSince1970, dateFormat: "MMM dd, yyyy")
        } else {
            if let dictionary = XAppDelegate.horoscopesManager.data["tomorrow"] as? Dictionary<String, AnyObject> {
                if let string = dictionary["time_tag"] as? String {
                    timeTag = TimeInterval((string as NSString).doubleValue)
                }
            }
            return Utilities.getDateStringFromTimestamp((Date().timeIntervalSince1970 + 86400), dateFormat: "MMM dd, yyyy")
        }
    }
    
    func updateLikedLabel(_ votes : Int, likedPercentage: Int){
        
        let likedString = String(format :"%d%% liked it \u{00B7}", likedPercentage)
        let voteString = String(format :"%d votes", votes)
        
        let resultString = String(format : "%@ %@",likedString, voteString)
        
        let attString = NSMutableAttributedString(string: resultString)
        let likedStringLength = likedString.characters.count
        
        let voteStringLength = voteString.characters.count
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 11.0), range: NSMakeRange(0, likedStringLength))
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1), range: NSMakeRange(0, likedStringLength))
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 11.0), range: NSMakeRange(likedStringLength, (voteStringLength + 1))) // +1 for the space between
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 153/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1), range: NSMakeRange(likedStringLength, voteStringLength + 1))
        likedLabel.attributedText = attString
    }
    
    func updateLikedImageView(_ likedPercentage: Int) {
        let images = likedImageArrayForLikedPercentage(likedPercentage)
        likedImageView.image = images.last
        likedImageView.animationImages = images
        likedImageView.animationDuration = 1.0
        likedImageView.animationRepeatCount = 1
        likedImageView.startAnimating()
    }
    
    func likedImageArrayForLikedPercentage(_ likedPercentage : Int) -> [UIImage]{
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
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.likedLabel.alpha = 1.0
            self.likedImageView.alpha = 1.0
        })
    }
    
    // MARK: - Convenience
    
    func updateLikedPercentage(_ vote: Int, likedPercentage: Int) {
        updateLikedLabel(vote, likedPercentage: likedPercentage)
        updateLikedImageView(likedPercentage)
        animateLike()
    }
    
    // MARK: - Selector and handler
    
    func doRatingRequestWithRateValue(_ timer: Timer){
        let value = timer.userInfo as! NSNumber
        let time = timeTag as NSNumber
        XAppDelegate.horoscopesManager.sendRateRequestWithTimeTag(time.intValue, signIndex: selectedSign, rating: value.intValue, viewcontroller: XAppDelegate.window!.rootViewController!)
    }
    
    func rateResultNotificationHandler(_ notif : Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_RATE_HOROSCOPE_RESULT), object: nil)
        let rateResultDictionary = notif.object as! [String: AnyObject]
        var vote = 0
        var likedPercentage = 0
        if let serverVote = rateResultDictionary["total_rates"] as? Int {
            vote = serverVote
        }
        
        if let serverLike = rateResultDictionary["percent_liked"] as? Int {
            likedPercentage = serverLike
        }
        Utilities.hideHUD()
        updateLikedPercentage(vote, likedPercentage: likedPercentage)
    }

}
