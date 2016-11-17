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
    var type = ServerNotificationType.follow
    let SEND_HEART_TEXT = " sends you a heart"
    let FOLLOWING_TEXT = " is following you"
    let DEFAULT_TEXT = " sends you a notification"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: for Testing now, only fake data
    func populateData(_ notif : NotificationObject){
        DispatchQueue.main.async(execute: {
            self.notification = notif
            self.cellImageView.backgroundColor = UIColor.profileImageGrayColor()
            self.cellImageView.layer.cornerRadius = self.cellImageView.frame.width/2
            
            self.parseAlertObject()
            self.setNotificationType()
            self.setupComponents()
        })
    }
    
    // resetUI
    func resetUI(){
        DispatchQueue.main.async(execute: {
            self.timeLabel.text = ""
            self.notificationDescLabel.text = ""
            self.cellImageView.image = nil
//            self.cellOverlay.hidden = true
        })
    }
    
    // MARK: Populate UI
    func setupComponents(){
        DispatchQueue.main.async(execute: {
            self.timeLabel.text = Utilities.getTimeAgoString(self.notification.created)
            self.notificationDescLabel.text = self.alertObject?.body
            switch(self.type){
                case ServerNotificationType.sendHeart:
                    self.notifTypeImageView.image = UIImage(named: "send_heart_icon")
                case ServerNotificationType.follow:
                    self.notifTypeImageView.image = UIImage(named: "follow_icon")
                default:
                    self.notifTypeImageView.image = UIImage(named: "send_heart_icon")
                
                
            }
            self.setupCellImage()
        })
    }
    
    func setupCellImage(){
        if let url = URL(string: (alertObject?.imageURL)!) {
            self.downloadImageAndSetToImageHolder(url, imageHolder: self.cellImageView)
        }
    }
    
    // MARK: Helpers
    func setNotificationType(){
        
        switch(self.alertObject?.type){
            case ?"send_heart":
                self.type = ServerNotificationType.sendHeart
            case ?"follow":
                self.type = ServerNotificationType.follow
            default:
                self.type = ServerNotificationType.default
        }
    }
    
    func defaultCell(){
        let imageURL = URL(string: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xfa1/v/t1.0-1/p160x160/11210415_976351309044730_8258958221771799158_n.jpg?oh=8e218674b285255d08cc6506ba1d27a1&oe=561997A7&__gda__=1448374830_c84a435124e10413bed7cd7774800790")
        Utilities.getDataFromUrl(imageURL!) { data -> Void in
            DispatchQueue.main.async {
                if let checkData = data {
                    let downloadedImage = UIImage(data: checkData)
                    self.cellImageView.image = downloadedImage
                } else {
                    let image = UIImage(named: "default_avatar")
                    self.cellImageView.image = image
                }
            }
        }
        
        let desc = "Cedric Chin, Binh Dang and 2 other people send you hearts"
        
        
        notificationDescLabel.attributedText = self.createDescAttributedString(desc)
        timeLabel.text = "10 minutes ago"
        notifTypeImageView.image = UIImage(named: "send_heart_icon")
    }
    
    func createDescAttributedString(_ nameString : String) -> NSMutableAttributedString {
        var string = nameString
        
        switch(self.type){
            case ServerNotificationType.sendHeart:
                string += SEND_HEART_TEXT
            case ServerNotificationType.follow:
                string += FOLLOWING_TEXT
            default:
                string += DEFAULT_TEXT
        }
        let attString = NSMutableAttributedString(string: string)
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 13.0), range: NSMakeRange(0, nameString.characters.count))
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, nameString.characters.count))
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12.0), range: NSMakeRange(nameString.characters.count, nameString.characters.count - nameString.characters.count)) // +1 for the space between
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(nameString.characters.count, nameString.characters.count - nameString.characters.count))
        return attString
    }
    // MARK: helpers
    
    func downloadImageAndSetToImageHolder(_ url:URL, imageHolder : UIImageView){
        Utilities.getDataFromUrl(url) { data in
            DispatchQueue.main.async {
                
                if let checkData = data {
                    let downloadedImage = UIImage(data: checkData)
                    imageHolder.image = downloadedImage
                    imageHolder.backgroundColor = UIColor.clear
                } else {
                    let image = UIImage(named: "default_avatar")
                    imageHolder.image = image
                    imageHolder.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    func parseAlertObject(){
        if let alert = notification.alert{
            var alertObject = Alert()
            alertObject = alertObject?.fromJson(alert)
            self.alertObject = alertObject
        }
    }
    
    func updateTimeAgo(){
        if let notification = self.notification{
            self.timeLabel.text = Utilities.getTimeAgoString(notification.created)
        }
    }

}
