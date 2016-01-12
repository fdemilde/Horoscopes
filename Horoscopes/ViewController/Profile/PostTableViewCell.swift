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
    
    @IBOutlet weak var locationLabel: UILabel!
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
    
    var alreadyAddCircle = false
    
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
        // should add circle here so it renders at right position
        if profileImageView != nil {
            if (alreadyAddCircle == false){
                let centerPoint = CGPoint(x: profileImageView.frame.origin.x + profileImageView.frame.size.width/2, y: profileImageView.frame.origin.y + profileImageView.frame.height/2)
                let radius = profileImageView.frame.size.width/2 + 5
                let circleLayer = Utilities.layerForCircle(centerPoint, radius: radius, lineWidth: 1)
                circleLayer.fillColor = UIColor.clearColor().CGColor
                let color = UIColor(red: 227, green: 223, blue: 246, alpha: 1)
                circleLayer.strokeColor = color.CGColor
                profileView.layer.addSublayer(circleLayer)
            }
        }
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
        dispatch_async(dispatch_get_main_queue(), {
            self.post = post
            self.postTypeImageView.image = UIImage(named: postTypes[post.type]!.0)
            if let type = postTypes[post.type] {
                self.postTypeLabel.text = type.1
            }
            self.postDateLabel.text = Utilities.getTimeAgoString(post.ts)
            let string = "\(post.message)"
            let stringWithWebLink = Utilities.getTextWithWeblink(string, isTruncated: post.truncated == 1)
            let att = stringWithWebLink
            let linkAttributes = [NSForegroundColorAttributeName: UIColor(red: 133.0/255.0, green: 124.0/255.0, blue: 173.0/255.0, alpha: 1),
                NSUnderlineStyleAttributeName: 1
            ]
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            att.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, att.string.characters.count))
            self.textView!.linkTextAttributes = linkAttributes
            self.textView.attributedText = att
            
//            self.likeNumberLabel.text = "\(post.hearts) Likes  \(post.shares) Shares"
            self.likeNumberLabel.text = "\(post.hearts) Likes"
            if NSUserDefaults.standardUserDefaults().boolForKey(String(post.post_id)) {
                self.likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), forState: .Normal)
                self.likeButton.userInteractionEnabled = false
            } else {
                self.likeButton.setImage(UIImage(named: "newsfeed_heart_icon"), forState: .Normal)
                self.likeButton.userInteractionEnabled = true
            }
            
            
            let likeLabelTapRecognizer = UITapGestureRecognizer(target: self, action: "tapLikeLable:")
            self.likeNumberLabel.userInteractionEnabled = true
            self.likeNumberLabel.addGestureRecognizer(likeLabelTapRecognizer)
        })
    }
    
    func configureCellForNewsfeed(post: UserPost) {
        dispatch_async(dispatch_get_main_queue(),{
            self.configureNewsfeedUi()
            self.configureCell(post)
            self.horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: (post.user?.sign)!)
            self.horoscopeSignImageView.image = Utilities.horoscopeSignIconImage(fromSignNumber: (post.user?.sign)!)
            Utilities.getImageFromUrlString(post.user!.imgURL, completionHandler: { (image) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.profileImageView.image = image
                })
            })
            self.locationLabel.text = post.user?.location
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
            
            let nameGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
            self.profileNameLabel.userInteractionEnabled = true
            self.profileNameLabel.addGestureRecognizer(nameGestureRecognizer)
            
            let nameGestureRecognizer2 = UITapGestureRecognizer(target: self, action: "tapProfile:")
            self.locationLabel.userInteractionEnabled = true
            self.locationLabel.addGestureRecognizer(nameGestureRecognizer2)
            
            let nameGestureRecognizer3 = UITapGestureRecognizer(target: self, action: "tapProfile:")
            self.horoscopeSignView.userInteractionEnabled = true
            self.horoscopeSignView.addGestureRecognizer(nameGestureRecognizer3)
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
                Utilities.showAlert(viewController, title: "Action Denied", message: "Please login via Facebook to perform this action", error: nil)
            }
        }
    }
    
    @IBAction func tapLikeButton(sender: UIButton) {
        if(!XAppDelegate.socialManager.isLoggedInFacebook()){
            Utilities.showAlertView(self, title: "", message: "Please login via Facebook to perform this action", tag: 1)
            return
        }
        let label = "type = post, like = 1, info = \(post.post_id)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.like, label: label)
        self.likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), forState: .Normal)
        self.likeButton.userInteractionEnabled = false
