//
//  PostTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

@objc protocol PostTableViewCellDelegate {
    optional func didTapShareButton(cell: PostTableViewCell)
    optional func didTapLikeButton(cell: PostTableViewCell)
    optional func didTapPostProfile(cell: PostTableViewCell)
    optional func didTapNewsfeedFollowButton(cell: PostTableViewCell)
}

class PostTableViewCell: UITableViewCell, UIAlertViewDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var postTypeShadowUpper: UIView!
    @IBOutlet weak var postTypeShadowLower: UIView!
    
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var actionView: UIView!
    
    // MARK: - Newsfeed outlet
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var horoscopeSignView: UIView!
    @IBOutlet weak var horoscopeSignImageView: UIImageView!
    @IBOutlet weak var horoscopeSignLabel: UILabel!
    @IBOutlet weak var newsfeedFollowButton: UIButton!
    
    // MARK: - Property
    
    var delegate: PostTableViewCellDelegate?
    let profileImageSize: CGFloat = 80
    var postTypeLabel: UILabel!
    var topBorder: CALayer!
    let minimumTextViewHeight = UIScreen.mainScreen().bounds.height - TABBAR_HEIGHT - ADMOD_HEIGHT - 50 - 350
    var heightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
        postTypeLabel = UILabel()
        postTypeLabel.textColor = UIColor.whiteColor()
        addSubview(postTypeLabel)
        topBorder = CALayer()
        topBorder.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1).CGColor
        actionView.layer.addSublayer(topBorder)
        heightConstraint = NSLayoutConstraint(item: textView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: minimumTextViewHeight)
        if #available(iOS 8.0, *) {
            heightConstraint.active = true
        } else {
            // Fallback on earlier versions
            textView.addConstraint(heightConstraint)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        postTypeLabel.sizeToFit()
        postTypeLabel.frame.origin = CGPoint(x: postTypeImageView.frame.origin.x + postTypeImageView.frame.width + 20, y: headerView.frame.height/2 - postTypeLabel.frame.height/2)
        topBorder.frame = CGRect(x: 0, y: 0, width: actionView.frame.width, height: 1)
    }
    
    // MARK: BINH BINH, need to reset all UI before populating to prevent wrong UI from reusing cell
    func resetUI(){
        profileImageView.image = nil
        profileNameLabel.text = ""
        postDateLabel.text = ""
        textView.text = ""
        likeNumberLabel.text = ""
        newsfeedFollowButton.setImage(nil, forState: .Normal)
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
        delegate?.didTapNewsfeedFollowButton?(self)
    }
    
    func tapProfile(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            delegate?.didTapPostProfile?(self)
        }
    }
    
    @IBAction func tapLikeButton(sender: UIButton) {
        delegate?.didTapLikeButton?(self)
    }

    @IBAction func tapShareButton(sender: UIButton) {
        delegate?.didTapShareButton?(self)
    }
}
