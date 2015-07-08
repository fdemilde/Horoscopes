//
//  FollowingCollectionCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class FollowingCollectionCell : UICollectionViewCell {
 
    // cell is {80,80}
    
    let profileImageSize = 50 as CGFloat
    let feedTypeImageSize = 22 as CGFloat
    
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var feedTypeImageView : UIImageView!
    @IBOutlet weak var userNameLabel : UILabel!
    var userPost : UserPost!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = 0.5 * profileImageSize
        profileImageView.layer.masksToBounds = true
    }
    
    func populateData(post: UserPost){
        self.userPost = post
        
        Utilities.getDataFromUrl(NSURL(string: self.userPost.user!.imgURL)!) { data in
            dispatch_async(dispatch_get_main_queue()) {
                var downloadedImage = UIImage(data: data!)
                self.profileImageView.image = downloadedImage
            }
        }
        println("populateData populateData userPost name = \(userPost.user!.name)")
        var feedTypeImageName = Utilities.getFeedTypeImageName(userPost)
        feedTypeImageView.image = UIImage(named: feedTypeImageName)
        userNameLabel.text = userPost.user!.name
    }
}
