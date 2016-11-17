//
//  FollowTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/31/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

@objc protocol FollowTableViewCellDelegate {
    @objc optional func didTapFollowButton(_ cell: FollowTableViewCell)
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
        selectionStyle = .none
        followButton = UIButton()
        followButton.isHidden = true
        followButton.addTarget(self, action: #selector(FollowTableViewCell.tapFollowButton(_:)), for: .touchUpInside)
        addSubview(followButton)
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        followButton.frame = CGRect(x: frame.width - followButtonWidth - 10, y: frame.height/2 - followButtonHeight/2 , width: followButtonWidth, height: followButtonHeight)
//        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ profile: UserProfile) {
        profileNameLabel.text = profile.name
        horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: profile.sign)
        Utilities.getImageFromUrlString(profile.imgURL, completionHandler: { (image) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.profileImageView?.image = image
            })
        })
    }
    
    func configureFollowButton(_ isFollowed: Bool, showFollowButton: Bool) {
        if showFollowButton {
            if isFollowed {
                followButton.isHidden = true
            } else {
                followButton.setImage(UIImage(named: "follow_btn"), for: UIControlState())
                followButton.isHidden = false
            }
        } else {
            followButton.isHidden = true
        }
    }
    
    func tapFollowButton(_ sender: UIButton) {
        delegate?.didTapFollowButton?(self)
    }

}
