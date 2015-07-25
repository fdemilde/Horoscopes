//
//  ProfileSecondSectionHeaderView.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

protocol ButtonDelegate {
    func didTapPostButton(sender: UIButton)
    func didTapFollowersButton(sender: UIButton)
    func didTapFollowingButton(sender: UIButton)
}

class ProfileSecondSectionHeaderView: UIView {
    
    var postButton: UIButton!
    var followingButton: UIButton!
    var followersButton: UIButton!
    var signInImageView: UIImageView!
    var nameLabel: UILabel!
    var horoscopeSignLabel: UILabel!
    var addButton: UIButton!
    var settingsButton: UIButton!
    let buttonHeight: CGFloat = 44
    let padding: CGFloat = 3
    let pictureSize: CGFloat = 30
    var buttonDelegate: ButtonDelegate?
    var parentViewController: ProfileViewController!
    let postButtonTitleLabel = "Post"
    let followersButtonTitleLabel = "Followers"
    let followingButtonTitleLabel = "Following"
    
    init(frame: CGRect, userProfile: UserProfile, parentViewController: ProfileViewController) {
        super.init(frame: frame)
        self.parentViewController = parentViewController
        
        postButton = UIButton()
        postButton.frame = CGRectMake(0, 36, bounds.size.width / 3, buttonHeight)
        postButton.addTarget(self, action: "postButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(postButton)
        
        followersButton = UIButton()
        followersButton.frame = CGRectMake(bounds.size.width / 3, 36, bounds.size.width / 3, buttonHeight)
        followersButton.addTarget(self, action: "followersButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(followersButton)
        
        followingButton = UIButton()
        followingButton.frame = CGRectMake(bounds.size.width / 3 * 2, 36, bounds.size.width / 3, buttonHeight)
        followingButton.addTarget(self, action: "followingButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(followingButton)
        
        configureButtonTitleLabel()
        
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
        addSubview(signInImageView)
        
        nameLabel = UILabel()
        nameLabel.text = userProfile.name
        nameLabel.font = UIFont.systemFontOfSize(13)
        nameLabel.sizeToFit()
        nameLabel.textColor = UIColor.whiteColor()
        addSubview(nameLabel)
        
        horoscopeSignLabel = UILabel()
        horoscopeSignLabel.text = HoroscopesManager.sharedInstance.getHoroscopesSigns()[userProfile.sign].sign
        horoscopeSignLabel.font = UIFont.systemFontOfSize(11)
        horoscopeSignLabel.sizeToFit()
        horoscopeSignLabel.textColor = UIColor(red: 190/255.0, green: 196/255.0, blue: 239/255.0, alpha: 1)
        addSubview(horoscopeSignLabel)
        
        addButton = UIButton()
        addButton.setImage(UIImage(named: "add_btn_small"), forState: UIControlState.Normal)
        addButton.sizeToFit()
        addSubview(addButton)
        
        settingsButton = UIButton()
        settingsButton.setImage(UIImage(named: "settings_btn_small"), forState: UIControlState.Normal)
        settingsButton.sizeToFit()
        addSubview(settingsButton)
        
        hide()
    }
    
    override func layoutSubviews() {
        signInImageView.frame = CGRectMake(15, padding, pictureSize, pictureSize)
        nameLabel.frame = CGRectMake(22 + pictureSize + padding, padding, nameLabel.bounds.width, nameLabel.bounds.height)
        horoscopeSignLabel.frame = CGRectMake(22 + pictureSize + padding, padding + nameLabel.bounds.height, horoscopeSignLabel.bounds.width, horoscopeSignLabel.bounds.height)
        addButton.frame = CGRectMake(bounds.width - addButton.bounds.width - settingsButton.bounds.width - padding*2, padding, addButton.bounds.width, addButton.bounds.height)
        settingsButton.frame = CGRectMake(bounds.width - settingsButton.bounds.width - padding, padding, settingsButton.bounds.width, settingsButton.bounds.height)
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
        buttonDelegate?.didTapPostButton(postButton)
    }
    
    func followersButtonTapped(sender: UIButton) {
        buttonDelegate?.didTapFollowersButton(followersButton)
    }
    
    func followingButtonTapped(sender: UIButton) {
        buttonDelegate?.didTapFollowingButton(followingButton)
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