//        self.likeNumberLabel.text = "\(++post.hearts) Likes  \(post.shares) Shares"
        self.likeNumberLabel.text = "\(++post.hearts) Likes"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendHeartSuccessful:", name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        XAppDelegate.socialManager.sendHeart(post.uid, postId: post.post_id, type: SEND_HEART_USER_POST_TYPE)
    }

    @IBAction func tapShareButton(sender: UIButton) {
        let name = post.user?.name
        let postContent = post.message
        let sharingText = String(format: "%@ \n %@", name!, postContent)
        let controller = Utilities.getShareViewController()
        controller.populateNewsfeedShareData(post.post_id, viewType: ShareViewType.ShareViewTypeHybrid, sharingText: sharingText, pictureURL: "", shareUrl: post.permalink)
        Utilities.presentShareFormSheetController(viewController, shareViewController: controller)
    }
    
    func tapLikeLable(sender: UITapGestureRecognizer){
        if sender.state == .Ended {
            
                if SocialManager.sharedInstance.isLoggedInFacebook() {
                    let postId = self.post.post_id
                    SocialManager.sharedInstance.retrieveUsersWhoLikedPost(postId, page: 0) { (result, error) -> Void in
                        if(error != ""){
                            Utilities.showAlert(self.viewController, title: "Action Denied", message: "\(error)", error: nil)
                        } else {
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyBoard.instantiateViewControllerWithIdentifier("LikeDetailTableViewController") as! LikeDetailTableViewController
                            viewController.postId = postId
                            viewController.userProfile = result!.0
                            viewController.parentVC = self.viewController
                            viewController.numberOfLike = self.post.hearts
                            self.displayViewController(viewController)
                        }
                    }
                } else {
                    Utilities.showAlert(self.viewController, title: "Action Denied", message: "Please login via Facebook to perform this action", error: nil)
                }
            
        }
    }
    
    //     Notification handler
    func sendHeartSuccessful(notif: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        post.hearts++
    }
    
    // MARK: link textview Delegate
    func linkTextView(linkTextView: CCHLinkTextView!, didTapLinkWithValue value: AnyObject!) {
        let urlString = value as! String
        Utilities.showHUD()
        XAppDelegate.socialManager.getPost(post.post_id,ignoreCache: true, completionHandler: { (result, error) -> Void in
            Utilities.hideHUD()
            if let _ = error {
                
            } else {
                if(urlString == "readmore"){
                    if let result = result {
                        for post : UserPost in result {
                            let controller = self.viewController.storyboard?.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
                            controller.userPost = post
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.viewController.navigationController?.pushViewController(controller, animated: true)
                            })
                        }
                    }
                } else {
                    print("urlString urlString = \(urlString)")
                    if let url = NSURL(string: urlString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                    
                }
                
            }
        })
    }
    
    // MARK: display View controller
    func displayViewController(viewController : UIViewController){
        dispatch_async(dispatch_get_main_queue()) {
        let paddingTop = (DeviceType.IS_IPHONE_4_OR_LESS) ? 50 : 70 as CGFloat
        let formSheet = MZFormSheetController(viewController: viewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.Fade
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.portraitTopInset = paddingTop;
            formSheet.presentedFormSheetSize = CGSizeMake(Utilities.getScreenSize().width - 20, Utilities.getScreenSize().height - paddingTop * 2)
        self.viewController.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
        }
    }
}

