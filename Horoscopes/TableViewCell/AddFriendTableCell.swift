//
//  AddFriendTableCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/28/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class AddFriendTableCell : UITableViewCell {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var followedLabel: UILabel!
    
    
    var userProfile : UserProfile!
    var followingDelegate : FollowDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profilePictureImageView.layer.cornerRadius = 15 // image size = 30px
        self.profilePictureImageView.clipsToBounds = true
        
    }
    
    func setupCell(userProfile : UserProfile, isFollowing : Bool, profileVC : ProfileViewController){
        self.userProfile = userProfile
        // set name
        nameLabel.text = userProfile.name
        // set profile image
        if let url = NSURL(string: userProfile.imgURL) {
            self.downloadImage(url)
        }
        if(isFollowing){
            followButton.hidden = true
        }
        followingDelegate = profileVC
    }
    
    // MARK: helpers
    
    func downloadImage(url:NSURL){
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                var downloadedImage = UIImage(data: data!)
                self.profilePictureImageView.image = downloadedImage
            }
        }
    }
    
    // MARK: Button actions
    
    @IBAction func followButtonTapped(sender: AnyObject) {
        followingDelegate.didClickFollowButton(userProfile.uid)
        self.followButton.hidden = true
    }
    
    
    
}
