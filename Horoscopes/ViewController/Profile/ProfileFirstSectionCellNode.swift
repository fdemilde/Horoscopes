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
    var signInImageNode: ASNetworkImageNode!
    var nameTextNode: ASTextNode!
    var horoscopeSignTextNode: ASTextNode!
    let signInImageSize: CGFloat = 80
    let nameHeight: CGFloat = 16
    let horoscopeSignHeight: CGFloat = 14.5
    let padding: CGFloat = 10
    
    init(userProfile: UserProfile) {
        super.init()
        signInImageNode = ASNetworkImageNode(webImage: ())
        signInImageNode.URL = NSURL(string: userProfile.imgURL)
        signInImageNode.cornerRadius = signInImageSize / 2
        signInImageNode.clipsToBounds = true
        addSubnode(signInImageNode)
        
        nameTextNode = ASTextNode()
        var attrs: [String: AnyObject] = [NSFontAttributeName: UIFont.systemFontOfSize(13)]
        attrs[NSForegroundColorAttributeName] = UIColor.whiteColor()
        let name = NSAttributedString(string: userProfile.name, attributes: attrs)
        nameTextNode.attributedString = name
        addSubnode(nameTextNode)
        
        horoscopeSignTextNode = ASTextNode()
        attrs[NSFontAttributeName] = UIFont.systemFontOfSize(12)
        attrs[NSForegroundColorAttributeName] = UIColor(red: 186/255.0, green: 192/255.0, blue: 235/255.0, alpha: 1)
        let horoscopeSign = NSAttributedString(string: HoroscopesManager.sharedInstance.getHoroscopesSigns()[userProfile.sign].sign, attributes: attrs)
        horoscopeSignTextNode.attributedString = horoscopeSign
        addSubnode(horoscopeSignTextNode)
    }
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        let nameSize = nameTextNode.measure(CGSizeMake(constrainedSize.width, nameHeight))
        let horoscopeSignSize = horoscopeSignTextNode.measure(CGSizeMake(constrainedSize.width, horoscopeSignHeight))
        
        return CGSizeMake(constrainedSize.width, signInImageSize + nameHeight + horoscopeSignHeight + padding)
    }
    
    override func layout() {
        signInImageNode.frame = CGRectMake(calculatedSize.width/2 - signInImageSize/2, 0, signInImageSize, signInImageSize)
        nameTextNode.frame = CGRectMake(calculatedSize.width/2 - nameTextNode.calculatedSize.width/2, signInImageSize + padding, nameTextNode.calculatedSize.width, nameHeight)
        horoscopeSignTextNode.frame = CGRectMake(calculatedSize.width/2 - horoscopeSignTextNode.calculatedSize.width/2, signInImageSize + nameTextNode.calculatedSize.height + padding, horoscopeSignTextNode.calculatedSize.width, horoscopeSignHeight)
    }
}