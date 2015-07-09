//
//  PostCellNode.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class PostCellNode: ASCellNode {
    let profileImageSize: CGFloat = 80.0
    let outterPadding: CGFloat = 16.0
    let innerPadding: CGFloat = 10.0
    
    var userPost: UserPost!
    var profileImageNode: ASNetworkImageNode?
    var profileNameTextNode: ASTextNode?
    var separator: ASDisplayNode?
    var backgroundDisplayNode: ASDisplayNode!
    var dateTimeTextNode: ASTextNode?
    
    init!(userPost: UserPost) {
        super.init()
        self.userPost = userPost
        
        backgroundDisplayNode = ASDisplayNode()
        backgroundDisplayNode.backgroundColor = UIColor(red: 238.0/255.0, green: 238.0/255.0, blue: 242.0/255.0, alpha: 1)
        self.addSubnode(backgroundDisplayNode)
        
        self.setupHeader()
    }
    
    func setupHeader() {
        profileImageNode = ASNetworkImageNode()
        profileImageNode!.backgroundColor = ASDisplayNodeDefaultPlaceholderColor()
        profileImageNode!.URL = NSURL(string: userPost.user!.imgURL)
        backgroundDisplayNode.addSubnode(profileImageNode)
        
        profileNameTextNode = ASTextNode()
//        let name = String(format: "%@", userPost.user!.name)
//        var attrString = NSMutableAttributedString(string: name)
//        attrString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, count(userPost.user!.name)))
//        profileNameTextNode!.attributedString = attrString
        profileNameTextNode!.attributedString = NSAttributedString(string: "\(userPost.user!.name)")
        backgroundDisplayNode.addSubnode(profileNameTextNode)
        
        dateTimeTextNode = ASTextNode()
        let timeDict = [NSForegroundColorAttributeName: UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1), NSFontAttributeName : UIFont.systemFontOfSize(11.0)]
        dateTimeTextNode!.attributedString = NSAttributedString(string: self.getTimePassedString(), attributes: timeDict)
        backgroundDisplayNode.addSubnode(dateTimeTextNode)
    }
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let profileImageNodeSize = CGSizeMake(profileImageSize, profileImageSize)
        return CGSizeMake(constrainedSize.width, profileImageSize + 2*outterPadding)
    }
    
    override func layout() {
        backgroundDisplayNode.cornerRadius = 5
        backgroundDisplayNode.layer.masksToBounds = true
        backgroundDisplayNode.frame = CGRectMake(0, 0, self.calculatedSize.width, self.calculatedSize.height)
        
        profileImageNode!.frame = CGRectMake(outterPadding, outterPadding, profileImageSize, profileImageSize)
        
        profileNameTextNode!.frame = CGRectMake(profileImageNode!.frame.origin.x + profileImageSize + innerPadding, outterPadding, profileNameTextNode!.calculatedSize.width, profileNameTextNode!.calculatedSize.height)
        
        dateTimeTextNode!.frame = CGRectMake(profileImageNode!.frame.origin.x + profileImageSize + innerPadding, profileNameTextNode!.frame.origin.y + profileNameTextNode!.calculatedSize.height, dateTimeTextNode!.calculatedSize.width, dateTimeTextNode!.calculatedSize.height)
    }
    
    func getTimePassedString() -> String {
        var timePassSecond = Int(NSDate().timeIntervalSince1970) - userPost!.ts
        return String(format: "%d mins ago", timePassSecond/60)
    }
}