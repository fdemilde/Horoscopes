//
//  NewsfeedCellNode.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/1/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class NewsfeedCellNode : ASCellNode {
    
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
    var timePassedLabelNode : ASTextNode?
    var feedDescriptionLabelNode : ASTextNode?
    var heartNumberLabelNode : ASTextNode?
    var separator : ASDisplayNode?
    var heartImageView : ASImageNode?
    var sendAHeartButton : UIButton?
    var shareImageView : ASImageNode?
    var shareButton : UIButton?
    
    var userPost : UserPost?
    
    init(post : UserPost){
        super.init()
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.userPost = post
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
        feedTypeImageNode?.image = UIImage(named: (self.getFeedTypeImageName()))
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
        profilePicture?.URL = NSURL(string: userPost!.user!.imgURL)
        background!.addSubnode(profilePicture)
//        userPost!.user!.name
        userNameLabelNode = ASTextNode()
        var nameWithPostTypeString = String(format : "%@ %@","ha hi haosh dhaisdh asdhia hasd" , self.getFeedTypeText())
        var attString = NSMutableAttributedString(string: nameWithPostTypeString)
        var nameStringLength = count("ha hi haosh dhaisdh asdhia hasd")
        var nameWithPostTypeStringLength = count(nameWithPostTypeString)
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, nameStringLength))
//        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(11.0), range: NSMakeRange(nameStringLength, nameWithPostTypeStringLength-1))
        
        userNameLabelNode?.attributedString = attString
        background!.addSubnode(userNameLabelNode)
        
        timePassedLabelNode = ASTextNode()
        let timeDict = [NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
        timePassedLabelNode?.attributedString = NSAttributedString(string: self.getTimePassedString(), attributes: timeDict)
        background!.addSubnode(timePassedLabelNode)
        
    }
    
    func createFeedDescirption(){
        feedDescriptionLabelNode = ASTextNode()
        let dict = [NSForegroundColorAttributeName: UIColor.blackColor(), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
        // data : userPost!.message
        feedDescriptionLabelNode?.attributedString = NSAttributedString(string: "co ho Hieu hom nay se bi co dau bep chui xoi xa vao mom, khong duoc an com. Co ho Tuan bi dau bung vi an nhieu qua, cuoi ngay con bi tieu chay", attributes: dict)
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
        timePassedLabelNode?.measure(constrainedSize)
        
        feedDescriptionLabelNode?.measure(feedDescriptionLabelSize)
        
        heartNumberLabelNode?.measure(constrainedSize)
        separator?.measure(constrainedSize)
        
        var resultSize = CGSizeMake(constrainedSize.width, headerHeight + feedDescriptionLabelNode!.calculatedSize.height + footerHeight + CELL_PADDING_BOTTOM)
        

        return resultSize
    }
    
    override func layout(){
        background!.view.addSubview(sendAHeartButton!)
        background!.view.addSubview(shareButton!)
        background?.layer.cornerRadius = 5
        background?.layer.masksToBounds = true
        self.feedTypeImageNode!.frame = CGRectMake(TYPE_IMAGE_PADDING_LEFT, TYPE_IMAGE_PADDING_TOP, TYPE_IMAGE_WIDTH, TYPE_IMAGE_HEIGHT)
        
        var backgroundXPosition = self.feedTypeImageNode!.frame.origin.x + self.feedTypeImageNode!.frame.width + 5
        self.background?.frame = CGRectMake(backgroundXPosition, 0, Utilities.getScreenSize().width - backgroundXPosition - 5, self.calculatedSize.height - 10)
        
        self.profilePicture!.frame = CGRectMake(10, 10, PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)
        
        self.userNameLabelNode!.frame = CGRectMake(self.profilePicture!.frame.origin.x + PROFILE_IMAGE_WIDTH + 10, 12, userNameLabelNode!.calculatedSize.width, userNameLabelNode!.calculatedSize.height)
        
        self.timePassedLabelNode!.frame = CGRectMake(self.profilePicture!.frame.origin.x + PROFILE_IMAGE_WIDTH + 10, self.userNameLabelNode!.frame.origin.y + self.userNameLabelNode!.calculatedSize.height,timePassedLabelNode!.calculatedSize.width, timePassedLabelNode!.calculatedSize.height)
        
        self.feedDescriptionLabelNode!.frame = CGRectMake(DESCRIPTION_PADDING_LEFT, self.profilePicture!.frame.origin.y + PROFILE_IMAGE_HEIGHT + 20, feedDescriptionLabelNode!.calculatedSize.width, feedDescriptionLabelNode!.calculatedSize.height)
        
        let heartImageSizeValue = 12 as CGFloat
        self.heartImageView?.frame = CGRectMake(DESCRIPTION_PADDING_LEFT, self.background!.frame.height - heartImageSizeValue - 10, heartImageSizeValue, heartImageSizeValue)
        let sendAHeartButtonSize = CGSizeMake(150, 25)
        
        self.sendAHeartButton?.frame = CGRectMake( DESCRIPTION_PADDING_LEFT, self.background!.frame.height - sendAHeartButtonSize.height, sendAHeartButtonSize.width, sendAHeartButtonSize.height)
        
        self.shareButton?.frame = CGRectMake(self.background!.frame.width - sendAHeartButtonSize.width - 15, self.background!.frame.height - sendAHeartButtonSize.height, sendAHeartButtonSize.width,sendAHeartButtonSize.height)
        
        self.separator?.frame = CGRectMake(0, self.background!.frame.height - 26, self.background!.frame.width, 0.5)
        self.heartNumberLabelNode?.frame = CGRectMake(DESCRIPTION_PADDING_LEFT, self.separator!.frame.origin.y - 18, self.heartNumberLabelNode!.calculatedSize.width, self.heartNumberLabelNode!.calculatedSize.height)
    }
    
    //MARK: Button Action
    func sendHeartTapped(){
        println("sendHeartTapped sendHeartTapped")
    }
    
    func shareTapped(){
        println("shareTapped shareTapped")
    }
    
    // MARK: Helpers
    
    func getFeedTypeImageName() -> String{
        switch(self.userPost!.type){
        case NewsfeedType.OnYourMind:
            return "post_type_mind"
        case NewsfeedType.Feeling:
            return "post_type_feel"
        case NewsfeedType.Story:
            return "post_type_story"
        default:
            break
        }
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
    
    func getTimePassedString() -> String {
        var timePassSecond = Int(NSDate().timeIntervalSince1970) - userPost!.ts
        return String(format: "%d mins ago", timePassSecond/60)
    }
}