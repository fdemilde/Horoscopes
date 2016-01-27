//
//  CommunityWelcomeView.swift
//  Horoscopes
//
//  Created by Binh Dang on 1/25/16.
//  Copyright © 2016 Binh Dang. All rights reserved.
//

import Foundation

class CommunityWelcomeView : UIView {
    let POST_BUTTON_SIZE = CGSizeMake(54,49)
    let ARROW_SIZE = CGSizeMake(21,32)
    let ICON_SIZE = CGSizeMake(26,26)
    let TEXT_PADDING = 30 as CGFloat
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupOverlay()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupOverlay(){
        // setup overlay
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.9)
        
        let overlayTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "overlayTapGestureRecognizer:")
        self.addGestureRecognizer(overlayTapGestureRecognizer)
        
        
        // add post button
        let postButtonFrame = CGRectMake((self.frame.width - POST_BUTTON_SIZE.width)/2, (self.frame.height - POST_BUTTON_SIZE.height), POST_BUTTON_SIZE.width, POST_BUTTON_SIZE.height)
        let postButton = UIButton(frame: postButtonFrame)
        postButton.setImage(UIImage(named: "tabbar_create_post"), forState: UIControlState.Normal)
        postButton.addTarget(self, action: "postButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(postButton)
        
        // add post arrow
        let arrowImage = UIImage(named: "community_post_arrow")
        let arrowFrame = CGRectMake(postButton.frame.origin.x - ARROW_SIZE.width, postButton.frame.origin.y + 13 - ARROW_SIZE.height, ARROW_SIZE.width, ARROW_SIZE.height)
        let arrowImageView = UIImageView(frame: arrowFrame)
        arrowImageView.image = arrowImage
        self.addSubview(arrowImageView)
        
        // add get started label
        let getStartedLabel = UILabel()
        getStartedLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        getStartedLabel.text = "Tap the pencil to get started"
        getStartedLabel.sizeToFit()
        getStartedLabel.textColor = UIColor.whiteColor()
        getStartedLabel.textAlignment = NSTextAlignment.Center
        let getStartedLabelFrame = CGRectMake(0, arrowImageView.frame.origin.y - getStartedLabel.frame.size.height, self.frame.size.width, getStartedLabel.frame.size.height)
        getStartedLabel.frame = getStartedLabelFrame
        self.addSubview(getStartedLabel)
        
        // add explain label
        let explainLabel = UILabel()
        explainLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        explainLabel.text = "You can now exchange your thoughts and bits of daily advice with other members of the Horoscopes community"
        explainLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        explainLabel.numberOfLines = 0
        explainLabel.textColor = UIColor.whiteColor()
        explainLabel.textAlignment = NSTextAlignment.Center
        explainLabel.sizeToFit()
        let explainLabelFrame = CGRectMake(TEXT_PADDING, getStartedLabel.frame.origin.y - 150 - explainLabel.frame.size.height, self.frame.size.width - TEXT_PADDING * 2, 100)
        explainLabel.frame = explainLabelFrame
        self.addSubview(explainLabel)
        
        // add community icon
        let communityIcon = UIImage(named: "community_btn_icon")
        let communityIconFrame = CGRectMake((self.frame.size.width - ICON_SIZE.width)/2, explainLabel.frame.origin.y - 13 - ICON_SIZE.height, ICON_SIZE.width, ICON_SIZE.height)
        let communityIconView = UIImageView(frame: communityIconFrame)
        communityIconView.image = communityIcon
        self.addSubview(communityIconView)
        
        // add welcome label
        let welcomeLabel = UILabel()
        welcomeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
        welcomeLabel.text = "Welcome to the Family"
        welcomeLabel.sizeToFit()
        welcomeLabel.textColor = UIColor.whiteColor()
        welcomeLabel.textAlignment = NSTextAlignment.Center
        let welcomeLabelFrame = CGRectMake(0, communityIconView.frame.origin.y - 20 - welcomeLabel.frame.size.height, self.frame.size.width, welcomeLabel.frame.size.height)
        welcomeLabel.frame = welcomeLabelFrame
        self.addSubview(welcomeLabel)
    }
    
    func overlayTapGestureRecognizer(recognizer: UITapGestureRecognizer){
        self.removeFromSuperview()
    }
    
    func postButtonTapped(){
        if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
            let rootVC = XAppDelegate.window!.rootViewController! as? CustomTabBarController
            rootVC?.postButtonTapped()
        }
        self.removeFromSuperview()
    }
}