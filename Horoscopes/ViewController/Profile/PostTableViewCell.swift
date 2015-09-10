//
//  PostTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

@objc protocol PostTableViewCellDelegate {
    func didTapShareButton(cell: PostTableViewCell)
    optional func didTapLikeButton(cell: PostTableViewCell)
    optional func didTapPostProfile(cell: PostTableViewCell)
    optional func didTapNewsfeedFollowButton(cell: PostTableViewCell)
}

class PostTableViewCell: UITableViewCell, UIAlertViewDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Newsfeed outlet
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var horoscopeSignView: UIView!
    @IBOutlet weak var horoscopeSignImageView: UIImageView!
    @IBOutlet weak var horoscopeSignLabel: UILabel!
    @IBOutlet weak var newsfeedFollowButton: UIButton!
    
    // MARK: - Property
    
    var delegate: PostTableViewCellDelegate!
    let profileImageSize: CGFloat = 80
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureNewsfeedUi() {
        horoscopeSignView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        horoscopeSignView.layer.cornerRadius = 4
        horoscopeSignView.clipsToBounds = true
        profileImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        profileImageView.layer.shadowOpacity = 0.6
        profileImageView.layer.shadowRadius = 2
        profileImageView.clipsToBounds = false
        headerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        profileImageView.layer.cornerRadius = profileImageSize / 2
        profileImageView.clipsToBounds = true
        
        let nameGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
        profileNameLabel.userInteractionEnabled = true
        profileNameLabel.addGestureRecognizer(nameGestureRecognizer)
        profileImageView.userInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    func configureUserPostUi() {
        likeButton.hidden = true
    }
    
    @IBAction func tapNewsfeedFollowButton(sender: UIButton) {
        delegate.didTapNewsfeedFollowButton!(self)
    }
    
    func tapProfile(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            delegate.didTapPostProfile!(self)
        }
    }
    
    @IBAction func tapLikeButton(sender: UIButton) {
        delegate.didTapLikeButton?(self)
    }

    @IBAction func tapShareButton(sender: UIButton) {
        delegate.didTapShareButton(self)
    }
}
