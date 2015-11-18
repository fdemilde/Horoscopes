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
    @IBOutlet weak var postTypeLabel: UILabel!
    
    @IBOutlet weak var headerBackgroundImage: UIImageView!
    var viewController: UIViewController!
    var post: UserPost!
    var isPostInProfileTab = false
    
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
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    
    
    // MARK: - Property
    let profileImageSize: CGFloat = 60
    let minimumTextViewHeight = UIScreen.mainScreen().bounds.height - TABBAR_HEIGHT - ADMOD_HEIGHT - 50 - 350
    var heightConstraint: NSLayoutConstraint!
    var horoscopeSignImageViewLeadingSpaceConstant: CGFloat = 10
    var horoscopeSignImageViewWidthConstant: CGFloat = 18
    var horoscopeSignImageViewTrailingSpaceConstant: CGFloat = 5
    var horoscopeSignLabelTrailingSpaceConstant: CGFloat = 10
    let postTypes = [
        NewsfeedType.Feeling: ("post_type_feel", "How do you feel today?"),
        NewsfeedType.Story: ("post_type_story", "Share your story"),
        NewsfeedType.OnYourMind: ("post_type_mind", "What's on your mind?")
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        textView.linkDelegate = self
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if isPostInProfileTab {
            configurePostUi()
        }
    }
    
    // MARK: BINH BINH, need to reset all UI before populating to prevent wrong UI from reusing cell
    func resetUI(){
        dispatch_async(dispatch_get_main_queue(), {
            self.profileImageView.image = nil
            self.profileNameLabel.text = ""
            self.textView.text = ""
            self.postDateLabel.text = ""
            self.likeNumberLabel.text = ""
        })
    }
    
    private func configureCell(post: UserPost) {
        self.post = post
        postTypeImageView.image = UIImage(named: postTypes[post.type]!.0)
        if let type = postTypes[post.type] {
            postTypeLabel.text = type.1
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
        if NSUserDefaults.standardUserDefaults().boolForKey(String(post.post_id)) {
            likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), forState: .Normal)
        } else {
            likeButton.setImage(UIImage(named: "newsfeed_heart_icon"), forState: .Normal)
        }
    }
    
    func configureCellForNewsfeed(post: UserPost) {
        dispatch_async(dispatch_get_main_queue(),{
            self.configureNewsfeedUi()
            self.configureCell(post)
            self.horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: (post.user?.sign)!)
            self.horoscopeSignImageView.image = Utilities.horoscopeSignImage(fromSignNumber: (post.user?.sign)!)
            Utilities.getImageFromUrlString(post.user!.imgURL, completionHandler: { (image) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.profileImageView.image = image
                })
            })
            self.profileNameLabel.text = post.user?.name
        })
    }
    
    func configureCellForProfile(post: UserPost) {
        isPostInProfileTab = true
        configureCell(post)
    }
    
    private func configurePostUi() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: containerView.bounds, byRoundingCorners: UIRectCorner.BottomLeft.union(.BottomRight), cornerRadii: CGSize(width: 4, height: 4)).CGPath
        containerView.layer.mask = maskLayer
    }
    
    func configureNewsfeedUi() {
        dispatch_async(dispatch_get_main_queue(), {
            self.headerBackgroundImage = Utilities.makeCornerRadius(self.headerBackgroundImage, maskFrame: self.headerBackgroundImage.bounds, roundOptions: [.TopLeft , .TopRight], radius: 4) as! UIImageView
            self.actionView = Utilities.makeCornerRadius(self.actionView, maskFrame: self.actionView.bounds, roundOptions: [.BottomLeft , .BottomRight], radius: 4)
            self.horoscopeSignView.layer.cornerRadius = 4
            self.horoscopeSignView.clipsToBounds = true
            
            self.profileImageView.layer.cornerRadius = self.profileImageSize / 2
            self.profileImageView.clipsToBounds = true
            
            
            let centerPoint = CGPoint(x: self.profileImageView.frame.origin.x + self.profileImageView.frame.size.width/2, y: self.profileImageView.frame.origin.y + self.profileImageView.frame.height/2)
            let radius = self.profileImageView.frame.size.width/2 + 5
            let circleLayer = Utilities.layerForCircle(centerPoint, radius: radius, lineWidth: 1)
            circleLayer.fillColor = UIColor.clearColor().CGColor
            let color = UIColor(red: 227, green: 223, blue: 246, alpha: 1)
            circleLayer.strokeColor = color.CGColor
            self.profileView.layer.addSublayer(circleLayer)
            
            let nameGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
            let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
            self.profileNameLabel.userInteractionEnabled = true
            self.profileNameLabel.addGestureRecognizer(nameGestureRecognizer)
            self.profileImageView.userInteractionEnabled = true
            self.profileImageView.addGestureRecognizer(imageGestureRecognizer)
        })
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
        XAppDelegate.socialManager.getPost(post.post_id,ignoreCache: true, completionHandler: { (result, error) -> Void in
            Utilities.hideHUD()
            if let _ = error {
                
            } else {
                if let result = result {
                    for post : UserPost in result {
                        let controller = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
                        controller.userPost = post
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.viewController.navigationController?.pushViewController(controller, animated: true)
                        })
                    }
                }
            }
        })
    }
}

