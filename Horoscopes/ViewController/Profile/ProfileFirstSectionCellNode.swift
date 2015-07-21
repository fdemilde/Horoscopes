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
    
    init(userProfile: UserProfile) {
        super.init()
        signInImageNode = ASNetworkImageNode(webImage: ())
        signInImageNode.URL = NSURL(string: userProfile.imgURL)
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
        let signInSize = CGSizeMake(signInImageSize, signInImageSize)
        let nameSize = nameTextNode.measure(CGSizeMake(constrainedSize.width, CGFloat.max))
        let horoscopeSignSize = horoscopeSignTextNode.measure(CGSizeMake(constrainedSize.width, CGFloat.max))
        
        return CGSizeMake(constrainedSize.width, signInSize.height + nameSize.height + horoscopeSignSize.height)
    }
    
    override func layout() {
        signInImageNode.frame = CGRectMake(calculatedSize.width/2 - signInImageSize/2, 0, signInImageSize, signInImageSize)
        nameTextNode.frame = CGRectMake(calculatedSize.width/2 - nameTextNode.calculatedSize.width/2, signInImageSize, nameTextNode.calculatedSize.width, nameTextNode.calculatedSize.height)
        horoscopeSignTextNode.frame = CGRectMake(calculatedSize.width/2 - horoscopeSignTextNode.calculatedSize.width/2, signInImageSize + nameTextNode.calculatedSize.height, horoscopeSignTextNode.calculatedSize.width, horoscopeSignTextNode.calculatedSize.height)
    }
}