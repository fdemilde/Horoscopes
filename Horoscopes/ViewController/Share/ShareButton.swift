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
        case shareButtonTypeTwitter
        case shareButtonTypeFacebook
        case shareButtonTypeMessages
        case shareButtonTypeEmail
        case shareButtonTypeFBMessenger
        case shareButtonTypeWhatsapp
        case shareButtonTypeViber
    }
    
    var type = ShareButtonType.shareButtonTypeEmail
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
        super.init(coder: aDecoder)!
    }
    
    func createButtonImage(){
        let imageName = self.getImageName()
        let image = UIImage(named: imageName)
        buttonImage.image = image
        let imagePosX = (self.frame.width - image!.size.width)/2
        buttonImage.frame = CGRect(x: imagePosX, y: 0, width: image!.size.width, height: image!.size.height)
        self.addSubview(buttonImage)
    }
    
    func createTitleLabel(){
        let titleString = self.getTitle()
        let font = UIFont(name: "HelveticaNeue-Light", size: 16)
        titleLabel.font = font
        let labelSize = Utilities.getLabelSizeWithString(titleString, font: font!)
        let titlePosX = (self.frame.width - labelSize.width) / 2;
        let titlePosY = buttonImage.frame.size.height + paddingHeight;
        titleLabel.frame = CGRect(x: titlePosX, y: titlePosY, width: labelSize.width, height: labelSize.height)
        titleLabel.text = titleString
        titleLabel.textColor = UIColor.black
        self.addSubview(titleLabel)
    }
    
    
    
    // MARK: Helpers
    func getTitle() -> String{
        if(type == ShareButtonType.shareButtonTypeTwitter){ return "Twitter" }
        if(type == ShareButtonType.shareButtonTypeFacebook){ return "Facebook" }
        if(type == ShareButtonType.shareButtonTypeMessages){ return "Messages" }
        if(type == ShareButtonType.shareButtonTypeEmail){ return "Email" }
        if(type == ShareButtonType.shareButtonTypeFBMessenger){ return "FBMessenger" }
        if(type == ShareButtonType.shareButtonTypeWhatsapp){ return "Whatsapp" }
        if(type == ShareButtonType.shareButtonTypeViber){ return "Viber" }
        print("ERROR getTitle: input type does not exist")
        return "Email"
    }
    
    func getImageName() -> String{
        if(type == ShareButtonType.shareButtonTypeTwitter){ return "share_twitter.png" }
        if(type == ShareButtonType.shareButtonTypeFacebook){ return "share_facebook.png" }
        if(type == ShareButtonType.shareButtonTypeMessages){ return "share_message.png" }
        if(type == ShareButtonType.shareButtonTypeEmail){ return "share_mail.png" }
        if(type == ShareButtonType.shareButtonTypeFBMessenger){ return "share_fbmessage.png" }
        if(type == ShareButtonType.shareButtonTypeWhatsapp){ return "share_whatsapp.png" }
        if(type == ShareButtonType.shareButtonTypeViber){ return "share_viber.png" }
        return "share_twitter.png"
    }
    
}
