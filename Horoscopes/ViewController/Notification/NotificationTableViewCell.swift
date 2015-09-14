//
//  NotificationTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var notificationDescLabel: UILabel!
    @IBOutlet weak var notifTypeImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cellOverlay:  UIView!
    
    var notification : NotificationObject!
    var alertObject = Alert()
    var type = ServerNotificationType.Follow
    let SEND_HEART_TEXT = " sends you a heart"
    let FOLLOWING_TEXT = " is following you"
    let DEFAULT_TEXT = " sends you a notification"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: for Testing now, only fake data
    func populateData(notif : NotificationObject){
        notification = notif
        self.cellImageView.backgroundColor = UIColor.profileImageGrayColor()
        self.parseAlertObject()
        self.setNotificationType()
        self.setupComponents()
//        self.getUserProfile()
    }
    
    // resetUI
    func resetUI(){
        timeLabel.text = ""
        notificationDescLabel.text = ""
        cellImageView.image = nil
        cellOverlay.hidden = true
    }
    
    // MARK: Populate UI
    func setupComponents(){
        timeLabel.text = Utilities.getTimeAgoString(notification.created)
        notificationDescLabel.text = alertObject.body
        switch(type){
            case ServerNotificationType.SendHeart:
                notifTypeImageView.image = UIImage(named: "send_heart_icon")
                cellOverlay.hidden = true
            case ServerNotificationType.Follow:
                notifTypeImageView.image = UIImage(named: "follow_icon")
                cellOverlay.hidden = false
            default:
                notifTypeImageView.image = UIImage(named: "send_heart_icon")
                cellOverlay.hidden = true
            
            
        }
        self.bringSubviewToFront(cellOverlay)
        self.backgroundColor = UIColor.whiteColor()
        self.setupCellImage()
        
    }
    
    func setupCellImage(){
        if let url = NSURL(string: alertObject.imageURL) {
            self.downloadImageAndSetToImageHolder(url, imageHolder: self.cellImageView)
        }
    }
    
    // MARK: Helpers
    func setNotificationType(){
        
        switch(self.alertObject.type){
            case "send_heart":
                self.type = ServerNotificationType.SendHeart
            case "follow":
                self.type = ServerNotificationType.Follow
            default:
                self.type = ServerNotificationType.Default
        }
    }
    
    func defaultCell(){
        var imageURL = NSURL(string: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xfa1/v/t1.0-1/p160x160/11210415_976351309044730_8258958221771799158_n.jpg?oh=8e218674b285255d08cc6506ba1d27a1&oe=561997A7&__gda__=1448374830_c84a435124e10413bed7cd7774800790")
        Utilities.getDataFromUrl(imageURL!) { data -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                var downloadedImage = UIImage(data: data!)
                self.cellImageView.image = downloadedImage
            }
        }
        
        var desc = "Cedric Chin, Binh Dang and 2 other people send you hearts"
        
        
        notificationDescLabel.attributedText = self.createDescAttributedString(desc)
        timeLabel.text = "10 minutes ago"
        notifTypeImageView.image = UIImage(named: "send_heart_icon")
    }
    
    func createDescAttributedString(nameString : String) -> NSMutableAttributedString {
        var string = nameString
        
        switch(self.type){
            case ServerNotificationType.SendHeart:
                string += SEND_HEART_TEXT
            case ServerNotificationType.Follow:
                string += FOLLOWING_TEXT
            default:
                string += DEFAULT_TEXT
        }
        var attString = NSMutableAttributedString(string: string)
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, count(nameString)))
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, count(nameString)))
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12.0), range: NSMakeRange(count(nameString), count(string) - count(nameString))) // +1 for the space between
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(count(nameString), count(string) - count(nameString)))
        return attString
    }
    // MARK: helpers
    
    func downloadImageAndSetToImageHolder(url:NSURL, imageHolder : UIImageView){
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                var downloadedImage = UIImage(data: data!)
                imageHolder.image = downloadedImage
                imageHolder.backgroundColor = UIColor.clearColor()
            }
        }
    }
    
    func parseAlertObject(){
        if let alert = notification.alert{
            var alertObject = Alert()
            alertObject = alertObject.fromJson(alert)
            self.alertObject = alertObject
        }
    }

}
