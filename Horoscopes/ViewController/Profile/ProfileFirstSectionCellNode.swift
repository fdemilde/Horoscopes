//
//  ProfileFirstSectionCellNode.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class ProfileFirstSectionCellNode: ASCellNode {
    var profilePictureImageNode: ASNetworkImageNode!
    var horoscopeSignImageNode: ASImageNode!
    var nameTextNode: ASTextNode!
    var horoscopeSignTextNode: ASTextNode!
    let profilePictureSize: CGFloat = 165
    let horoscopeSignImageSize: CGFloat = 55
    let nameHeight: CGFloat = 16
    let horoscopeSignTextHeight: CGFloat = 14.5
    let padding: CGFloat = 10
    
    init(userProfile: UserProfile) {
        super.init()
        self.selectionStyle = UITableViewCellSelectionStyle.None
        profilePictureImageNode = ASNetworkImageNode(webImage: ())
        profilePictureImageNode.cornerRadius = profilePictureSize / 2
        profilePictureImageNode.clipsToBounds = true
        profilePictureImageNode.backgroundColor = UIColor.profileImagePurpleColor()
        profilePictureImageNode.URL = NSURL(string: userProfile.imgURL)
        addSubnode(profilePictureImageNode)
        
        let horoscopeSignString = HoroscopesManager.sharedInstance.getHoroscopesSigns()[userProfile.sign].sign
        let horoscopeSignImageName = horoscopeSignString + "_icon_selected"
        horoscopeSignImageNode = ASImageNode()
        horoscopeSignImageNode.backgroundColor = UIColor.horoscopeSignImagePurpleCorlor()
        horoscopeSignImageNode.image = UIImage(named: horoscopeSignImageName)
        horoscopeSignImageNode.contentMode = UIViewContentMode.Center
        horoscopeSignImageNode.cornerRadius = horoscopeSignImageSize / 2
        horoscopeSignImageNode.clipsToBounds = true
        addSubnode(horoscopeSignImageNode)
        
        nameTextNode = ASTextNode()
        var attrs: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(13)]
        attrs[NSForegroundColorAttributeName] = UIColor.whiteColor()
        let name = NSAttributedString(string: userProfile.name, attributes: attrs)
        nameTextNode.attributedString = name
        addSubnode(nameTextNode)
        
        horoscopeSignTextNode = ASTextNode()
        attrs[NSFontAttributeName] = UIFont.systemFontOfSize(12)
        attrs[NSForegroundColorAttributeName] = UIColor(red: 186/255.0, green: 192/255.0, blue: 235/255.0, alpha: 1)
        let horoscopeSignAttributedString = NSAttributedString(string: horoscopeSignString, attributes: attrs)
        horoscopeSignTextNode.attributedString = horoscopeSignAttributedString
        addSubnode(horoscopeSignTextNode)
    }
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let nameSize = nameTextNode.measure(CGSizeMake(constrainedSize.width, nameHeight))
        let horoscopeSignSize = horoscopeSignTextNode.measure(CGSizeMake(constrainedSize.width, horoscopeSignTextHeight))
        
        return CGSizeMake(constrainedSize.width, profilePictureSize + horoscopeSignImageSize / 2 + nameHeight + horoscopeSignTextHeight + padding)
    }
    
    override func layout() {
        profilePictureImageNode.frame = CGRectMake(calculatedSize.width/2 - profilePictureSize/2, 0, profilePictureSize, profilePictureSize)
        horoscopeSignImageNode.frame = CGRectMake(calculatedSize.width/2 - horoscopeSignImageSize/2, profilePictureSize - horoscopeSignImageSize/2, horoscopeSignImageSize, horoscopeSignImageSize)
        nameTextNode.frame = CGRectMake(calculatedSize.width/2 - nameTextNode.calculatedSize.width/2, profilePictureSize + horoscopeSignImageSize/2 + padding, nameTextNode.calculatedSize.width, nameHeight)
        horoscopeSignTextNode.frame = CGRectMake(calculatedSize.width/2 - horoscopeSignTextNode.calculatedSize.width/2, profilePictureSize + horoscopeSignImageSize/2 + nameTextNode.calculatedSize.height + padding, horoscopeSignTextNode.calculatedSize.width, horoscopeSignTextHeight)
    }
}