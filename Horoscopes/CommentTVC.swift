//
//  CommentTVC.swift
//  Horoscopes
//
//  Created by AndAnotherOne on 12/6/16.
//  Copyright © 2016 Binh Dang. All rights reserved.
//

import UIKit

class CommentTVC: UITableViewCell {

    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var btnDropdown: UIButton!
    @IBOutlet weak var TvComment: UITextView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblCommentDate: UILabel!
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var viewContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideOptions()
        viewContainer.layer.cornerRadius = 4
        imgViewProfile.layer.cornerRadius = imgViewProfile.layer.frame.height / 2
        imgViewProfile.clipsToBounds = true
        
    }
    
    override func prepareForReuse() {
        hideOptions()
    }
    
    func configureCell(userComment: UserPostComment) {
        
            self.TvComment.text = userComment.comment
            self.lblLike.text = "\(userComment.hearts)"
            let user = userComment.user
            self.lblUsername.text = user.name
            print("timestampe:", userComment.ts)

        
//        Utilities.getImageFromUrlString(user.imgURL, completionHandler: { (image) in
//            if image != nil {
//                DispatchQueue.main.async(execute: { () -> Void in
//                    self.imgViewProfile.image = image
//                })
//                
//            }
//        })
        
    }
    
    func hideOptions() {
        
    }
    
    func showOptions() {
        
    }

    @IBAction func btnDropdownDidTouch(_ sender: Any) {
        showOptions()
    }
    
    @IBAction func btnLikeDidTouch(_ sender: Any) {
    }
    
}
