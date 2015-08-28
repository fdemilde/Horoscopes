//
//  ProfilePostTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

protocol ProfilePostTableViewCellDelegate {
    func didTapShareButton(profileName: String?, postContent: String)
}

class ProfilePostTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    var delegate: ProfilePostTableViewCellDelegate!
    
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
    
    @IBAction func tapLikeButton(sender: UIButton) {
    }

    @IBAction func tapShareButton(sender: UIButton) {
        delegate.didTapShareButton(nil, postContent: textView.text)
    }
}
