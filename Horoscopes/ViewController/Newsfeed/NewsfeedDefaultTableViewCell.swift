//
//  NewsfeedDefaultTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/24/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewsfeedDefaultTableViewCell: UITableViewCell {
    
    let imageViewMargin: CGFloat = 3
    let textLabelLeadingSpace: CGFloat = 13
    let viewMargin: CGFloat = 10
    var containerView: UIView!
    var postTextLabel: UILabel!
    var profileImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .None
        backgroundColor = UIColor.clearColor()
        
        containerView = UIView()
        containerView.backgroundColor = UIColor(white: 0, alpha: 0.25)
        addSubview(containerView)
        
        postTextLabel = UILabel()
        postTextLabel.text = "What's on your mind?"
        if #available(iOS 8.2, *) {
            postTextLabel.font = UIFont.systemFontOfSize(11, weight: UIFontWeightLight)
        } else {
            postTextLabel.font = UIFont.systemFontOfSize(11)
        }
        postTextLabel.textColor = UIColor(white: 1, alpha: 0.5)
        containerView.addSubview(postTextLabel)
        postTextLabel.sizeToFit()
        
        profileImageView = UIImageView(image: UIImage(named: "default_avatar"))
        profileImageView.clipsToBounds = true
        containerView.addSubview(profileImageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.frame = CGRect(x: 0, y: viewMargin, width: frame.width, height: frame.height - 2 * viewMargin)
        containerView.layer.cornerRadius = containerView.frame.height / 2
        profileImageView.frame = CGRect(x: imageViewMargin, y: imageViewMargin, width: containerView.frame.height - 2 * imageViewMargin, height: containerView.frame.height - 2 * imageViewMargin)
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        postTextLabel.frame.origin = CGPoint(x: profileImageView.frame.origin.x + profileImageView.frame.width + textLabelLeadingSpace, y: (containerView.frame.height - postTextLabel.frame.height) / 2)
    }

}
