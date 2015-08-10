//
//  ProfileFollowCellNode.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/21/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

protocol ProfileFollowCellNodeDelegate {
    func didClickFollowButton(uid: Int)
}

class ProfileFollowCellNode: ASCellNode {
    var backgroundDisplayNode: ASDisplayNode!
    var pictureImageNode: ASNetworkImageNode!
    var nameTextNode: ASTextNode!
    var horoscopeSignTextNode: ASTextNode!
    var followButton: UIButton!
    var followedLabel: UILabel!
    
    var user: UserProfile!
//    var isFollowed: Bool!
    var followerTab = false
    var delegate: ProfileFollowCellNodeDelegate?
    var parentViewController: ProfileViewController!
    
    let tablePadding: CGFloat = 5
    let outterPadding: CGFloat = 15
    let innerPadding: CGFloat = 2
    let pictureSize: CGFloat = 30
    
    // MARK: - Initialization
    required init(user: UserProfile, parentViewController: ProfileViewController) {
        super.init()
        self.user = user
        self.selectionStyle = .None
        self.parentViewController = parentViewController
        configureUI()
        if parentViewController.profileType == ProfileType.CurrentUser {
            followerTab = true
            configureFollowerUI()
        }
    }
    
    // MARK: - UI Configuration
    func configureUI() {
        backgroundDisplayNode = ASDisplayNode()
        backgroundDisplayNode.backgroundColor = UIColor.whiteColor()
        addSubnode(backgroundDisplayNode)
        
        pictureImageNode = ASNetworkImageNode(webImage: ())
        pictureImageNode.cornerRadius = pictureSize / 2
        pictureImageNode.clipsToBounds = true
        pictureImageNode.backgroundColor = UIColor.profileImageGrayColor()
        pictureImageNode.URL = NSURL(string: user.imgURL)
        backgroundDisplayNode.addSubnode(pictureImageNode)
        
        nameTextNode = ASTextNode()
        var nameWithPostTypeString = String(format : "%@", user.name)
        var attString = NSMutableAttributedString(string: nameWithPostTypeString)
        var nameStringLength = count(user.name)
        var nameWithPostTypeStringLength = count(nameWithPostTypeString)
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, nameStringLength))
        nameTextNode.attributedString = attString
        backgroundDisplayNode.addSubnode(nameTextNode)
        
        horoscopeSignTextNode = ASTextNode()
        let horoscopeSignAttributes = [NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
        horoscopeSignTextNode.attributedString = NSAttributedString(string: HoroscopesManager.sharedInstance.getHoroscopesSigns()[user.sign].sign, attributes: horoscopeSignAttributes)
        backgroundDisplayNode.addSubnode(horoscopeSignTextNode)
        
        enableUserProfileInteraction()
    }
    
    func configureFollowerUI() {
        if user.isFollowed {
            followedLabel = UILabel()
            followedLabel.text = "Followed"
            followedLabel.font = UIFont.systemFontOfSize(13)
            followedLabel.textColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1)
            followedLabel.sizeToFit()
        } else {
            followButton = UIButton()
            followButton.setImage(UIImage(named: "follow_btn"), forState: UIControlState.Normal)
            followButton.addTarget(self, action: "followButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            followButton.sizeToFit()
        }
    }
    
    // MARK: - Calculate size and layout
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        backgroundDisplayNode.measure(constrainedSize)
        let nameSize = nameTextNode.measure(CGSizeMake(constrainedSize.width - pictureSize - 2*outterPadding - innerPadding, CGFloat.max))
        let horoscopeSignSize = horoscopeSignTextNode.measure(CGSizeMake(constrainedSize.width - pictureSize - outterPadding*2 - innerPadding, CGFloat.max))
        let requiredHeight = max(pictureSize, nameSize.height + horoscopeSignSize.height)
        
        return CGSizeMake(constrainedSize.width, requiredHeight + outterPadding*2)
    }
    
    override func layout() {
        backgroundDisplayNode.frame = CGRectMake(tablePadding, 0, calculatedSize.width - tablePadding*2, calculatedSize.height)
        pictureImageNode.frame = CGRectMake(outterPadding - 2, outterPadding, pictureSize, pictureSize)
        nameTextNode.frame = CGRectMake((outterPadding - 4)*2 + pictureSize, outterPadding, nameTextNode.calculatedSize.width, nameTextNode.calculatedSize.height)
        horoscopeSignTextNode.frame = CGRectMake((outterPadding - 4)*2 + pictureSize, outterPadding + nameTextNode.calculatedSize.height + innerPadding, horoscopeSignTextNode.calculatedSize.width, horoscopeSignTextNode.calculatedSize.height)
        if followerTab {
            if user.isFollowed {
                backgroundDisplayNode.view.addSubview(followedLabel)
                followedLabel.frame = CGRectMake(calculatedSize.width - outterPadding - followedLabel.bounds.size.width - tablePadding, calculatedSize.height/2 - followedLabel.bounds.size.height/2, followedLabel.bounds.size.width, followedLabel.bounds.size.height)
            } else {
                backgroundDisplayNode.view.addSubview(followButton)
                followButton.frame = CGRectMake(calculatedSize.width - outterPadding - followButton.bounds.size.width - tablePadding, calculatedSize.height/2 - followButton.bounds.size.height/2, followButton.bounds.size.width, followButton.bounds.size.height)
            }
        }
    }
    
    // MARK: - Action
    func userProfileTapped(sender: AnyObject) {
        let controller = parentViewController.storyboard?.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        controller.profileType = ProfileType.OtherUser
        controller.userProfile = user
        parentViewController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func followButtonTapped(sender: AnyObject) {
        delegate!.didClickFollowButton(user.uid)
    }
    
    // MARK: - Helper
    func enableUserProfileInteraction() {
        pictureImageNode?.userInteractionEnabled = true
        pictureImageNode?.addTarget(self, action: "userProfileTapped:", forControlEvents: .TouchUpInside)
        nameTextNode?.userInteractionEnabled = true
        nameTextNode?.addTarget(self, action: "userProfileTapped:", forControlEvents: ASControlNodeEvent.TouchUpInside)
    }
}