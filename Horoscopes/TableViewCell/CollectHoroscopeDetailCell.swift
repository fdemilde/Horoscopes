//
//  CollectHoroscopeDetailCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/16/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CollectHoroscopeDetailCell : UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var horoscopeDesc: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    var collectedItem : CollectedItem!
    var type : DailyHoroscopeType!
    
    @IBOutlet weak var separatorImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        horoscopeDesc.delegate = self
    }
    
    func setupCell(item : CollectedItem, type: DailyHoroscopeType) {
        collectedItem = item
        self.type = type
        if(type == DailyHoroscopeType.TodayHoroscope){
            todayLabel.text = "Today"
            horoscopeDesc.text = item.horoscope.horoscopes[0] as! String
        } else {
            todayLabel.text = "Tomorrow"
            horoscopeDesc.text = item.horoscope.horoscopes[1] as! String
            separatorImageView.hidden = true
        }
        
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
        var sharingText = String(format: "%@",self.horoscopeDesc.text)
        var signIndex = XAppDelegate.horoscopesManager.getSignIndexOfSignName(self.collectedItem.horoscope.sign)
        var pictureURL = String(format: "http://dv7.zwigglers.com/mrest/pic/signs/%d.jpg", signIndex + 1)
        var horoscopeSignName = self.collectedItem.horoscope.sign
        var timeTag = self.collectedItem.collectedDate.timeIntervalSince1970
        if(type == DailyHoroscopeType.TomorrowHoroscope){
            timeTag += 24*60*60 // tomorrow timetag
        }
        shareVC.populateDailyShareData( ShareViewType.ShareViewTypeHybrid, timeTag: timeTag, horoscopeSignName: horoscopeSignName, sharingText: sharingText, pictureURL: pictureURL)
        return shareVC
    }
}