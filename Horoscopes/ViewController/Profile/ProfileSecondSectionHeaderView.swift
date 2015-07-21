//
//  ProfileSecondSectionHeaderView.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileSecondSectionHeaderView: UIView {
    
    var postButton: UIButton!
    var followingButton: UIButton!
    var followersButton: UIButton!
    let buttonHeight: CGFloat = 44
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        postButton = UIButton()
        postButton.frame = CGRectMake(0, 0, bounds.size.width / 3, buttonHeight)
        postButton.setTitle("Post\n0", forState: UIControlState.Normal)
        postButton.titleLabel?.textAlignment = NSTextAlignment.Center
        postButton.titleLabel?.numberOfLines = 2
        addSubview(postButton)
        
        followersButton = UIButton()
        followersButton.frame = CGRectMake(bounds.size.width / 3, 0, bounds.size.width / 3, buttonHeight)
        followersButton.titleLabel?.numberOfLines = 2
        followersButton.titleLabel?.textAlignment = NSTextAlignment.Center
        addSubview(followersButton)
        
        followingButton = UIButton()
        followingButton.frame = CGRectMake(bounds.size.width / 3 * 2, 0, bounds.size.width / 3, buttonHeight)
        followingButton.titleLabel?.numberOfLines = 2
        followingButton.titleLabel?.textAlignment = NSTextAlignment.Center
        addSubview(followingButton)
        
        postButton.backgroundColor = UIColor.redColor()
        followersButton.backgroundColor = UIColor.greenColor()
        followingButton.backgroundColor = UIColor.blueColor()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
