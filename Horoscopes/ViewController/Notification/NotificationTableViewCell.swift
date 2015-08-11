//
//  NotificationTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var notificationDescLabel: UILabel!
    @IBOutlet weak var notifTypeImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    var notification : NotificationObject!
    var type = ServerNotificationType.Follow
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: for Testing now, only fake data
    func populateData(notif : NotificationObject){
        notification = notif
        self.profilePictureImageView.backgroundColor = UIColor.profileImageGrayColor()
        self.setNotificationType()
        self.setupComponents()
        self.getUserProfile()
//        self.defaultCell()
        
        
    }
    
    // MARK: Populate UI
    func setupComponents(){
        var desc = "send you heart"
//        notificationDescLabel.attributedText = self.createDescAttributedString(desc)
        notificationDescLabel.text = desc
        timeLabel.text = Utilities.getTimeAgoString(notification.created)
//        timeLabel.text = "10 minutes ago"
        switch(type){
            case ServerNotificationType.SendHeart:
                notifTypeImageView.image = UIImage(named: "send_heart_icon")
            case ServerNotificationType.Follow:
                notifTypeImageView.image = UIImage(named: "follow_icon")
            default:
                notifTypeImageView.image = UIImage(named: "send_heart_icon")
        }
        
    }
    
    // MARK: Helpers
    func setNotificationType(){
        switch(self.notification.ref){
            case "send_heart":
                self.type = ServerNotificationType.SendHeart
            case "follow":
                self.type = ServerNotificationType.Follow
            default:
                println("getNotificationType type is not available")
                self.type = ServerNotificationType.SendHeart
        }
    }
    
    func defaultCell(){
        var imageURL = NSURL(string: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xfa1/v/t1.0-1/p160x160/11210415_976351309044730_8258958221771799158_n.jpg?oh=8e218674b285255d08cc6506ba1d27a1&oe=561997A7&__gda__=1448374830_c84a435124e10413bed7cd7774800790")
        Utilities.getDataFromUrl(imageURL!) { data -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                var downloadedImage = UIImage(data: data!)
                self.profilePictureImageView.image = downloadedImage
            }
        }
        
        var desc = "Cedric Chin, Binh Dang and 2 other people send you hearts"
        
        
        notificationDescLabel.attributedText = self.createDescAttributedString(desc)
        timeLabel.text = "10 minutes ago"
        notifTypeImageView.image = UIImage(named: "send_heart_icon")
    }
    
    func createDescAttributedString(nameString : String) -> NSMutableAttributedString {
        var attString = NSMutableAttributedString(string: nameString)
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, 21))
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, 21))
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12.0), range: NSMakeRange(21, 34)) // +1 for the space between
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(21, 34))
        return attString
    }
    
    // Network
    func getUserProfile(){
        XAppDelegate.socialManager.getProfile(notification.sender, completionHandler: { (result, error) -> Void in
//            println("getProfile getProfile == \(result)")
            if let result = result {
                for user in result {
                    if let url = NSURL(string: user.imgURL) {
                        self.downloadImage(url)
                    }
                }
            }
        })
    }
    
    // MARK: helpers
    
    func downloadImage(url:NSURL){
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                var downloadedImage = UIImage(data: data!)
                self.profilePictureImageView.image = downloadedImage
                self.profilePictureImageView.backgroundColor = UIColor.clearColor()
            }
        }
    }

}
