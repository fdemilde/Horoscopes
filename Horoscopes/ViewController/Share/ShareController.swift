//
//  ShareController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/24/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import Social
import MessageUI

class ShareController : NSObject, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    // MARK: Facebook
    
    func shareFacebook(parentVC : UIViewController, text : String, pictureURL : String ,  url : String ){
        var composerVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        composerVC.completionHandler = { (result : SLComposeViewControllerResult) in
            if (result == SLComposeViewControllerResult.Cancelled) {
                println("Share FB Cancel!!")
            } else {
                println("Share FB OK!!")
            }
            composerVC.dismissViewControllerAnimated(true, completion: nil)
        }
        composerVC.setInitialText(text)
        
        composerVC.addURL(NSURL(string: url)!)
        composerVC.addImage(ShareController.getImageFromURL(pictureURL))
        parentVC.presentViewController(composerVC, animated: true, completion: nil)
    }
    
    // MARK: Twitter
    
    func shareTwitter(parentVC : UIViewController, text : String,pictureURL : String ,  url : String ){
        var composerVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        composerVC.completionHandler = { (result : SLComposeViewControllerResult) in
            if (result == SLComposeViewControllerResult.Cancelled) {
                println("Share TW Cancel!!")
            } else {
                println("Share TW OK!!")
            }
            composerVC.dismissViewControllerAnimated(true, completion: nil)
        }
        composerVC.setInitialText(text)
        composerVC.addURL(NSURL(string: url)!)
        composerVC.addImage(ShareController.getImageFromURL(pictureURL))
        parentVC.presentViewController(composerVC, animated: true, completion: nil)
    }
    
    // Messages
    
    func shareMessage(parentVC : UIViewController, text : String){
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        //        messageComposeVC.recipients
        messageComposeVC.body = text
        
        // Present the configured MFMessageComposeViewController instance
        // Note that the dismissal of the VC will be handled by the messageComposer instance,
        // since it implements the appropriate delegate call-back
        parentVC.presentViewController(messageComposeVC, animated: true, completion: nil)
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        println("Finish send message")
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Mail
    
    func shareMail(parentVC : UIViewController, text : String){
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        mailComposeVC.setSubject("My Horoscope Today")
        mailComposeVC.setMessageBody(text, isHTML: false)
        
        // Present the configured MFMessageComposeViewController instance
        // Note that the dismissal of the VC will be handled by the messageComposer instance,
        // since it implements the appropriate delegate call-back
        parentVC.presentViewController(mailComposeVC, animated: true, completion: nil)
    }
    
    // MFMailComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Whatsapp
    func shareWhatapps(text : String, url: String){
        var sharingText = String(format:"whatsapp://send?text=%@", text)
        println("sharingText sharingText = \(sharingText)")
        var whatsappURL = NSURL(string: sharingText.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        if(UIApplication.sharedApplication().canOpenURL(whatsappURL!)){
            UIApplication.sharedApplication().openURL(whatsappURL!)
        } else {
            println("Cannott open URL")
        }

    }
    
    // MARK: share FBMessage
    func shareFbMessage(signName : String, text : String, url: String, pictureURL : String){
        let content:FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = NSURL(string: url)
        content.contentTitle = String(format: "Daily %@ Horoscope", signName)
        content.contentDescription = text
        content.imageURL = NSURL(string: pictureURL)
        
        FBSDKMessageDialog.showWithContent(content, delegate:nil);
        
    }
    
    // MARK: Helpers
    
    class func getImageFromURL(urlString: String) -> UIImage{
        let url = NSURL(string: urlString)
        let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        return UIImage(data: data!)!
    }
}