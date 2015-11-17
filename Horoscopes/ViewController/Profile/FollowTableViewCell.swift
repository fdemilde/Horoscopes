//
//  FollowTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/31/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

@objc protocol FollowTableViewCellDelegate {
    optional func didTapFollowButton(cell: FollowTableViewCell)
}

class FollowTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var horoscopeSignLabel: UILabel!
    let followButtonWidth: CGFloat = 60
    let followButtonHeight: CGFloat = 44
    var delegate: FollowTableViewCellDelegate?
    var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .None
        followButton = UIButton()
        followButton.hidden = true
        followButton.addTarget(self, action: "tapFollowButton:", forControlEvents: .TouchUpInside)
        addSubview(followButton)
        profileImageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        followButton.frame = CGRect(x: frame.width - followButtonWidth - 10, y: frame.height/2 - followButtonHeight/2 , width: followButtonWidth, height: followButtonHeight)
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(profile: UserProfile) {
        profileNameLabel.text = profile.name
        horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: profile.sign)
        Utilities.getImageFromUrlString(profile.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.profileImageView?.image = image
            })
        })
    }
    
    func configureFollowButton(isFollowed: Bool, showFollowButton: Bool) {
        if showFollowButton {
            if isFollowed {
                followButton.hidden = true
            } else {
                followButton.setImage(UIImage(named: "follow_btn"), forState: .Normal)
                followButton.hidden = false
            }
        } else {
            followButton.hidden = true
        }
    }
    
    func tapFollowButton(sender: UIButton) {
        delegate?.didTapFollowButton?(self)
    }

}
