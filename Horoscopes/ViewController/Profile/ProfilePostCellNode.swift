//
//  ProfilePostCellNode.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class ProfilePostCellNode: ASCellNode {
    // MARK: Properties
    let tablePadding: CGFloat = 5
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
    
    
    var background : ASDisplayNode?
    var profilePicture : ASNetworkImageNode?
    var userNameLabelNode : ASTextNode?
    var timePassedLabelNode : ASTextNode?
    var feedDescriptionLabelNode : ASTextNode?
    var heartNumberLabelNode : ASTextNode?
    var separator : ASDisplayNode?
    var heartImageView : ASImageNode?
    var shareImageView : ASImageNode?
    var shareButton : UIButton?
    let imageColor = UIColor(red: 185, green: 191, blue: 234, alpha: 1)
    
    var userPost : UserPost?
    
    var followDelegate: FollowDelegate?
    
    // MARK: Initialization
    
    func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }
    
    init(userPost: UserPost) {
        super.init()
        self.userPost = userPost
        setup()
        createBackground()
        createFeedHeader()
        createFeedDescirption()
        createFeedHeartTextNode()
        createSeparator()
        createButtons()
    }
    
    // MARK: create components
    
    func createBackground(){
        background = ASDisplayNode()
        background?.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 242.0/255.0, alpha: 1)
        self.addSubnode(background);
    }
    
    func createFeedHeader(){
        // header includes profile image, user name, user share text and time passed
        profilePicture = ASNetworkImageNode(webImage: ())
        profilePicture?.cornerRadius = PROFILE_IMAGE_WIDTH / 2
        profilePicture?.clipsToBounds = true
        profilePicture?.backgroundColor = UIColor.profileImagePurpleColor()
        profilePicture?.URL = NSURL(string: userPost!.user!.imgURL)
        background!.addSubnode(profilePicture)
        //        userPost!.user!.name
        userNameLabelNode = ASTextNode()
        var nameWithPostTypeString = String(format : "%@",userPost!.user!.name)
        var attString = NSMutableAttributedString(string: nameWithPostTypeString)
        var nameStringLength = count(userPost!.user!.name)
        var nameWithPostTypeStringLength = count(nameWithPostTypeString)
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, nameStringLength))
        //        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(11.0), range: NSMakeRange(nameStringLength, nameWithPostTypeStringLength-1))
        
        userNameLabelNode?.attributedString = attString
        background!.addSubnode(userNameLabelNode)
        
        timePassedLabelNode = ASTextNode()
        let timeDict = [NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
        timePassedLabelNode?.attributedString = NSAttributedString(string: getTimeAgo(), attributes: timeDict)
        background!.addSubnode(timePassedLabelNode)
        
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
        let userNameLabelNodeLabelSize = userNameLabelNode?.measure(CGSizeMake(constrainedSize.width - BG_PADDING_LEFT - BG_PADDING_RIGHT - DESCRIPTION_PADDING_LEFT * 2 - PROFILE_IMAGE_WIDTH - TYPE_IMAGE_PADDING_LEFT * 2, constrainedSize.height / 2))
        var headerHeight = BG_TOP_HEIGHT;
        var footerHeight = BG_BOTTOM_HEIGHT;
        /// calculate the text in middle + padding
        
        var feedDescriptionLabelSize = CGSizeMake(constrainedSize.width - BG_PADDING_LEFT - BG_PADDING_RIGHT - DESCRIPTION_PADDING_LEFT * 2 , CGFloat(FLT_MAX))
        
        timePassedLabelNode?.measure(constrainedSize)
        
        feedDescriptionLabelNode?.measure(feedDescriptionLabelSize)
        
        heartNumberLabelNode?.measure(constrainedSize)
        separator?.measure(constrainedSize)
        
        var resultSize = CGSizeMake(constrainedSize.width, headerHeight + feedDescriptionLabelNode!.calculatedSize.height + footerHeight + CELL_PADDING_BOTTOM)
        background?.measure(constrainedSize)
        
        return resultSize
    }
    
    override func layout(){
        self.profilePicture!.frame = CGRectMake(10, 10, PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_HEIGHT)
        self.userNameLabelNode!.frame = CGRectMake(self.profilePicture!.frame.origin.x + PROFILE_IMAGE_WIDTH + 10, 12, userNameLabelNode!.calculatedSize.width, userNameLabelNode!.calculatedSize.height)
        background!.view.addSubview(shareButton!)
        background?.layer.cornerRadius = 5
        background?.layer.masksToBounds = true
        
        self.background?.frame = CGRectMake(tablePadding, 0, calculatedSize.width - tablePadding*2, self.calculatedSize.height - 10)
        
        self.timePassedLabelNode!.frame = CGRectMake(self.profilePicture!.frame.origin.x + PROFILE_IMAGE_WIDTH + 10, self.userNameLabelNode!.frame.origin.y + self.userNameLabelNode!.calculatedSize.height,timePassedLabelNode!.calculatedSize.width, timePassedLabelNode!.calculatedSize.height)
        
        self.feedDescriptionLabelNode!.frame = CGRectMake(DESCRIPTION_PADDING_LEFT, self.profilePicture!.frame.origin.y + PROFILE_IMAGE_HEIGHT + 20, feedDescriptionLabelNode!.calculatedSize.width, feedDescriptionLabelNode!.calculatedSize.height)
        
        let heartImageSizeValue = 12 as CGFloat
        let sendAHeartButtonSize = CGSizeMake(150, 25)
        
        self.shareButton?.frame = CGRectMake(self.background!.frame.width - sendAHeartButtonSize.width - 15, self.background!.frame.height - sendAHeartButtonSize.height, sendAHeartButtonSize.width,sendAHeartButtonSize.height)
        
        self.separator?.frame = CGRectMake(0, self.background!.frame.height - 26, self.background!.frame.width, 0.5)
        self.heartNumberLabelNode?.frame = CGRectMake(DESCRIPTION_PADDING_LEFT, self.separator!.frame.origin.y - 18, self.heartNumberLabelNode!.calculatedSize.width, self.heartNumberLabelNode!.calculatedSize.height)
    }
    
    //MARK: Button Action
    
    func shareTapped(){
        println("shareTapped shareTapped")
    }
    
    
    
    // MARK: Helpers
    
    func getTimeAgo() -> String {
        let timeAgoDate = NSDate(timeIntervalSince1970: NSTimeInterval(userPost!.ts))
        return timeAgoDate.timeAgoSinceNow()
    }
}