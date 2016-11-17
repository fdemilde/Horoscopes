//
//  CommunityWelcomeView.swift
//  Horoscopes
//
//  Created by Binh Dang on 1/25/16.
//  Copyright © 2016 Binh Dang. All rights reserved.
//

import Foundation

class CommunityWelcomeView : UIView {
    let POST_BUTTON_SIZE = CGSize(width: 54,height: 49)
    let ARROW_SIZE = CGSize(width: 21,height: 32)
    let ICON_SIZE = CGSize(width: 26,height: 26)
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
        
        let overlayTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommunityWelcomeView.overlayTapGestureRecognizer(_:)))
        self.addGestureRecognizer(overlayTapGestureRecognizer)
        
        
        // add post button
        let postButtonFrame = CGRect(x: (self.frame.width - POST_BUTTON_SIZE.width)/2, y: (self.frame.height - POST_BUTTON_SIZE.height), width: POST_BUTTON_SIZE.width, height: POST_BUTTON_SIZE.height)
        let postButton = UIButton(frame: postButtonFrame)
        postButton.setImage(UIImage(named: "tabbar_create_post"), for: UIControlState())
        postButton.addTarget(self, action: #selector(CommunityWelcomeView.postButtonTapped), for: UIControlEvents.touchUpInside)
        self.addSubview(postButton)
        
        // add post arrow
        let arrowImage = UIImage(named: "community_post_arrow")
        let arrowFrame = CGRect(x: postButton.frame.origin.x - ARROW_SIZE.width, y: postButton.frame.origin.y + 13 - ARROW_SIZE.height, width: ARROW_SIZE.width, height: ARROW_SIZE.height)
        let arrowImageView = UIImageView(frame: arrowFrame)
        arrowImageView.image = arrowImage
        self.addSubview(arrowImageView)
        
        // add get started label
        let getStartedLabel = UILabel()
        getStartedLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        getStartedLabel.text = "Tap the pencil to get started"
        getStartedLabel.sizeToFit()
        getStartedLabel.textColor = UIColor.white
        getStartedLabel.textAlignment = NSTextAlignment.center
        let getStartedLabelFrame = CGRect(x: 0, y: arrowImageView.frame.origin.y - getStartedLabel.frame.size.height, width: self.frame.size.width, height: getStartedLabel.frame.size.height)
        getStartedLabel.frame = getStartedLabelFrame
        self.addSubview(getStartedLabel)
        
        // add explain label
        let explainLabel = UILabel()
        explainLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
        explainLabel.text = "You can now exchange your thoughts and bits of daily advice with other members of the Horoscopes community"
        explainLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        explainLabel.numberOfLines = 0
        explainLabel.textColor = UIColor.white
        explainLabel.textAlignment = NSTextAlignment.center
        explainLabel.sizeToFit()
        let explainLabelFrame = CGRect(x: TEXT_PADDING, y: getStartedLabel.frame.origin.y - 150 - explainLabel.frame.size.height, width: self.frame.size.width - TEXT_PADDING * 2, height: 100)
        explainLabel.frame = explainLabelFrame
        self.addSubview(explainLabel)
        
        // add community icon
        let communityIcon = UIImage(named: "community_btn_icon")
        let communityIconFrame = CGRect(x: (self.frame.size.width - ICON_SIZE.width)/2, y: explainLabel.frame.origin.y - 13 - ICON_SIZE.height, width: ICON_SIZE.width, height: ICON_SIZE.height)
        let communityIconView = UIImageView(frame: communityIconFrame)
        communityIconView.image = communityIcon
        self.addSubview(communityIconView)
        
        // add welcome label
        let welcomeLabel = UILabel()
        welcomeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24)
        welcomeLabel.text = "Welcome to the Family"
        welcomeLabel.sizeToFit()
        welcomeLabel.textColor = UIColor.white
        welcomeLabel.textAlignment = NSTextAlignment.center
        let welcomeLabelFrame = CGRect(x: 0, y: communityIconView.frame.origin.y - 20 - welcomeLabel.frame.size.height, width: self.frame.size.width, height: welcomeLabel.frame.size.height)
        welcomeLabel.frame = welcomeLabelFrame
        self.addSubview(welcomeLabel)
    }
    
    func overlayTapGestureRecognizer(_ recognizer: UITapGestureRecognizer){
        self.removeFromSuperview()
    }
    
    func postButtonTapped(){
        if(XAppDelegate.window!.rootViewController!.isKind(of: UITabBarController.self)){
            let rootVC = XAppDelegate.window!.rootViewController! as? CustomTabBarController
            rootVC?.postButtonTapped()
        }
        self.removeFromSuperview()
    }
}
