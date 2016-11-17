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
    var eventTrackerString: String!
    
    init(eventTrackerStr: String) {
        eventTrackerString = eventTrackerStr
    }
    
    // MARK: Facebook
    
    func shareFacebook(_ parentVC : UIViewController, text : String, pictureURL : String ,  url : String ){
        let composerVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        composerVC?.completionHandler = { (result : SLComposeViewControllerResult) in
            if (result == SLComposeViewControllerResult.cancelled) {
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareCancel, label: self.eventTrackerString)
                print("Share FB Cancel!!")
            } else {
                self.eventTrackerString! += ", result = Done"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareComplete, label: self.eventTrackerString)
                print("Share FB OK!!")
            }
            composerVC?.dismiss(animated: true, completion: nil)
        }
        composerVC?.add(URL(string: url)!)
        if(pictureURL != ""){
            composerVC?.add(getImageFromURL(pictureURL))
        }
        parentVC.present(composerVC!, animated: true, completion: nil)
    }
    
    // MARK: Twitter
    
    func shareTwitter(_ parentVC : UIViewController, text : String,pictureURL : String ,  url : String ){
        let composerVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        composerVC?.completionHandler = { (result : SLComposeViewControllerResult) in
            if (result == SLComposeViewControllerResult.cancelled) {
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareCancel, label: self.eventTrackerString)
                print("Share TW Cancel!!")
            } else {
                self.eventTrackerString! += ", result = Done"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareComplete, label: self.eventTrackerString)
                print("Share TW OK!!")
            }
            composerVC?.dismiss(animated: true, completion: nil)
        }
//        composerVC.setInitialText(url)
        composerVC?.add(URL(string: url)!)
        if(pictureURL != ""){
            composerVC?.add(getImageFromURL(pictureURL))
        }
        
        parentVC.present(composerVC!, animated: true, completion: nil)
    }
    
    // Messages
    
    func shareMessage(_ parentVC : UIViewController, text : String, shareUrl : String){
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        //        messageComposeVC.recipients
        messageComposeVC.body = shareUrl
        
        // Present the configured MFMessageComposeViewController instance
        // Note that the dismissal of the VC will be handled by the messageComposer instance,
        // since it implements the appropriate delegate call-back
        parentVC.present(messageComposeVC, animated: true, completion: nil)
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        if result.rawValue == MessageComposeResult.cancelled.rawValue {
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareCancel, label: self.eventTrackerString)
        } else if result.rawValue == MessageComposeResult.sent.rawValue {
            self.eventTrackerString! += ", result = Sent"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareComplete, label: self.eventTrackerString)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    // Mail
    
    func shareMail(_ parentVC : UIViewController, text : String, shareUrl : String){
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        mailComposeVC.setSubject("Horoscopes - daily horoscope and fortune")
        mailComposeVC.setMessageBody(shareUrl, isHTML: false)
        
        // Present the configured MFMessageComposeViewController instance
        // Note that the dismissal of the VC will be handled by the messageComposer instance,
        // since it implements the appropriate delegate call-back
        parentVC.present(mailComposeVC, animated: true, completion: nil)
    }
    
    // MFMailComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result.rawValue == MFMailComposeResult.cancelled.rawValue {
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareCancel, label: self.eventTrackerString)
        } else if result.rawValue == MFMailComposeResult.sent.rawValue {
            self.eventTrackerString! += ", result = Sent"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.shareComplete, label: self.eventTrackerString)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Whatsapp
    func shareWhatapps(_ text : String, url: String){
        let whatsappURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        if(UIApplication.shared.canOpenURL(whatsappURL!)){
            UIApplication.shared.openURL(whatsappURL!)
        } else {
            print("Cannot open URL")
        }

    }
    
    // MARK: share FBMessage
    func shareFbMessage(_ title : String, text : String, url: String, pictureURL : String){
        let content:FBSDKShareLinkContent = FBSDKShareLinkContent()
        content.contentURL = URL(string: url)
        content.contentTitle = title
        content.contentDescription = text
        content.imageURL = URL(string: pictureURL)
        
        FBSDKMessageDialog.show(with: content, delegate:nil);
        
    }
    
    // MARK: Helpers
    
    func getImageFromURL(_ urlString: String) -> UIImage{
        let url = URL(string: urlString)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
        if let checkData = data {
            return UIImage(data: checkData)!
        }
        return UIImage()
    }
}
