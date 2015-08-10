//
//  PostCellNode.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/1/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class PostCellNode : ASCellNode, UIAlertViewDelegate {
    
    let BG_PADDING_LEFT = 30 as CGFloat
    let BG_PADDING_RIGHT = 5 as CGFloat
    let BG_PADDING_BOTTOM = 10 as CGFloat
    
    // the background will be divided into 3 parts: top, description part and bottom part
    // we will hard code top and bottom height since they will not change, only calculate desc height
    let BG_TOP_HEIGHT = 55 as CGFloat
    let BG_BOTTOM_HEIGHT = 55 as CGFloat
    let PROFILE_IMAGE_WIDTH = 30 as CGFloat
    let PROFILE_IMAGE_HEIGHT = 30 as CGFloat
    
    let TYPE_IMAGE_WIDTH = 22 as CGFloat
    let TYPE_IMAGE_HEIGHT = 22 as CGFloat
    let TYPE_IMAGE_PADDING_TOP = 15 as CGFloat
    let TYPE_IMAGE_PADDING_LEFT = 5 as CGFloat
    
    let DESCRIPTION_PADDING_LEFT = 15 as CGFloat
    
    let CELL_PADDING_BOTTOM = 10 as CGFloat
    
    
    var feedTypeImageNode : ASImageNode?
    var background : ASDisplayNode?
    var profilePicture : ASNetworkImageNode?
    var userNameLabelNode : ASTextNode?
    var feedTypeLabelNode : ASTextNode?
    var userDescLabelNode : ASTextNode?
    var feedDescriptionLabelNode : ASTextNode?
    var locationLabelNode : ASTextNode?
    var heartNumberLabelNode : ASTextNode?
    var separator : ASDisplayNode?
    var heartImageView : ASImageNode?
    var sendAHeartButton : UIButton?
    var shareImageView : ASImageNode?
    var shareButton : UIButton?
    
    var userPost : UserPost?
    var type = PostCellType.Newsfeed
    var parentViewController: UIViewController!
    var gestureRecognizer: UITapGestureRecognizer!
    
    required init(post : UserPost, type : PostCellType, parentViewController: UIViewController){
        super.init()
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.userPost = post
        self.type = type
        self.parentViewController = parentViewController
        self.createFeedTypeImage()
        self.createBackground()
        self.createFeedHeader()
        self.createFeedDescirption()
        self.createFeedHeartTextNode()
        self.createSeparator()
        self.createButtons()
    }
    
    // MARK: create components
    
    func createFeedTypeImage(){
        feedTypeImageNode = ASImageNode()
        feedTypeImageNode?.backgroundColor = UIColor.clearColor()
        feedTypeImageNode?.image = UIImage(named: (Utilities.getFeedTypeImageName(userPost!)))
        self.addSubnode(feedTypeImageNode)
    }
    
    func createBackground(){
        background = ASDisplayNode()
        background?.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 242.0/255.0, alpha: 1)
        self.addSubnode(background);
    }
    
    func createFeedHeader(){
        // header includes profile image, user name, user share text and time passed
        profilePicture = ASNetworkImageNode(webImage: ())
        if type == .Profile {
            profilePicture?.cornerRadius = PROFILE_IMAGE_WIDTH / 2
            profilePicture?.clipsToBounds = true
            profilePicture?.backgroundColor = UIColor.profileImagePurpleColor()
        }
        profilePicture?.URL = NSURL(string: userPost!.user!.imgURL)
        background!.addSubnode(profilePicture)
//        userPost!.user!.name
        userNameLabelNode = ASTextNode()
        var nameWithPostTypeString = String(format : "%@ %@",userPost!.user!.name , self.getFeedTypeText())
        var attString = NSMutableAttributedString(string: nameWithPostTypeString)
        var nameStringLength = count(userPost!.user!.name)
        var nameWithPostTypeStringLength = count(nameWithPostTypeString)
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, nameStringLength))
//        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(11.0), range: NSMakeRange(nameStringLength, nameWithPostTypeStringLength-1))
        
        userNameLabelNode?.attributedString = attString
        background!.addSubnode(userNameLabelNode)
        
        userDescLabelNode = ASTextNode()
        let timeDict = [NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
        userDescLabelNode?.attributedString = NSAttributedString(string: self.getUserDescString(), attributes: timeDict)
        background!.addSubnode(userDescLabelNode)
        
        locationLabelNode = ASTextNode()
        locationLabelNode?.attributedString = NSAttributedString(string: userPost!.user!.location, attributes: timeDict)
        background!.addSubnode(locationLabelNode)
        
        if type == .Profile {
            if let viewController = parentViewController as? ProfileViewController {
                if viewController.profileType == ProfileType.OtherUser {
                    enableUserProfileInteraction()
                }
            }
        } else {
            enableUserProfileInteraction()
        }
    }
    
    func createFeedDescirption(){
        feedDescriptionLabelNode = ASTextNode()
        let dict = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
        // data : userPost!.message
        feedDescriptionLabelNode?.attributedString = NSAttributedString(string: userPost!.message, attributes: dict)
        background!.addSubnode(feedDescriptionLabelNode)
        
        
    }
    
    func createFeedHeartTextNode(){
        heartNumberLabelNode = ASTextNode()
        let dict = [NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
        heartNumberLabelNode?.attributedString = NSAttributedString(string:String(format:"%d hearts",userPost!.hearts), attributes: dict)
        background!.addSubnode(heartNumberLabelNode)
    }
    
    func createSeparator(){
        separator = ASDisplayNode()
        separator?.backgroundColor = UIColor(red: 215.0/255.0, green: 215.0/255.0, blue: 216.0/255.0, alpha: 1)
        background!.addSubnode(separator);
    }
    
    func createButtons(){
        
        sendAHeartButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        sendAHeartButton!.backgroundColor = UIColor.clearColor()
        sendAHeartButton!.setTitle("Send A Heart", forState: UIControlState.Normal)
        sendAHeartButton?.setTitleColor(UIColor(red: 27.0/255.0, green: 0/255.0, blue: 89.0/255.0, alpha: 1), forState: UIControlState.Normal)
        sendAHeartButton?.titleLabel?.font =  UIFont.systemFontOfSize(13)
        sendAHeartButton!.setImage(UIImage(named: "newsfeed_heart_icon"), forState: UIControlState.Normal)
        sendAHeartButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left;
        sendAHeartButton!.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        sendAHeartButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        sendAHeartButton!.addTarget(self, action: "sendHeartTapped", forControlEvents: UIControlEvents.TouchUpInside)
        if type == .Profile {
            if let viewController = parentViewController as? ProfileViewController {
                if viewController.profileType == ProfileType.CurrentUser {
                    sendAHeartButton?.hidden = true
                }
            }
        }
        
        
        shareImageView = ASImageNode()
        shareImageView?.backgroundColor = UIColor.clearColor()
        shareImageView?.image = UIImage(named: "newsfeed_share_icon")
        background!.addSubnode(shareImageView)
        
        shareButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
        shareButton!.backgroundColor = UIColor.clearColor()
        shareButton!.setTitle("Share", forState: UIControlState.Normal)
        shareButton?.titleLabel?.font =  UIFont.systemFontOfSize(13)
        shareButton?.setTitleColor(UIColor(red: 27.0/255.0, green: 0/255.0, blue: 89.0/255.0, alpha: 1), forState: UIControlState.Normal)
        shareButton!.setImage(UIImage(named: "newsfeed_share_icon"), forState: UIControlState.Normal)
        shareButton!.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Right;
        shareButton!.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10);
        shareButton!.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        shareButton!.addTarget(self, action: "shareTapped", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    
    // MARK: layout 
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        
        var headerHeight = BG_TOP_HEIGHT;
        var footerHeight = BG_BOTTOM_HEIGHT;
        /// calculate the text in middle + padding
        
        var feedDescriptionLabelSize = CGSizeMake(constrainedSize.width - BG_PADDING_LEFT - BG_PADDING_RIGHT - DESCRIPTION_PADDING_LEFT * 2 , CGFloat(FLT_MAX))
        
        var userNameLabelNodeLabelSize = CGSizeMake(constrainedSize.width - BG_PADDING_LEFT - BG_PADDING_RIGHT - DESCRIPTION_PADDING_LEFT * 2 - PROFILE_IMAGE_WIDTH - TYPE_IMAGE_PADDING_LEFT * 2, CGFloat(FLT_MAX))
        userNameLabelNode?.measure(userNameLabelNodeLabelSize)
        userDescLabelNode?.measure(constrainedSize)
        locationLabelNode?.measure(constrainedSize)
        feedDescriptionLabelNode?.measure(feedDescriptionLabelSize)
        
        
        heartNumberLabelNode?.measure(constrainedSize)
        separator?.measure(constrainedSize)
        
        var resultSize = CGSizeMake(constrainedSize.width, headerHeight + feedDescriptionLabelNode!.calculatedSize.height + locationLabelNode!.calculatedSize.height + footerHeight + CELL_PADDING_BOTTOM)
        

        return resultSize
    }
    
    override func layout(){
        background!.view.addSubview(sendAHeartButton!)
        background!.view.addSubview(shareButton!)
        background?.layer.cornerRadius = 5
        background?.layer.masksToBounds = true
        
        var backgroundXPosition = 0 as CGFloat
        
        if(self.type == PostCellType.Newsfeed){
            self.feedTypeImageNode!.frame = CGRectMake(TYPE_IMAGE_PADDING_LEFT, TYPE_IMAGE_PADDING_TOP, TYPE_IMAGE_WIDTH, TYPE_IMAGE_HEIGHT)
            
            backgroundXPosition = self.feedTypeImageNode!.frame.origin.x + self.feedTypeImageNode!.frame.width + 5
        } else {
            backgroundXPosition = 5
        }
        
        self.background?.frame = CGRectMake(backgroundXPosition, 0, Utilities.getScreenSize().width - backgroundXPosition - 5, self.calculatedSize.height - 10)
        
        self.profilePicture!.frame = CGRectMake(10, 10, PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)
        
        self.userNameLabelNode!.frame = CGRectMake(self.profilePicture!.frame.origin.x + PROFILE_IMAGE_WIDTH + 10, self.profilePicture!.frame.origin.y - 2, userNameLabelNode!.calculatedSize.width, userNameLabelNode!.calculatedSize.height) // 2px is padding of text node
        
        self.userDescLabelNode!.frame = CGRectMake(self.profilePicture!.frame.origin.x + PROFILE_IMAGE_WIDTH + 10, self.userNameLabelNode!.frame.origin.y + self.userNameLabelNode!.calculatedSize.height,userDescLabelNode!.calculatedSize.width, userDescLabelNode!.calculatedSize.height)
        locationLabelNode!.frame = CGRectMake(self.profilePicture!.frame.origin.x + PROFILE_IMAGE_WIDTH + 10, self.userDescLabelNode!.frame.origin.y + userDescLabelNode!.calculatedSize.height + 2, locationLabelNode!.calculatedSize.width, locationLabelNode!.calculatedSize.height)
        
        self.feedDescriptionLabelNode!.frame = CGRectMake(DESCRIPTION_PADDING_LEFT, self.profilePicture!.frame.origin.y + PROFILE_IMAGE_HEIGHT + 25, feedDescriptionLabelNode!.calculatedSize.width, feedDescriptionLabelNode!.calculatedSize.height)
        
        
        
        let heartImageSizeValue = 12 as CGFloat
        self.heartImageView?.frame = CGRectMake(DESCRIPTION_PADDING_LEFT, self.background!.frame.height - heartImageSizeValue - 10, heartImageSizeValue, heartImageSizeValue)
        let sendAHeartButtonSize = CGSizeMake(150, 25)
        
        self.sendAHeartButton?.frame = CGRectMake( DESCRIPTION_PADDING_LEFT, self.background!.frame.height - sendAHeartButtonSize.height, sendAHeartButtonSize.width, sendAHeartButtonSize.height)
        
        self.shareButton?.frame = CGRectMake(self.background!.frame.width - sendAHeartButtonSize.width - 15, self.background!.frame.height - sendAHeartButtonSize.height, sendAHeartButtonSize.width,sendAHeartButtonSize.height)
        
        self.separator?.frame = CGRectMake(0, self.background!.frame.height - 26, self.background!.frame.width, 0.5)
        self.heartNumberLabelNode?.frame = CGRectMake(DESCRIPTION_PADDING_LEFT, self.separator!.frame.origin.y - 18, self.heartNumberLabelNode!.calculatedSize.width, self.heartNumberLabelNode!.calculatedSize.height)
    }
    
    //MARK: Button Action
    func userProfileTapped(sender: AnyObject) {
        let controller = parentViewController.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        controller.profileType = ProfileType.OtherUser
        controller.userProfile = userPost!.user!
        parentViewController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func sendHeartTapped(){
        
        if(!XAppDelegate.socialManager.isLoggedInFacebook()){
            Utilities.showAlertView(self, title: "", message: "Must Login facebook to send heart", tag: 1)
            return
        }
        
        Utilities.showHUD()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendHeartSuccessful:", name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        XAppDelegate.socialManager.sendHeart(userPost!.post_id, type: SEND_HEART_USER_POST_TYPE)
        
    }
    
    func shareTapped(){
        var parentVC = Utilities.getParentUIViewController(self.view) as! UIViewController
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
        var sharingText = String(format: "%@ \n %@", userNameLabelNode!.attributedString.string, feedDescriptionLabelNode!.attributedString.string)
        var pictureURL = ""
        shareVC.populateNewsfeedShareData(ShareViewType.ShareViewTypeHybrid, sharingText: sharingText, pictureURL:pictureURL)
        return shareVC
    }
    
    // Notification handler
    func sendHeartSuccessful(notif: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        Utilities.hideHUD()
        var animation = CATransition()
        animation.duration = 0.5
        animation.type = kCATransitionFade
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        heartNumberLabelNode!.layer.addAnimation(animation, forKey: "changeTextTransition")
//            :animation forKey:"changeTextTransition"];
        userPost!.hearts++
        // Change the text
        dispatch_async(dispatch_get_main_queue(),{
            let dict = [NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
            self.heartNumberLabelNode?.attributedString = NSAttributedString(string:String(format:"%d hearts",self.userPost!.hearts), attributes: dict)
        })
        XAppDelegate.socialManager.sendHeartServerNotification(userPost!.user!.uid, postId: userPost!.post_id)
    }
    
    // MARK: Helpers
    func enableUserProfileInteraction() {
        profilePicture?.userInteractionEnabled = true
        profilePicture?.addTarget(self, action: "userProfileTapped:", forControlEvents: .TouchUpInside)
        userNameLabelNode?.userInteractionEnabled = true
        userNameLabelNode?.addTarget(self, action: "userProfileTapped:", forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
    
    func getFeedTypeText() -> String{
        switch(self.userPost!.type){
        case NewsfeedType.OnYourMind:
            return "shared mind"
        case NewsfeedType.Feeling:
            return "shared feeling"
        case NewsfeedType.Story:
            return "shared a story"
        default:
            break
        }
    }
    
    func getUserDescString() -> String {
        var result = ""
        var signName = getSignName()
        var timePassed = getTimePassedString()
        if(signName != ""){
            result.extend(String(format: "%@ \u{00B7} ", signName))
        }
        if(timePassed != ""){
            result.extend(String(format: "%@", timePassed))
        } else {
            result = result.substringToIndex(advance(result.startIndex, count(result) - 2))
        }
        
        return result
    }
    
    func getTimePassedString() -> String {
        var result = ""
        if let ts = userPost?.ts {
            var timePassSecond = Int(NSDate().timeIntervalSince1970) - userPost!.ts
            // if time passed more than 2 days, show the date
            var dateFormatter = NSDateFormatter()
            var date = NSDate(timeIntervalSince1970: NSTimeInterval(ts))
            if(timePassSecond / (3600 * 24) >= 2){
                dateFormatter.dateFormat = "MMM dd, yyyy hh:mm a"
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                result =  dateFormatter.stringFromDate(date)
            } else if (timePassSecond / (3600 * 24) >= 1){
                dateFormatter.dateFormat = "Yesterday hh:mm a"
                result =  dateFormatter.stringFromDate(date)
            } else {
                var timePassedMinute = timePassSecond/60 as Int
                if(timePassedMinute >= 60){
                    var timePassHour = timePassedMinute / 60 as Int
                    var remainingMinute = timePassedMinute % 60 as Int
                    var hourString = (timePassHour == 1) ? "hour" : "hours"
                    
                    if(remainingMinute != 0){
                        var minuteString = (remainingMinute == 1) ? "minute" : "minutes"
                        result = String(format:"%d %@ %d %@",timePassHour,hourString,remainingMinute,minuteString)
                    } else {
                        result = String(format:"%d %@",timePassHour,hourString)
                    }
                } else if (timePassedMinute >= 1){
                    var minuteString = (timePassedMinute == 1) ? "minute" : "minutes"
                    result = String(format:"%d %@",timePassedMinute,minuteString)
                } else {
                    var secondString = (timePassSecond == 1) ? "second" : "seconds"
                    result = String(format:"%d %@",timePassSecond,secondString)
                }
            }
        }
        
        
        return result
    }
    
    func getSignName() -> String {
        if(userPost?.user?.sign != 0){
            return Utilities.getHoroscopeNameWithIndex(userPost!.user!.sign)
        }
        return ""
    }
    
    func getLocation()-> String{
        return userPost!.user!.location
    }
    
}