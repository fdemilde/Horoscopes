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
    let buttonHeight: CGFloat = 44
    var buttonDelegate: ButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        postButton = UIButton()
        postButton.frame = CGRectMake(0, 36, bounds.size.width / 3, buttonHeight)
        postButton.addTarget(self, action: "postButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(postButton)
//        postButton.backgroundColor = UIColor.redColor()
//        backgroundColor = UIColor.blueColor()
        
        followersButton = UIButton()
        followersButton.frame = CGRectMake(bounds.size.width / 3, 36, bounds.size.width / 3, buttonHeight)
        followersButton.addTarget(self, action: "followersButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(followersButton)
        
        followingButton = UIButton()
        followingButton.frame = CGRectMake(bounds.size.width / 3 * 2, 36, bounds.size.width / 3, buttonHeight)
        followingButton.addTarget(self, action: "followingButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        configureButton(followingButton)    }
    
    func configureButton(button: UIButton) {
        button.titleLabel?.font = UIFont.systemFontOfSize(13)
        button.titleLabel?.textAlignment = NSTextAlignment.Center
        button.titleLabel?.numberOfLines = 2
        addSubview(button)
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
