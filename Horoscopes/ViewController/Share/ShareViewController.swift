//
//  SharingViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/19/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import Social

class ShareViewController : UIViewController {
    
    
    let startPosY = 55.0 as CGFloat
    
    let paddingSeparator = 30.0 as CGFloat
    var buttonDefaultSize = CGSizeMake(100, 100)
    var timeTag = NSTimeInterval()
    var sharingText = ""
    var pictureURL = ""
    var horoscopeSignName = ""
    var horoscopeSignIndex = 8
    var postId = ""
    var shareUrl = ""
    var shareController: ShareController!
    var numberOfButtons = 3
    var paddingY = 15.0 as CGFloat
    var fortuneId = 0
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var shareView: UIView!
    @IBOutlet weak var shareTitleLabel: UILabel!
    
    @IBOutlet weak var shareViewHeightConstraint: NSLayoutConstraint!
    
    var currentButtonIndex = 0
    
    var viewType = ShareViewType.ShareViewTypeDirect
    var shareType = ShareType.ShareTypeDaily
    
    var separateLineView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        self.setupNumberOfButtonsAndPadding()
        self.setupShareButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let label = "type = " + getTypeString() + ", info = " + getInfoString()
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareDialog, label: label)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setupNumberOfButtonsAndPadding(){
        // This is a very poor way to implement since I hardcoded the thing
        if (DeviceType.IS_IPHONE_6){
            numberOfButtons = 3
            let paddingX = 18.0 as CGFloat
            buttonDefaultSize = CGSizeMake(buttonDefaultSize.width + paddingX , buttonDefaultSize.height)
        }  else if (DeviceType.IS_IPHONE_6P){
            numberOfButtons = 4
            buttonDefaultSize = CGSizeMake(buttonDefaultSize.width - 2, buttonDefaultSize.height)
        }
    }
    
    func setupShareButtons(){
        if(self.viewType == ShareViewType.ShareViewTypeHybrid){
            // include Twitter and Facebook
            self.createFacebookButton()
            self.createTwitterButton()
            self.createSeparatorLine()
        }
        if(self.isMessageAvailable()){self.createMessageButton()}
        if(self.isMailAvailable()){self.createEmailButton()}
//        if(self.isFBMessageAvailable()){self.createFBMessageButton()}
//        if(self.isWhatsappAvailable()){self.createWhatappsButton()}
    }
    
    func createSeparatorLine(){
        separateLineView = UIView(frame: CGRectMake(0, startPosY + buttonDefaultSize.height + paddingSeparator/2, self.view.frame.width, 1.0))
        separateLineView.backgroundColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1)
        self.shareView.addSubview(separateLineView)
    }
    
     // MARK: create buttons
    
    func createTwitterButton(){
        let twitterBtn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeTwitter)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTwTap:"))
        twitterBtn.addGestureRecognizer(tap)
    }
    
    func createFacebookButton(){
        let facebookBtn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeFacebook)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleFBTap:"))
        facebookBtn.addGestureRecognizer(tap)
    }
    
    func createMessageButton(){
        let btn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeMessages)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleMessageTap:"))
        btn.addGestureRecognizer(tap)
    }
    
    func createEmailButton(){
        let btn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeEmail)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleEmailTap:"))
        btn.addGestureRecognizer(tap)
    }
    
    func createFBMessageButton(){
        let btn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeFBMessenger)
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleFBMessageTap:"))
        btn.addGestureRecognizer(tap)
    }
    
    func createWhatappsButton(){
        let btn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeWhatsapp)
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleWhatsappTap:"))
        btn.addGestureRecognizer(tap)
    }
    
    func createShareButton(type : ShareButton.ShareButtonType) -> ShareButton{
        let buttonFrame = self.getPosition(currentButtonIndex)
        let button = ShareButton(type: type, frame: buttonFrame)
        button.parentVC = self
        self.shareView.addSubview(button)
        currentButtonIndex++
        
        return button
    }
    
    func getPosition(index : Int) -> CGRect {
        
        var posX = 0 as CGFloat
        var posY = startPosY
        var row = 0 as Int
        var col = 0 as Int
        
        if(viewType == ShareViewType.ShareViewTypeHybrid){
            /*
            it should have FB and twitter button
            row 1: 1,2
            row 2: 3,4,5 // number of button is based on screen width
            row 3: 6,7
            */
            if (currentButtonIndex <= 1){
                row = 0
                col = currentButtonIndex%2
            } else {
                if (currentButtonIndex <= (numberOfButtons + 1)) {row = 1}
                else {row = 2}
                col = (currentButtonIndex-2)%numberOfButtons
                posY += paddingSeparator + paddingY // if more than 2 buttons, the other buttons should be after the separate line
            }
            
            
        } else {
            /*
            row 1: 1,2,3
            row 2: 4,5
            */
            if (currentButtonIndex <= 2) {row = 0}
            else { row = 1 }
            col = currentButtonIndex%numberOfButtons
        }
        
        
        posX += buttonDefaultSize.width * CGFloat(col)
        posY += buttonDefaultSize.height * CGFloat(row)
        
        
        return CGRectMake(posX,posY,buttonDefaultSize.width,buttonDefaultSize.height)
    }
    
    // MARK: Populate sharing data
    func populateShareData(viewType: ShareViewType, shareType: ShareType, timeTag: NSTimeInterval = 0, horoscopeSignName : String, sharingText: String, pictureURL : String) {
        self.viewType = viewType
        self.shareType = shareType
        self.timeTag = timeTag
        self.horoscopeSignName = horoscopeSignName
        self.sharingText = sharingText
        self.pictureURL = pictureURL
    }
    
    func populateDailyShareData(viewType: ShareViewType, timeTag: NSTimeInterval, horoscopeSign : Int, sharingText: String, pictureURL : String, shareUrl : String){
        self.viewType = viewType
        self.shareType = ShareType.ShareTypeDaily
        self.timeTag = timeTag
        self.horoscopeSignName = Utilities.getHoroscopeNameWithIndex(horoscopeSign - 1)
        self.horoscopeSignIndex = horoscopeSign
        self.sharingText = sharingText
        self.pictureURL = pictureURL
        self.shareUrl = shareUrl
        XAppDelegate.socialManager.registerShare(self.shareType, postId:  "", timetag: self.timeTag, sign: self.horoscopeSignIndex) { (result, error) -> Void in
        }
    }
    
    func populateCookieShareData(viewType: ShareViewType, sharingText: String, pictureURL : String, shareUrl : String, fortuneId : Int){
        self.viewType = viewType
        self.shareType = ShareType.ShareTypeFortune
        self.sharingText = sharingText
        self.pictureURL = pictureURL
        self.shareUrl = shareUrl
        self.fortuneId = fortuneId
        XAppDelegate.socialManager.registerShare(self.shareType, postId:  "", timetag: 0, sign: 0, fortuneId: self.fortuneId) { (result, error) -> Void in
        }
    }
    
    func populateNewsfeedShareData(postId : String, viewType: ShareViewType, sharingText: String, pictureURL : String, shareUrl : String){
        self.viewType = viewType
        self.shareType = ShareType.ShareTypeNewsfeed
        self.sharingText = sharingText
        self.pictureURL = pictureURL
        self.postId = postId
        self.shareUrl = shareUrl
        XAppDelegate.socialManager.registerShare(self.shareType, postId: self.postId) { (result, error) -> Void in
        }
    }
    
    
    // MARK: Button Tapp gesture handlers
    
    @IBAction func copyURLTapped(sender: AnyObject) {
        UIPasteboard.generalPasteboard().string = self.shareUrl
        let hud = MBProgressHUD.showHUDAddedTo(view, animated: true)
        hud.mode = MBProgressHUDMode.Text
        hud.detailsLabelFont = UIFont.systemFontOfSize(11)
        hud.detailsLabelText = "Copied!"
        hud.hide(true, afterDelay: 2)
    }
    
    func handleFBTap(sender: AnyObject){
        let label = "type = " + getTypeString() + ", info = " + getInfoString() + ", method = facebook"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareSelect, label: label)
        shareController = ShareController(eventTrackerStr: label)
        shareController.shareFacebook(self, text: self.getTextIncludingTitle(), pictureURL: pictureURL, url: self.shareUrl)
    }
    
    func handleTwTap(sender: AnyObject){
        let label = "type = " + getTypeString() + ", info = " + getInfoString() + ", method = twitter"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareSelect, label: label)
        shareController = ShareController(eventTrackerStr: label)
        shareController.shareTwitter(self, text: self.getTextIncludingTitle(), pictureURL: pictureURL, url: self.shareUrl)
    }
    
    func handleMessageTap(sender: AnyObject){
        let label = "type = " + getTypeString() + ", info = " + getInfoString() + ", method = messages"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareSelect, label: label)
        // Obtain a configured MFMessageComposeViewController
        shareController = ShareController(eventTrackerStr: label)
        shareController.shareMessage(self,text: self.getTextIncludingTitle(), shareUrl: self.shareUrl)
    }
    
    func handleEmailTap(sender: AnyObject){
        let label = "type = " + getTypeString() + ", info = " + getInfoString() + ", method = email"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareSelect, label: label)
        // Obtain a configured MFMessageComposeViewController
        shareController = ShareController(eventTrackerStr: label)
        shareController.shareMail(self,text: self.getTextIncludingTitle(),shareUrl: self.shareUrl)
    }
    
    func handleFBMessageTap(sender: AnyObject){
        // Obtain a configured MFMessageComposeViewController
        let title = self.getTitle()
        shareController = ShareController(eventTrackerStr: "")
        shareController.shareFbMessage(title, text: sharingText, url: self.shareUrl, pictureURL: pictureURL)
    }
    
    func handleWhatsappTap(sender: AnyObject){
        // Obtain a configured MFMessageComposeViewController
        shareController = ShareController(eventTrackerStr: "")
        shareController.shareWhatapps(self.getTextIncludingTitle(), url: self.shareUrl)
    }
    
    // MARK: checkAvailability
    
    func isMessageAvailable() -> Bool {
        return MFMessageComposeViewController .canSendText()
    }
    
    func isMailAvailable() -> Bool {
        return MFMailComposeViewController .canSendMail()
    }
    
    func isWhatsappAvailable() -> Bool {
        let url = "whatsapp://send?text=a"
        let whatsappURL = NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        
        return UIApplication.sharedApplication().canOpenURL(whatsappURL!)
    }
    
    /*
    Reference: http://stackoverflow.com/questions/25467445/custom-uri-schemes-for-the-facebook-messenger
    */
    
    func isFBMessageAvailable() -> Bool {
        let url = "fb-messenger://compose"
        let fbURL = NSURL(string: url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        return UIApplication.sharedApplication().canOpenURL(fbURL!)
    }
    
    // MARK: Helpers
    
    func getTypeString() -> String {
        switch shareType {
        case .ShareTypeDaily:
            return "horoscope"
        case .ShareTypeFortune:
            return "fortune"
        case .ShareTypeNewsfeed:
            return "post"
        }
    }
    
    func getInfoString() -> String {
        if shareType == .ShareTypeNewsfeed {
            return postId
        }
        let df = NSDateFormatter()
        df.dateStyle = .FullStyle
        let date = NSDate(timeIntervalSince1970: timeTag)
        let dateString = df.stringFromDate(date)
        return dateString
    }
    
//    func getSharingURL() -> String{
//        var urlString = ""
//        switch (shareType) {
//            case ShareType.ShareTypeDaily:
//                let dateString = Utilities.getDateStringFromTimestamp(timeTag, dateFormat: "yyyy-MM-dd")
//                urlString = String(format: "https://horoscopes.zwigglers.com/%@/%d", dateString, horoscopeSignIndex)
////                print("urlString urlString = \(urlString)")
//            break
//            case ShareType.ShareTypeFortune:
//                urlString = "http://apps.facebook.com/getyourfortune/?rf=nf_iphone"
//            break
//        case ShareType.ShareTypeNewsfeed:
//            urlString = String(format: "https://horoscopes.zwigglers.com/post/%@", postId)
////            print("urlString urlString = \(urlString)")
//            break
//        }
//    
//        
//        return urlString
//    }
    
    func getTextIncludingTitle() -> String{
        var text = ""
        
        switch (shareType) {
        case ShareType.ShareTypeDaily:
            text = String(format: "Daily %@ Horoscope \n %@",horoscopeSignName,sharingText)
            break
        case ShareType.ShareTypeFortune:
            text = String(format: "I read my mobile fortune cookie! \n Lucky Numbers %@",sharingText)
            break
        case ShareType.ShareTypeNewsfeed:
            text = String(format: "%@",sharingText)
            break
        }
        return text
    }
    
    func getTitle() -> String{
        var title = ""
        switch (shareType) {
        case ShareType.ShareTypeDaily:
            title = String(format: "Daily %@ Horoscope", horoscopeSignName)
            break
        case ShareType.ShareTypeFortune:
            title = "Read your fortune cookie"
            break
        case ShareType.ShareTypeNewsfeed:
            title = ""
            break
        }
        return title
    }
}