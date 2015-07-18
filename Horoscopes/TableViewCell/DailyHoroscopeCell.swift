//
//  HoroscopeDescCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/18/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class DailyHoroscopeCell : UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var horoscopeDesc: UITextView!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var divider: UIImageView!
    @IBOutlet weak var cookieButton: UIButton!
    
    @IBOutlet weak var moonImageView: UIImageView!
    @IBOutlet weak var likePercentageLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    var timeTag = NSTimeInterval()
    var signIndex = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        horoscopeDesc.delegate = self
    }
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(signIndex : Int, desc : String, time : NSTimeInterval, type : DailyHoroscopeType) {
        self.signIndex = signIndex
        var dateString = Utilities.getDateStringFromTimestamp(time,dateFormat: "MMM, dd YYYY")
        self.dateLabel.text = dateString
        self.timeTag = time
        
        switch type{
            case DailyHoroscopeType.TodayHoroscope:
                todayLabel.text = "Today"
            
            case DailyHoroscopeType.TomorrowHoroscope:
                todayLabel.text = "Tomorrow"
                divider.hidden = true
                cookieButton.hidden = true
            default:
                println("")
        }
        self.horoscopeDesc.text = desc
        self.showLikeAndDislikeButton()
        self.hideMoonAndPercentage()
    }
    
    // MARK: Button Action
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        Utilities.showHUD()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rateResultNotificationHandler:", name: NOTIFICATION_RATE_HOROSCOPE_RESULT, object: nil)
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("doRatingRequestWithRateValue:"), userInfo: NSNumber(int: Int32(5)), repeats: false)
    }
    
    @IBAction func dislikeButtonTapped(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "rateResultNotificationHandler:", name: NOTIFICATION_RATE_HOROSCOPE_RESULT, object: nil)
        NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("doRatingRequestWithRateValue:"), userInfo: NSNumber(int: Int32(1)), repeats: false)
    }
    
    @IBAction func cookieButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        var parentVC = Utilities.getParentUIViewController(self) as! UIViewController
        var shareVC = self.prepareShareVC()
        var formSheet = MZFormSheetController(viewController: shareVC)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom
        formSheet.cornerRadius = 0.0
        formSheet.portraitTopInset = parentVC.view.frame.height - SHARE_HYBRID_HEIGHT;
        formSheet.presentedFormSheetSize = CGSizeMake(parentVC.view.frame.width, SHARE_HYBRID_HEIGHT);
        parentVC.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    func prepareShareVC() -> ShareViewController{
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var shareVC = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        var sharingText = String(format: "%@",self.horoscopeDesc.text)
        var pictureURL = String(format: "http://dv7.zwigglers.com/mrest/pic/signs/%d.jpg", self.signIndex + 1)
        var horoscopeSignName = Utilities.getHoroscopeNameWithIndex(signIndex)
        shareVC.populateDailyShareData( ShareViewType.ShareViewTypeHybrid, timeTag: timeTag, horoscopeSignName: horoscopeSignName, sharingText: sharingText, pictureURL: pictureURL)
        return shareVC
    }
    
    // MARK: selectors and handlers
    func doRatingRequestWithRateValue(timer:NSTimer){
        var value = timer.userInfo as! NSNumber
        var time = timeTag as NSNumber;
        
    XAppDelegate.horoscopesManager.sendRateRequestWithTimeTag(time.integerValue, signIndex: self.signIndex, rating: value.integerValue)
    }
    
    func rateResultNotificationHandler(notif : NSNotification){
        
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_RATE_HOROSCOPE_RESULT, object: nil)
        var rateResult: AnyObject? = notif.object
        var rateResultDict = Utilities.parseNSDictionaryToDictionary(rateResult as! NSDictionary)
        Utilities.hideHUD()
        self.displayMoonAndLikeLabel(rateResultDict)
    }
    
    func displayMoonAndLikeLabel(rateResultDict : Dictionary<String, AnyObject>){
        var votes = rateResultDict["total_rates"] as! NSNumber
        var percentLiked = rateResultDict["percent_liked"] as! NSNumber
        self.setupLikePercentageLabel(Int(votes.intValue), percentLiked: Int(percentLiked.intValue))
        self.animateMoon(Int(percentLiked.intValue))
        
    }
    
    func setupLikePercentageLabel(votes : Int, percentLiked: Int){
        
        var likedString = String(format :"%d%% liked it \u{00B7}", percentLiked)
        var voteString = String(format :"%d votes", votes)
        
        var resultString = String(format : "%@ %@",likedString, voteString)
        
        var attString = NSMutableAttributedString(string: resultString)
        var likedStringLength = count(likedString)
        
        var voteStringLength = count(voteString)
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, likedStringLength))
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, likedStringLength))
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(13.0), range: NSMakeRange(likedStringLength, (voteStringLength + 1))) // +1 for the space between
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 145.0/255.0, green: 146.0/255.0, blue: 180.0/255.0, alpha: 1), range: NSMakeRange(likedStringLength, voteStringLength + 1))
        likePercentageLabel.attributedText = attString
    }
    
    func animateMoon(likePercentage : Int){
        var images = getMoonArrayImagesWithPercent(likePercentage)
        moonImageView.image = images.last
        moonImageView.animationImages = images
        moonImageView.animationDuration = 1.0;
        moonImageView.animationRepeatCount = 1;
        moonImageView.startAnimating()
        
        self.showResultWithAnimation()
    }
    
    func showResultWithAnimation(){
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            
            self.likeButton.alpha = 0.0
            self.dislikeButton.alpha = 0.0
            
            self.likePercentageLabel.alpha = 1.0
            self.moonImageView.alpha = 1.0
        })
    }
    
    // MARK: Helpers
    
    func hideLikeAndDislikeButton(){
        self.likeButton.alpha = 0.0
        self.dislikeButton.alpha = 0.0
    }
    
    func showLikeAndDislikeButton(){
        self.likeButton.alpha = 1.0
        self.dislikeButton.alpha = 1.0
    }
    
    func hideMoonAndPercentage(){
        moonImageView.alpha = 0.0
        likePercentageLabel.alpha = 0.0
    }
    
    /*
        when a user click like, run the moon animation the first time (12 frames) 
        and on the second time, stop at the frame of the properly percentage number:
        frame 1: 0 - <5%
        frame 2: 5 - <23%
        frame 3: 23 - <41%
        frame 4: 41 - <59%
        frame 5: 59 - <77%
        frame 6: 77 - <95%
        frame 7: 95 - 100%
    */
    
    func getMoonArrayImagesWithPercent(likePercentage : Int) -> [UIImage]{
        var result = [UIImage]()
        var lastImageNumber = 1
        
        if(likePercentage >= 5 && likePercentage < 23)  { lastImageNumber = 2 }
        if(likePercentage >= 23 && likePercentage < 41) { lastImageNumber = 3 }
        if(likePercentage >= 41 && likePercentage < 59) { lastImageNumber = 4 }
        if(likePercentage >= 59 && likePercentage < 77) { lastImageNumber = 5 }
        if(likePercentage >= 77 && likePercentage < 95) { lastImageNumber = 6 }
        if(likePercentage >= 95 && likePercentage < 100) { lastImageNumber = 7 }
        
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
    
}

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}
