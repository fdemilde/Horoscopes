//
//  ProfileSecondSectionHeaderView.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

protocol ProfileSecondSectionHeaderViewDelegate {
    func didTapPostButton()
    func didTapFollowersButton()
    func didTapFollowingButton()
}

class ProfileSecondSectionHeaderView: UIView {
    
    var userProfile: UserProfile!
    var postButton: UIButton!
    var followingButton: UIButton!
    var followersButton: UIButton!
    var followButton: UIButton?
    var signInImageView: UIImageView!
    var nameLabel: UILabel!
    var horoscopeSignLabel: UILabel!
    var addButton: UIButton!
    var settingsButton: UIButton!
    let buttonHeight: CGFloat = 44
    let padding: CGFloat = 3
    let pictureSize: CGFloat = 30
    let buttonOriginY: CGFloat = 36
    var delegate: ProfileSecondSectionHeaderViewDelegate?
    var followDelegate: ProfileFollowCellNodeDelegate?
    var parentViewController: ProfileViewController!
    let postButtonTitleLabel = "Post"
    let followersButtonTitleLabel = "Followers"
    let followingButtonTitleLabel = "Following"
    
    init(frame: CGRect, userProfile: UserProfile, parentViewController: ProfileViewController) {
        super.init(frame: frame)
        self.userProfile = userProfile
        self.parentViewController = parentViewController
        
        postButton = UIButton()
        postButton.frame = CGRectMake(0, buttonOriginY, bounds.size.width / 3, buttonHeight)
        postButton.addTarget(self, action: "postButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(postButton)
        
        followersButton = UIButton()
        followersButton.frame = CGRectMake(bounds.size.width / 3, buttonOriginY, bounds.size.width / 3, buttonHeight)
        followersButton.addTarget(self, action: "followersButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(followersButton)
        
        followingButton = UIButton()
        followingButton.frame = CGRectMake(bounds.size.width / 3 * 2, buttonOriginY, bounds.size.width / 3, buttonHeight)
        followingButton.addTarget(self, action: "followingButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(followingButton)
        
        configureButtonTitleLabel()
        
        if parentViewController.profileType == ProfileType.CurrentUser {
            signInImageView = UIImageView()
            signInImageView.layer.cornerRadius = self.pictureSize / 2
            signInImageView.clipsToBounds = true
            signInImageView.backgroundColor = UIColor.profileImagePurpleColor()
            let url = NSURL(string: userProfile.imgURL)
            let request = NSURLRequest(URL: url!)
            let session = NSURLSession.sharedSession()
            let task = session.downloadTaskWithRequest(request, completionHandler: { (location, response, error) -> Void in
                if let error = error {
                    
                } else {
                    let image = UIImage(data: NSData(contentsOfURL: location)!)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.signInImageView.image = image
                        self.signInImageView.sizeToFit()
                    })
                }
            })
            task.resume()
            signInImageView.frame = CGRectMake(15, padding, pictureSize, pictureSize)
            addSubview(signInImageView)
            
            nameLabel = UILabel()
            nameLabel.text = userProfile.name
            nameLabel.font = UIFont.systemFontOfSize(13)
            nameLabel.sizeToFit()
            nameLabel.textColor = UIColor.whiteColor()
            nameLabel.frame = CGRectMake(22 + pictureSize + padding, padding, nameLabel.bounds.width, nameLabel.bounds.height)
            addSubview(nameLabel)
            
            horoscopeSignLabel = UILabel()
            horoscopeSignLabel.text = HoroscopesManager.sharedInstance.getHoroscopesSigns()[userProfile.sign].sign
            horoscopeSignLabel.font = UIFont.systemFontOfSize(11)
            horoscopeSignLabel.sizeToFit()
            horoscopeSignLabel.textColor = UIColor(red: 190/255.0, green: 196/255.0, blue: 239/255.0, alpha: 1)
            horoscopeSignLabel.frame = CGRectMake(22 + pictureSize + padding, padding + nameLabel.bounds.height, horoscopeSignLabel.bounds.width, horoscopeSignLabel.bounds.height)
            addSubview(horoscopeSignLabel)
            
            settingsButton = UIButton()
            settingsButton.setImage(UIImage(named: "settings_btn_small"), forState: UIControlState.Normal)
            settingsButton.addTarget(self, action: "settingsButtonTapped", forControlEvents: .TouchUpInside)
            settingsButton.sizeToFit()
            settingsButton.frame = CGRectMake(bounds.width - settingsButton.bounds.width - padding, padding, settingsButton.bounds.width, settingsButton.bounds.height)
            addSubview(settingsButton)
            
            addButton = UIButton()
            addButton.setImage(UIImage(named: "add_btn_small"), forState: UIControlState.Normal)
            addButton.sizeToFit()
            addButton.frame = CGRectMake(bounds.width - addButton.bounds.width - settingsButton.bounds.width - padding*2, padding, addButton.bounds.width, addButton.bounds.height)
            addSubview(addButton)
            
            hide()
        } else {
            followButton = UIButton()
            followButton?.setImage(UIImage(named: "friend_follow"), forState: .Normal)
            followButton?.sizeToFit()
            followButton?.frame = CGRectMake(frame.width/2 - followButton!.frame.width/2, buttonOriginY/2 - followButton!.frame.height/2, followButton!.frame.width, followButton!.frame.height)
            followButton!.addTarget(self, action: "followButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            addSubview(followButton!)
        }
    }
    
    func configureButton(button: UIButton) {
        button.titleLabel?.font = UIFont.systemFontOfSize(13)
        button.titleLabel?.textAlignment = NSTextAlignment.Center
        button.titleLabel?.numberOfLines = 2
        addSubview(button)
    }
    
    func configureButtonTitleLabel() {
        switch parentViewController.currentTab {
        case .Post:
            reloadButtonTitleLabel(postButton)
        case .Followers:
            reloadButtonTitleLabel(followersButton)
        case .Following:
            reloadButtonTitleLabel(followingButton)
        }
    }
    
    func reloadButtonTitleLabel(highlightedButton: UIButton) {
        let buttons = [postButton, followersButton, followingButton]
        for button in buttons {
            var string = NSMutableAttributedString()
            var title: String
            var number: Int
            switch button {
            case postButton:
                title = postButtonTitleLabel
                number = parentViewController.userPosts.count
            case followersButton:
                title = followersButtonTitleLabel
                number = parentViewController.followers.count
            case followingButton:
                title = followingButtonTitleLabel
                number = parentViewController.followingUsers.count
            default:
                title = ""
                number = 0
            }
            let fullTitle = "\(title)\n\(number)"
            string.appendAttributedString(NSAttributedString(string: fullTitle))
            if button == highlightedButton {
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(title)))
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 190/255.0, green: 196/255.0, blue: 239/255.0, alpha: 1), range: NSMakeRange(count(title), count(fullTitle) - count(title)))
            } else {
                string.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 68/255.0, green: 66/255.0, blue: 96/255.0, alpha: 1), range: NSMakeRange(0, count(fullTitle)))
            }
            button.setAttributedTitle(string, forState: UIControlState.Normal)
        }
    }
    
    func hide() {
        signInImageView.hidden = true
        nameLabel.hidden = true
        horoscopeSignLabel.hidden = true
        addButton.enabled = false
        addButton.hidden = true
        settingsButton.enabled = false
        settingsButton.hidden = true
    }
    
    func show() {
        signInImageView.hidden = false
        nameLabel.hidden = false
        horoscopeSignLabel.hidden = false
        addButton.enabled = true
        addButton.hidden = false
        settingsButton.enabled = true
        settingsButton.hidden = false
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func postButtonTapped(sender: UIButton) {
        delegate?.didTapPostButton()
    }
    
    func followersButtonTapped(sender: UIButton) {
        delegate?.didTapFollowersButton()
    }
    
    func followingButtonTapped(sender: UIButton) {
        delegate?.didTapFollowingButton()
    }
    
    func followButtonTapped(sender: AnyObject) {
        followDelegate!.didClickFollowButton(userProfile.uid)
    }
    
    func settingsButtonTapped(){
        let settingViewController = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        var formSheet = MZFormSheetController(viewController: settingViewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom;
        formSheet.cornerRadius = 0.0;
        formSheet.portraitTopInset = 0.0;
        formSheet.presentedFormSheetSize = CGSizeMake(self.window!.frame.size.width, self.window!.frame.size.height);
        let tabBarVC = self.window?.rootViewController as! UITabBarController
        parentViewController?.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
