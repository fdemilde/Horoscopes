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
    
    init(frame: CGRect, userProfile: UserProfile) {
        super.init(frame: frame)
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
        
        signInImageView = UIImageView()
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
                    self.signInImageView.layer.cornerRadius = self.pictureSize / 2
                    self.signInImageView.clipsToBounds = true
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
