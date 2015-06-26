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
    var timeTag = NSTimeInterval()
    var signIndex = -1
    
    let SHARE_DIRECT_HEIGHT                     = 235.0 as CGFloat
    let SHARE_HYBRID_HEIGHT                     = 400 as CGFloat
    
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
        print("VC Class = \(NSStringFromClass(parentVC.classForCoder))")
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
        shareVC.type = ShareControlerType.ShareControlerTypeHybrid
        shareVC.timeTag = timeTag
        shareVC.horoscopeSignName = Utilities.getHoroscopeNameWithIndex(signIndex)
        shareVC.sharingText = String(format: "%@",self.horoscopeDesc.text)
        shareVC.pictureURL = String(format: "http://dv7.zwigglers.com/mrest/pic/signs/%d.jpg", self.signIndex + 1)
        
        return shareVC
    }
    
    // MARK: selectors and handlers
    func doRatingRequestWithRateValue(timer:NSTimer){
        var value = timer.userInfo as! NSNumber
        var time = timeTag as NSNumber;
        
    XAppDelegate.horoscopesManager.sendRateRequestWithTimeTag(time.integerValue, signIndex: self.signIndex, rating: value.integerValue)
    }
    
    func rateResultNotificationHandler(notif : NSNotification){
        
        Utilities.hideHUD()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_RATE_HOROSCOPE_RESULT, object: nil)
        var rateResultDict: AnyObject? = notif.object
        println("rateResultNotificationHandler rateResultNotificationHandler = \(rateResultDict)")
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
