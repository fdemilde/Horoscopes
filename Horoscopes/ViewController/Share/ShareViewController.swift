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
    let padding = 15.0 as CGFloat
    let paddingSeparator = 30.0 as CGFloat
    var buttonDefaultSize = CGSizeMake(90, 100)
    var timeTag = NSTimeInterval()
    var sharingText = ""
    var pictureURL = ""
    var horoscopeSignName = ""
    var shareController = ShareController()
    
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
        self.setupShareButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
        if(self.isFBMessageAvailable()){self.createFBMessageButton()}
        if(self.isWhatsappAvailable()){self.createWhatappsButton()}
    }
    
    func createSeparatorLine(){
        separateLineView = UIView(frame: CGRectMake(20, startPosY + buttonDefaultSize.height + paddingSeparator/2, self.view.frame.width - 40, 1.0))
        separateLineView.backgroundColor = UIColor(red: 105.0/255.0, green: 67.0/255.0, blue: 106.0/255.0, alpha: 1)
        self.shareView.addSubview(separateLineView)
    }
    
     // MARK: create buttons
    
    func createTwitterButton(){
        var twitterBtn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeTwitter)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleTwTap:"))
        twitterBtn.addGestureRecognizer(tap)
    }
    
    func createFacebookButton(){
        var facebookBtn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeFacebook)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleFBTap:"))
        facebookBtn.addGestureRecognizer(tap)
    }
    
    func createMessageButton(){
        var btn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeMessages)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleMessageTap:"))
        btn.addGestureRecognizer(tap)
    }
    
    func createEmailButton(){
        var btn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeEmail)
        
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleEmailTap:"))
        btn.addGestureRecognizer(tap)
    }
    
    func createFBMessageButton(){
        var btn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeFBMessenger)
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleFBMessageTap:"))
        btn.addGestureRecognizer(tap)
    }
    
    func createWhatappsButton(){
        var btn = self.createShareButton(ShareButton.ShareButtonType.ShareButtonTypeWhatsapp)
        let tap = UITapGestureRecognizer(target: self, action: Selector("handleWhatsappTap:"))
        btn.addGestureRecognizer(tap)
    }
    
    func createShareButton(type : ShareButton.ShareButtonType) -> ShareButton{
        var buttonFrame = self.getPosition(currentButtonIndex)
        var button = ShareButton(type: type, frame: buttonFrame)
        button.parentVC = self
        self.shareView.addSubview(button)
        currentButtonIndex++
        return button
    }
    
    func getPosition(index : Int) -> CGRect {
        var posX = (self.view.frame.width - buttonDefaultSize.width*3 - padding*2)/2
        var posY = startPosY
        var row = 0 as Int
        var col = 0 as Int
        
        if(viewType == ShareViewType.ShareViewTypeHybrid){
            /*
            it should have FB and twitter button
            row 1: 1,2
            row 2: 3,4,5
            row 3: 6,7
            */
            if (currentButtonIndex <= 1){
                row = 0
                col = currentButtonIndex%2
            } else {
                if (currentButtonIndex <= 4) {row = 1}
                else {row = 2}
                col = (currentButtonIndex-2)%3
                println("button index = \(currentButtonIndex) || separateLine height = \(separateLineView.frame.height)")
                posY += paddingSeparator + padding // if more than 2 buttons, the other buttons should be after the separate line
            }
            
            
        } else {
            /*
            row 1: 1,2,3
            row 2: 4,5
            */
            if (currentButtonIndex <= 2) {row = 0}
            else { row = 1 }
            col = currentButtonIndex%3
        }
        
        
        posX += buttonDefaultSize.width * CGFloat(col)
        posY += buttonDefaultSize.height * CGFloat(row)
        
        
        return CGRectMake(posX,posY,buttonDefaultSize.width,buttonDefaultSize.height)
    }
    
    // MARK: Populate sharing data
    func populateDailyShareData(viewType: ShareViewType, timeTag: NSTimeInterval, horoscopeSignName : String, sharingText: String, pictureURL : String){
        self.viewType = viewType
        self.shareType = ShareType.ShareTypeDaily
        self.timeTag = timeTag
        self.horoscopeSignName = horoscopeSignName
        self.sharingText = sharingText
        self.pictureURL = pictureURL
    }
    
    func populateCookieShareData(viewType: ShareViewType, sharingText: String, pictureURL : String){
        self.viewType = viewType
        self.shareType = ShareType.ShareTypeFortune
        self.sharingText = sharingText
        self.pictureURL = pictureURL
    }
    
    func populateNewsfeedShareData(viewType: ShareViewType, sharingText: String, pictureURL : String){
        self.viewType = viewType
        self.shareType = ShareType.ShareTypeNewsfeed
        self.sharingText = sharingText
        self.pictureURL = pictureURL
    }
    
    // MARK: Button Tapp gesture handlers
    func handleFBTap(sender: AnyObject){
        
        shareController.shareFacebook(self, text: self.getTextIncludingTitle(), pictureURL: pictureURL, url: getSharingURL())
    }
    
    func handleTwTap(sender: AnyObject){
        shareController.shareTwitter(self, text: self.getTextIncludingTitle(), pictureURL: pictureURL, url: getSharingURL())
    }
    
    func handleMessageTap(sender: AnyObject){
        // Obtain a configured MFMessageComposeViewController
        shareController.shareMessage(self,text: self.getTextIncludingTitle())
    }
    
    func handleEmailTap(sender: AnyObject){
        // Obtain a configured MFMessageComposeViewController
        shareController.shareMail(self,text: self.getTextIncludingTitle())
    }
    
    func handleFBMessageTap(sender: AnyObject){
        // Obtain a configured MFMessageComposeViewController
        var title = self.getTitle()
        shareController.shareFbMessage(title, text: sharingText, url: self.getSharingURL(), pictureURL: pictureURL)
    }
    
    func handleWhatsappTap(sender: AnyObject){
        // Obtain a configured MFMessageComposeViewController
        shareController.shareWhatapps(self.getTextIncludingTitle(), url: self.getSharingURL())
    }
    
    // MARK: checkAvailability
    
    func isMessageAvailable() -> Bool {
        return MFMessageComposeViewController .canSendText()
    }
    
    func isMailAvailable() -> Bool {
        return MFMailComposeViewController .canSendMail()
    }
    
    func isWhatsappAvailable() -> Bool {
        var url = "whatsapp://send?text=a"
        var whatsappURL = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        return UIApplication.sharedApplication().canOpenURL(whatsappURL!)
    }
    
    /*
    Reference: http://stackoverflow.com/questions/25467445/custom-uri-schemes-for-the-facebook-messenger
    */
    
    func isFBMessageAvailable() -> Bool {
        var url = "fb-messenger://compose"
        var fbURL = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        
        return UIApplication.sharedApplication().canOpenURL(fbURL!)
    }
    
    // MARK: Helpers
    
    func getSharingURL() -> String{
        var urlString = ""
        switch (shareType) {
            case ShareType.ShareTypeDaily:
                urlString = String(format: "http://apps.facebook.com/phonehoroscopes/read.php?rf=nf_iphone&tag=%f&ref_id=%@", timeTag, FACEBOOK_APP_ID)
            break
            case ShareType.ShareTypeFortune:
                urlString = "http://apps.facebook.com/getyourfortune/?rf=nf_iphone"
            break
        case ShareType.ShareTypeNewsfeed:
            urlString = "https://apps.facebook.com/getyourhoroscope/?rf=mobile"
            break
        }
        
        
        return urlString
    }
    
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