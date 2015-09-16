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
    optional func didTapFollowProfile(cell: FollowTableViewCell)
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
        let nameGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
        profileNameLabel.userInteractionEnabled = true
        profileNameLabel.addGestureRecognizer(nameGestureRecognizer)
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageGestureRecognizer)
        
//        let separatorImageView = UIImageView(image: UIImage(named: "separator"))
//        separatorImageView.frame = CGRect(x: 10, y: 70, width: frame.width - 10*2, height: 1)
//        addSubview(separatorImageView)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureFollowButton(isFollowed: Bool, showFollowButton: Bool) {
        if followButton == nil {
            followButton = UIButton()
            addSubview(followButton)
        }
        followButton.frame = CGRect(x: frame.width - followButtonWidth - 10, y: frame.height/2 - followButtonHeight/2 , width: followButtonWidth, height: followButtonHeight)
        if showFollowButton {
            followButton.hidden = false
            if isFollowed {
                followButton.setImage(UIImage(named: "follow_check_icon"), forState: .Normal)
                followButton.enabled = false
            } else {
                followButton.setImage(UIImage(named: "follow_btn"), forState: .Normal)
                followButton.addTarget(self, action: "tapFollowButton:", forControlEvents: .TouchUpInside)
            }
        } else {
            followButton.hidden = true
        }
    }
    
    func tapFollowButton(sender: UIButton) {
        delegate?.didTapFollowButton?(self)
    }
    
    func tapProfile(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            delegate?.didTapFollowProfile?(self)
        }
    }

}
