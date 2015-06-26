//
//  ShareButton.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/22/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class ShareButton : UIView {
    
    enum ShareButtonType {
        case ShareButtonTypeTwitter
        case ShareButtonTypeFacebook
        case ShareButtonTypeMessages
        case ShareButtonTypeEmail
        case ShareButtonTypeFBMessenger
        case ShareButtonTypeWhatsapp
        case ShareButtonTypeViber
    }
    
    var type = ShareButtonType.ShareButtonTypeEmail
    var parentVC = ShareViewController()
    var titleLabel = UILabel()
    var buttonImage = UIImageView()
    let paddingHeight = 10 as CGFloat
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    init(type : ShareButtonType, frame: CGRect){
        super.init(frame: frame)
        self.type = type
//        self.frame = frame
        self.createButtonImage()
        self.createTitleLabel()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createButtonImage(){
        var imageName = self.getImageName()
        var image = UIImage(named: imageName)
        buttonImage.image = image
        var imagePosX = (self.frame.width - image!.size.width)/2
        buttonImage.frame = CGRectMake(imagePosX, 0, image!.size.width, image!.size.height)
        self.addSubview(buttonImage)
    }
    
    func createTitleLabel(){
        var titleString = self.getTitle()
        var font = UIFont(name: "HelveticaNeue-Light", size: 16)
        titleLabel.font = font
        var labelSize = Utilities.getLabelSizeWithString(titleString, font: font!)
        var titlePosX = (self.frame.width - labelSize.width) / 2;
        var titlePosY = buttonImage.frame.size.height + paddingHeight;
        titleLabel.frame = CGRectMake(titlePosX, titlePosY, labelSize.width, labelSize.height)
        titleLabel.text = titleString
        titleLabel.textColor = UIColor.blackColor()
        self.addSubview(titleLabel)
    }
    
    
    
    // MARK: Helpers
    func getTitle() -> String{
        if(type == ShareButtonType.ShareButtonTypeTwitter){ return "Twitter" }
        if(type == ShareButtonType.ShareButtonTypeFacebook){ return "Facebook" }
        if(type == ShareButtonType.ShareButtonTypeMessages){ return "Messages" }
        if(type == ShareButtonType.ShareButtonTypeEmail){ return "Email" }
        if(type == ShareButtonType.ShareButtonTypeFBMessenger){ return "FBMessenger" }
        if(type == ShareButtonType.ShareButtonTypeWhatsapp){ return "Whatsapp" }
        if(type == ShareButtonType.ShareButtonTypeViber){ return "Viber" }
        println("ERROR getTitle: input type does not exist")
        return "Email"
    }
    
    func getImageName() -> String{
        if(type == ShareButtonType.ShareButtonTypeTwitter){ return "share_twitter.png" }
        if(type == ShareButtonType.ShareButtonTypeFacebook){ return "share_facebook.png" }
        if(type == ShareButtonType.ShareButtonTypeMessages){ return "share_message.png" }
        if(type == ShareButtonType.ShareButtonTypeEmail){ return "share_mail.png" }
        if(type == ShareButtonType.ShareButtonTypeFBMessenger){ return "share_fbmessage.png" }
        if(type == ShareButtonType.ShareButtonTypeWhatsapp){ return "share_whatsapp.png" }
        if(type == ShareButtonType.ShareButtonTypeViber){ return "share_viber.png" }
        return "share_twitter.png"
    }
    
}
