//
//  PostTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell, UIAlertViewDelegate, CCHLinkTextViewDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var postTypeShadowUpper: UIView!
    @IBOutlet weak var postTypeShadowLower: UIView!
    
    @IBOutlet weak var postTypeImageView: UIImageView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var textView: CCHLinkTextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var actionView: UIView!
    var viewController: UIViewController!
    var post: UserPost!
    
    // MARK: - Newsfeed outlet
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var horoscopeSignView: UIView!
    @IBOutlet weak var horoscopeSignImageView: UIImageView!
    @IBOutlet weak var horoscopeSignLabel: UILabel!
    @IBOutlet weak var newsfeedFollowButton: UIButton!
    
    // MARK: - Newsfeed constraint
    
    @IBOutlet weak var horoscopeSignImageViewLeadingSpaceLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var horoscopeSignImageViewWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var horoscopeSignImageViewTrailingSpaceLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var horoscopeSignLabelTrailingSpaceLayoutConstraint: NSLayoutConstraint!
    
    
    // MARK: - Property
    let profileImageSize: CGFloat = 80
    var postTypeLabel: UILabel!
    var topBorder: CALayer!
    let minimumTextViewHeight = UIScreen.mainScreen().bounds.height - TABBAR_HEIGHT - ADMOD_HEIGHT - 50 - 350
    var heightConstraint: NSLayoutConstraint!
    var horoscopeSignImageViewLeadingSpaceConstant: CGFloat = 10
    var horoscopeSignImageViewWidthConstant: CGFloat = 18
    var horoscopeSignImageViewTrailingSpaceConstant: CGFloat = 5
    var horoscopeSignLabelTrailingSpaceConstant: CGFloat = 10
    let postTypeTexts = [
        "How do you feel today?",
        "Share your story",
        "What's on your mind?"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.linkDelegate = self
        containerView.layer.cornerRadius = 4
        containerView.clipsToBounds = true
        postTypeLabel = UILabel()
        postTypeLabel.textColor = UIColor.whiteColor()
        if #available(iOS 8.2, *) {
            postTypeLabel.font = UIFont.systemFontOfSize(11, weight: UIFontWeightLight)
        } else {
            // Fallback on earlier versions
            postTypeLabel.font = UIFont.systemFontOfSize(11)
        }
        addSubview(postTypeLabel)
        topBorder = CALayer()
        topBorder.backgroundColor = UIColor(red: 216/255, green: 216/255, blue: 216/255, alpha: 1).CGColor
        actionView.layer.addSublayer(topBorder)
        for subview in subviews {
            for constraint in subview.constraints {
                if constraint.identifier == "textViewHeight" {
                    constraint.constant = minimumTextViewHeight
                }
            }
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
        dispatch_async(dispatch_get_main_queue(), {
            self.profileImageView.image = nil
            self.profileNameLabel.text = ""
            self.textView.text = ""
            self.postDateLabel.text = ""
            self.likeNumberLabel.text = ""
            self.newsfeedFollowButton.setImage(nil, forState: .Normal)
        })
    }
    
    func configureCell(post: UserPost) {
        self.post = post
        switch post.type {
        case .OnYourMind:
            postTypeImageView.image = UIImage(named: "post_type_mind")
        case .Feeling:
            postTypeImageView.image = UIImage(named: "post_type_feel")
        case .Story:
            postTypeImageView.image = UIImage(named: "post_type_story")
        }
        postDateLabel.text = Utilities.getDateStringFromTimestamp(NSTimeInterval(post.ts), dateFormat: postDateFormat)
        var string = "\(post.message)"
        let font = UIFont(name: "Book Antiqua", size: 15)
        
        
        if(post.truncated == 1){
            string = "\(post.message)... Read more"
            
        }
        let text = NSMutableAttributedString(string: "\(string)")
        let att = text.mutableCopy()
        
        if(post.truncated == 1){
            att.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, string.characters.count - 9))
            att.addAttribute(CCHLinkAttributeName, value: "Read more", range: NSMakeRange(string.characters.count - 9, 9))
            att.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(11), range: NSMakeRange(string.characters.count - 9, 9))
            let linkAttributes = [NSForegroundColorAttributeName: UIColor(red: 133.0/255.0, green: 124.0/255.0, blue: 173.0/255.0, alpha: 1),
                NSUnderlineStyleAttributeName: 1
            ]
            
            textView!.linkTextAttributes = linkAttributes
        } else {
            att.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, string.characters.count))
        }
        
        textView.attributedText = att as! NSAttributedString
        likeNumberLabel.text = "\(post.hearts) Likes  \(post.shares) Shares"
    }
    
    func configureCellForNewsfeed(post: UserPost) {
        configureNewsfeedUi()
        configureCell(post)
        horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: (post.user?.sign)!)
        horoscopeSignImageView.image = Utilities.horoscopeSignImage(fromSignNumber: (post.user?.sign)!)
        Utilities.getImageFromUrlString(post.user!.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.profileImageView.image = image
            })
        })
        profileNameLabel.text = post.user?.name
        if NSUserDefaults.standardUserDefaults().boolForKey(String(post.post_id)) {
            likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), forState: .Normal)
        } else {
            likeButton.setImage(UIImage(named: "newsfeed_heart_icon"), forState: .Normal)
        }
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            if post.uid != XAppDelegate.currentUser.uid {
                newsfeedFollowButton.userInteractionEnabled = true
                if post.user!.isFollowed {
                    newsfeedFollowButton.setImage(UIImage(named: "newsfeed_followed_btn"), forState: .Normal)
                } else {
                    newsfeedFollowButton.setImage(UIImage(named: "newsfeed_follow_btn"), forState: .Normal)
                }
            } else {
                newsfeedFollowButton.userInteractionEnabled = false
            }
        } else {
            newsfeedFollowButton.userInteractionEnabled = false
        }
    }
    
    func configureCellForProfile(post: UserPost) {
        configureUserPostUi()
        configureCell(post)
    }
    
    func configureNewsfeedUi() {
        dispatch_async(dispatch_get_main_queue(), {
            self.horoscopeSignView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
            self.horoscopeSignView.layer.cornerRadius = 4
            self.horoscopeSignView.clipsToBounds = true
            self.profileImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
            self.profileImageView.layer.shadowOpacity = 0.6
            self.profileImageView.layer.shadowRadius = 2
            self.profileImageView.clipsToBounds = false
            self.headerView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
            self.profileImageView.layer.cornerRadius = self.profileImageSize / 2
            self.profileImageView.clipsToBounds = true
            
            let nameGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
            let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
            self.profileNameLabel.userInteractionEnabled = true
            self.profileNameLabel.addGestureRecognizer(nameGestureRecognizer)
            self.profileImageView.userInteractionEnabled = true
            self.profileImageView.addGestureRecognizer(imageGestureRecognizer)
            switch self.post.type {
                case .OnYourMind:
                    self.profileView.backgroundColor = UIColor.newsfeedMindColor()
                case .Feeling:
                    self.profileView.backgroundColor = UIColor.newsfeedFeelColor()
                case .Story:
                    self.profileView.backgroundColor = UIColor.newsfeedStoryColor()
            }
        })
    }
    
    func configureUserPostUi() {
        likeButton.hidden = true
    }
    
    func changeHoroscopeSignViewWidthToZero() {
        horoscopeSignImageViewLeadingSpaceLayoutConstraint.constant = 0
        horoscopeSignImageViewWidthLayoutConstraint.constant = 0
        horoscopeSignImageViewTrailingSpaceLayoutConstraint.constant = 0
        horoscopeSignLabelTrailingSpaceLayoutConstraint.constant = 0
    }
    
    func changeHoroscopeSignViewWidthToDefault() {
        horoscopeSignImageViewLeadingSpaceLayoutConstraint.constant = horoscopeSignImageViewLeadingSpaceConstant
        horoscopeSignImageViewWidthLayoutConstraint.constant = horoscopeSignImageViewWidthConstant
        horoscopeSignImageViewTrailingSpaceLayoutConstraint.constant = horoscopeSignImageViewTrailingSpaceConstant
        horoscopeSignLabelTrailingSpaceLayoutConstraint.constant = horoscopeSignLabelTrailingSpaceConstant
    }
    
    @IBAction func tapNewsfeedFollowButton(sender: UIButton) {
//        viewController = viewController as! NewsfeedViewController
        let hud = MBProgressHUD.showHUDAddedTo(viewController.view, animated: true)
        SocialManager.sharedInstance.isFollowing(post.uid, followerId: XAppDelegate.currentUser.uid) { (result, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    hud.hide(true)
                })
                Utilities.showError(error, viewController: self.viewController)
            } else {
                let isFollowing = result!["isfollowing"] as! Int == 1
                hud.detailsLabelFont = UIFont.systemFontOfSize(11)
                let name = self.post.user!.name
                if isFollowing {
                    SocialManager.sharedInstance.unfollow(self.post.user!, completionHandler: { (error) -> Void in
                        hud.mode = MBProgressHUDMode.Text
                        if let _ = error {
                            hud.detailsLabelText = "Unfollow unsuccessully due to network error!"
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                hud.hide(true, afterDelay: 2)
                            })
                        } else {
                            hud.detailsLabelText = "\(name) has been removed from your Following list."
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                let parentVC = self.viewController as! NewsfeedViewController
                                parentVC.tableView.reloadData()
                                hud.hide(true, afterDelay: 2)
                            })
                        }
                    })
                } else {
                    SocialManager.sharedInstance.follow(self.post.user!, completionHandler: { (error) -> Void in
                        hud.mode = MBProgressHUDMode.Text
                        if let _ = error {
                            hud.detailsLabelText = "Follow unsuccessully due to network error!"
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                hud.hide(true, afterDelay: 2)
                            })
                        } else {
                            hud.detailsLabelText = "\(name) has been added to your Following list."
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                                let parentVC = self.viewController as! NewsfeedViewController
//                                parentVC.tableView.reloadData()
                                hud.hide(true, afterDelay: 2)
                            })
                        }
                    })
                }
            }
        }
    }
    
    func tapProfile(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            if SocialManager.sharedInstance.isLoggedInFacebook() {
                let profile = post.user
                let controller = viewController.storyboard?.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
                controller.userProfile = profile!
                viewController.navigationController?.pushViewController(controller, animated: true)
            } else {
                Utilities.showAlert(viewController, title: "Action Denied", message: "You have to login to Facebook to view profile!", error: nil)
            }
        }
    }
    
    @IBAction func tapLikeButton(sender: UIButton) {
        if(!XAppDelegate.socialManager.isLoggedInFacebook()){
            Utilities.showAlertView(self, title: "", message: "Must Login facebook to send heart", tag: 1)
            return
        }
        self.likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), forState: .Normal)
        self.likeButton.userInteractionEnabled = false
        self.likeNumberLabel.text = "\(++post.hearts) Likes  \(post.shares) Shares"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendHeartSuccessful:", name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        XAppDelegate.socialManager.sendHeart(post.uid, postId: post.post_id, type: SEND_HEART_USER_POST_TYPE)
    }

    @IBAction func tapShareButton(sender: UIButton) {
        let name = post.user?.name
        let postContent = post.message
        let sharingText = String(format: "%@ \n %@", name!, postContent)
        let controller = Utilities.shareViewControllerForType(ShareViewType.ShareViewTypeHybrid, shareType: ShareType.ShareTypeNewsfeed, sharingText: sharingText)
        Utilities.presentShareFormSheetController(viewController, shareViewController: controller)
    }
    
    //     Notification handler
    func sendHeartSuccessful(notif: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        post.hearts++
    }
    
    // MARK: link textview Delegate
    func linkTextView(linkTextView: CCHLinkTextView!, didTapLinkWithValue value: AnyObject!) {
        print("Tapped to link = \(value)")
        Utilities.showHUD()
        XAppDelegate.socialManager.getPost(post.post_id, completionHandler: { (result, error) -> Void in
            Utilities.hideHUD()
            if let _ = error {
                
            } else {
                if let result = result {
                    for post : UserPost in result {
                        let controller = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
                        controller.userPost = post
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            viewController.navigationController?.pushViewController(controller, animated: true)
                        })
                    }
                }
            }
        })
    }
}

