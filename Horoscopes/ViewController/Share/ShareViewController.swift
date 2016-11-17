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
    var buttonDefaultSize = CGSize(width: 100, height: 100)
    var timeTag = TimeInterval()
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
    
    var viewType = ShareViewType.shareViewTypeDirect
    var shareType = ShareType.shareTypeDaily
    
    var separateLineView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        self.setupNumberOfButtonsAndPadding()
        self.setupShareButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let label = "type = " + getTypeString() + ", info = " + getInfoString()
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareDialog, label: label)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupNumberOfButtonsAndPadding(){
        // This is a very poor way to implement since I hardcoded the thing
        if (DeviceType.IS_IPHONE_6){
            numberOfButtons = 3
            let paddingX = 18.0 as CGFloat
            buttonDefaultSize = CGSize(width: buttonDefaultSize.width + paddingX , height: buttonDefaultSize.height)
        }  else if (DeviceType.IS_IPHONE_6P){
            numberOfButtons = 4
            buttonDefaultSize = CGSize(width: buttonDefaultSize.width - 2, height: buttonDefaultSize.height)
        }
    }
    
    func setupShareButtons(){
        if(self.viewType == ShareViewType.shareViewTypeHybrid){
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
        separateLineView = UIView(frame: CGRect(x: 0, y: startPosY + buttonDefaultSize.height + paddingSeparator/2, width: self.view.frame.width, height: 1.0))
        separateLineView.backgroundColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1)
        self.shareView.addSubview(separateLineView)
    }
    
     // MARK: create buttons
    
    func createTwitterButton(){
        let twitterBtn = self.createShareButton(ShareButton.ShareButtonType.shareButtonTypeTwitter)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ShareViewController.handleTwTap(_:)))
        twitterBtn.addGestureRecognizer(tap)
    }
    
    func createFacebookButton(){
        let facebookBtn = self.createShareButton(ShareButton.ShareButtonType.shareButtonTypeFacebook)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ShareViewController.handleFBTap(_:)))
        facebookBtn.addGestureRecognizer(tap)
    }
    
    func createMessageButton(){
        let btn = self.createShareButton(ShareButton.ShareButtonType.shareButtonTypeMessages)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ShareViewController.handleMessageTap(_:)))
        btn.addGestureRecognizer(tap)
    }
    
    func createEmailButton(){
        let btn = self.createShareButton(ShareButton.ShareButtonType.shareButtonTypeEmail)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ShareViewController.handleEmailTap(_:)))
        btn.addGestureRecognizer(tap)
    }
    
    func createFBMessageButton(){
        let btn = self.createShareButton(ShareButton.ShareButtonType.shareButtonTypeFBMessenger)
        let tap = UITapGestureRecognizer(target: self, action: #selector(ShareViewController.handleFBMessageTap(_:)))
        btn.addGestureRecognizer(tap)
    }
    
    func createWhatappsButton(){
        let btn = self.createShareButton(ShareButton.ShareButtonType.shareButtonTypeWhatsapp)
        let tap = UITapGestureRecognizer(target: self, action: #selector(ShareViewController.handleWhatsappTap(_:)))
        btn.addGestureRecognizer(tap)
    }
    
    func createShareButton(_ type : ShareButton.ShareButtonType) -> ShareButton{
        let buttonFrame = self.getPosition(currentButtonIndex)
        let button = ShareButton(type: type, frame: buttonFrame)
        button.parentVC = self
        self.shareView.addSubview(button)
        currentButtonIndex += 1
        
        return button
    }
    
    func getPosition(_ index : Int) -> CGRect {
        
        var posX = 0 as CGFloat
        var posY = startPosY
        var row = 0 as Int
        var col = 0 as Int
        
        if(viewType == ShareViewType.shareViewTypeHybrid){
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
        
        
        return CGRect(x: posX,y: posY,width: buttonDefaultSize.width,height: buttonDefaultSize.height)
    }
    
    // MARK: Populate sharing data
    func populateShareData(_ viewType: ShareViewType, shareType: ShareType, timeTag: TimeInterval = 0, horoscopeSignName : String, sharingText: String, pictureURL : String) {
        self.viewType = viewType
        self.shareType = shareType
        self.timeTag = timeTag
        self.horoscopeSignName = horoscopeSignName
        self.sharingText = sharingText
        self.pictureURL = pictureURL
    }
    
    func populateDailyShareData(_ viewType: ShareViewType, timeTag: TimeInterval, horoscopeSign : Int, sharingText: String, pictureURL : String, shareUrl : String){
        self.viewType = viewType
        self.shareType = ShareType.shareTypeDaily
        self.timeTag = timeTag
        self.horoscopeSignName = Utilities.getHoroscopeNameWithIndex(horoscopeSign - 1)
        self.horoscopeSignIndex = horoscopeSign
        self.sharingText = sharingText
        self.pictureURL = pictureURL
        self.shareUrl = shareUrl
        XAppDelegate.socialManager.registerShare(self.shareType, postId:  "", timetag: self.timeTag, sign: self.horoscopeSignIndex) { (result, error) -> Void in
        }
    }
    
    func populateCookieShareData(_ viewType: ShareViewType, sharingText: String, pictureURL : String, shareUrl : String, fortuneId : Int){
        self.viewType = viewType
        self.shareType = ShareType.shareTypeFortune
        self.sharingText = sharingText
        self.pictureURL = pictureURL
        self.shareUrl = shareUrl
        self.fortuneId = fortuneId
        XAppDelegate.socialManager.registerShare(self.shareType, postId:  "", timetag: 0, sign: 0, fortuneId: self.fortuneId) { (result, error) -> Void in
        }
    }
    
    func populateNewsfeedShareData(_ postId : String, viewType: ShareViewType, sharingText: String, pictureURL : String, shareUrl : String){
        self.viewType = viewType
        self.shareType = ShareType.shareTypeNewsfeed
        self.sharingText = sharingText
        self.pictureURL = pictureURL
        self.postId = postId
        self.shareUrl = shareUrl
        XAppDelegate.socialManager.registerShare(self.shareType, postId: self.postId) { (result, error) -> Void in
        }
    }
    
    
    // MARK: Button Tapp gesture handlers
    
    @IBAction func copyURLTapped(_ sender: AnyObject) {
        UIPasteboard.general.string = self.shareUrl
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.detailsLabelFont = UIFont.systemFont(ofSize: 11)
        hud.detailsLabelText = "Copied!"
        hud.hide(true, afterDelay: 2)
    }
    
    func handleFBTap(_ sender: AnyObject){
        let label = "type = " + getTypeString() + ", info = " + getInfoString() + ", method = facebook"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareSelect, label: label)
        shareController = ShareController(eventTrackerStr: label)
        shareController.shareFacebook(self, text: self.getTextIncludingTitle(), pictureURL: pictureURL, url: self.shareUrl)
    }
    
    func handleTwTap(_ sender: AnyObject){
        let label = "type = " + getTypeString() + ", info = " + getInfoString() + ", method = twitter"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareSelect, label: label)
        shareController = ShareController(eventTrackerStr: label)
        shareController.shareTwitter(self, text: self.getTextIncludingTitle(), pictureURL: pictureURL, url: self.shareUrl)
    }
    
    func handleMessageTap(_ sender: AnyObject){
        let label = "type = " + getTypeString() + ", info = " + getInfoString() + ", method = messages"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareSelect, label: label)
        // Obtain a configured MFMessageComposeViewController
        shareController = ShareController(eventTrackerStr: label)
        shareController.shareMessage(self,text: self.getTextIncludingTitle(), shareUrl: self.shareUrl)
    }
    
    func handleEmailTap(_ sender: AnyObject){
        let label = "type = " + getTypeString() + ", info = " + getInfoString() + ", method = email"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareSelect, label: label)
        // Obtain a configured MFMessageComposeViewController
        shareController = ShareController(eventTrackerStr: label)
        shareController.shareMail(self,text: self.getTextIncludingTitle(),shareUrl: self.shareUrl)
    }
    
    func handleFBMessageTap(_ sender: AnyObject){
        // Obtain a configured MFMessageComposeViewController
        let title = self.getTitle()
        shareController = ShareController(eventTrackerStr: "")
        shareController.shareFbMessage(title, text: sharingText, url: self.shareUrl, pictureURL: pictureURL)
    }
    
    func handleWhatsappTap(_ sender: AnyObject){
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
        let whatsappURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        
        return UIApplication.shared.canOpenURL(whatsappURL!)
    }
    
    /*
    Reference: http://stackoverflow.com/questions/25467445/custom-uri-schemes-for-the-facebook-messenger
    */
    
    func isFBMessageAvailable() -> Bool {
        let url = "fb-messenger://compose"
        let fbURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        return UIApplication.shared.canOpenURL(fbURL!)
    }
    
    // MARK: Helpers
    
    func getTypeString() -> String {
        switch shareType {
        case .shareTypeDaily:
            return "horoscope"
        case .shareTypeFortune:
            return "fortune"
        case .shareTypeNewsfeed:
            return "post"
        }
    }
    
    func getInfoString() -> String {
        if shareType == .shareTypeNewsfeed {
            return postId
        }
        let df = DateFormatter()
        df.dateStyle = .full
        let date = Date(timeIntervalSince1970: timeTag)
        let dateString = df.string(from: date)
        return dateString
    }
    
    func getTextIncludingTitle() -> String{
        var text = ""
        
        switch (shareType) {
        case ShareType.shareTypeDaily:
            text = String(format: "Daily %@ Horoscope \n %@",horoscopeSignName,sharingText)
            break
        case ShareType.shareTypeFortune:
            text = String(format: "I read my mobile fortune cookie! \n Lucky Numbers %@",sharingText)
            break
        case ShareType.shareTypeNewsfeed:
            text = String(format: "%@",sharingText)
            break
        }
        return text
    }
    
    func getTitle() -> String{
        var title = ""
        switch (shareType) {
        case ShareType.shareTypeDaily:
            title = String(format: "Daily %@ Horoscope", horoscopeSignName)
            break
        case ShareType.shareTypeFortune:
            title = "Read your fortune cookie"
            break
        case ShareType.shareTypeNewsfeed:
            title = ""
            break
        }
        return title
    }
}
