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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: for Testing now, only fake data
    func populateData(){
        var imageURL = NSURL(string: "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-xfa1/v/t1.0-1/p160x160/11210415_976351309044730_8258958221771799158_n.jpg?oh=8e218674b285255d08cc6506ba1d27a1&oe=561997A7&__gda__=1448374830_c84a435124e10413bed7cd7774800790")
        Utilities.getDataFromUrl(imageURL!) { data -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                var downloadedImage = UIImage(data: data!)
                self.profilePictureImageView.image = downloadedImage
            }
        }
        
        var desc = "Cedric Chin, Binh Dang and 1 other people send you hearts"
        
        var attString = NSMutableAttributedString(string: desc)
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13.0), range: NSMakeRange(0, 21))
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, 21))
        
        attString.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(12.0), range: NSMakeRange(21, 34)) // +1 for the space between
        attString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(21, 34))
        notificationDescLabel.attributedText = attString
        timeLabel.text = "10 minutes ago"
        notifTypeImageView.image = UIImage(named: "send_heart_icon")
    }

}
