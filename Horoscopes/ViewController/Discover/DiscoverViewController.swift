//
//  DiscoverViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 11/12/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation

class DiscoverViewController : ViewControllerWithAds {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var postTypeLabel: UILabel!
    @IBOutlet weak var horoscopeSignView: UIView!
    @IBOutlet weak var horoscopeImageView: UIImageView!
    @IBOutlet weak var horoscopeLabel: UILabel!
    
    let scrollViewInset: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentInset = UIEdgeInsets(top: scrollViewInset, left: scrollViewInset, bottom: scrollViewInset, right: scrollViewInset)
        containerViewWidthConstraint.constant = UIScreen.mainScreen().bounds.width - 2 * scrollViewInset
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
        scrollView.backgroundColor = UIColor(red: 98/255, green: 98/255, blue: 145/255, alpha: 1)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        textViewHeightConstraint.constant = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.max)).height
    }
}
