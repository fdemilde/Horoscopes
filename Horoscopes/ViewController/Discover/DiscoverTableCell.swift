//
//  DiscoverTableCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 11/20/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class DiscoverTableCell : UITableViewCell, CCHLinkTextViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var signImage: UIImageView!
    @IBOutlet weak var signName: UILabel!
    @IBOutlet weak var postTypeImage: UIImageView!
    @IBOutlet weak var postTypeLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var horoscopeSignView: UIView!
    @IBOutlet weak var textView: CCHLinkTextView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    
    
    var parentViewController : UIViewController!
    let profileImageSize = 60 as CGFloat
    
    var userPost : UserPost!
    var alreadyAddCircle = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView.linkDelegate = self
        
    }
    
    func setupCell(userPost : UserPost){
        self.userPost = userPost
        dispatch_async(dispatch_get_main_queue(), {
            self.containerView.layer.cornerRadius = 4
            self.containerView.clipsToBounds = true
            self.horoscopeSignView.layer.cornerRadius = 4
            self.horoscopeSignView.clipsToBounds = true
            
            self.profileImage.layer.cornerRadius = self.profileImageSize / 2
            self.profileImage.clipsToBounds = true
            self.populateUI()
        })
    }
    
    func populateUI(){
        Utilities.getImageFromUrlString(userPost.user!.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.profileImage.image = image
            })
        })
        if (alreadyAddCircle == false){
            // create a circle
            let centerPoint = CGPoint(x: self.profileImage.frame.origin.x + self.profileImage.frame.size.width/2, y: self.profileImage.frame.origin.y + self.profileImage.frame.height/2)
            let radius = self.profileImage.frame.size.width/2 + 5
            let circleLayer = Utilities.layerForCircle(centerPoint, radius: radius, lineWidth: 1)
            circleLayer.fillColor = UIColor.clearColor().CGColor
            let color = UIColor(red: 227, green: 223, blue: 246, alpha: 1)
            circleLayer.strokeColor = color.CGColor
            self.profileView.layer.addSublayer(circleLayer)
            alreadyAddCircle = true
        }
        
        
        self.name.text = self.userPost.user!.name
        self.location.text = self.userPost.user!.location
        if(self.userPost.user?.sign == -1){
            self.signImage.hidden = true
            self.signName.hidden = true
            horoscopeSignView.hidden = true
        } else {
            self.signImage.hidden = false
            self.signName.hidden = false
            horoscopeSignView.hidden = false
            self.signName.text = Utilities.horoscopeSignString(fromSignNumber: (self.userPost.user?.sign)!)
            self.signImage.image = Utilities.horoscopeSignIconImage(fromSignNumber: (self.userPost.user?.sign)!)
        }
        self.postTypeImage.image = UIImage(named: postTypes[userPost.type]!.0)
        if let type = postTypes[userPost.type] {
            self.postTypeLabel.text = type.1
        }
        self.timeAgoLabel.text = Utilities.getTimeAgoString(userPost.ts)
        let string = "\(userPost.message)"
        let stringWithWebLink = Utilities.getTextWithWeblink(string, isTruncated: userPost.truncated == 1)
        let att = stringWithWebLink
        let linkAttributes = [NSForegroundColorAttributeName: UIColor(red: 133.0/255.0, green: 124.0/255.0, blue: 173.0/255.0, alpha: 1),
            NSUnderlineStyleAttributeName: 1
        ]
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        att.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, att.string.characters.count))
        self.textView!.linkTextAttributes = linkAttributes
        self.textView.attributedText = att
        
        let nameGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapProfile:")
        self.profileImage.userInteractionEnabled = true
        self.profileImage.addGestureRecognizer(nameGestureRecognizer)
        
        let nameGestureRecognizer2 = UITapGestureRecognizer(target: self, action: "tapProfile:")
        self.location.userInteractionEnabled = true
        self.location.addGestureRecognizer(nameGestureRecognizer2)
        
        let nameGestureRecognizer3 = UITapGestureRecognizer(target: self, action: "tapProfile:")
        self.horoscopeSignView.userInteractionEnabled = true
        self.horoscopeSignView.addGestureRecognizer(nameGestureRecognizer3)
        
        let nameGestureRecognizer4 = UITapGestureRecognizer(target: self, action: "tapProfile:")
        self.name.userInteractionEnabled = true
        self.name.addGestureRecognizer(nameGestureRecognizer4)
    }
    
    func configureFollowButton(isFollowed: Bool) {
        if let currentUser = XAppDelegate.currentUser {
            if(currentUser.uid == userPost.uid){
                followButton.hidden = true
                return
            }
        }
        followButton.hidden = false
        if isFollowed {
            followButton.setImage(UIImage(named: "discover_follow_button_check"), forState: .Normal)
        } else {
            followButton.setImage(UIImage(named: "discover_follow_button"), forState: .Normal)
        }
    }
    
    func configureCellForNewsfeed() {
//        self.likeNumberLabel.text = "\(userPost.hearts) Likes  \(userPost.shares) Shares"
        self.likeNumberLabel.text = "\(userPost.hearts) Likes"
        if NSUserDefaults.standardUserDefaults().boolForKey(String(userPost.post_id)) {
            self.likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), forState: .Normal)
            self.likeButton.userInteractionEnabled = false
        } else {
            self.likeButton.setImage(UIImage(named: "newsfeed_heart_icon"), forState: .Normal)
            self.likeButton.userInteractionEnabled = true
        }
        
        
        let likeLabelTapRecognizer = UITapGestureRecognizer(target: self, action: "tapLikeLable:")
        self.likeNumberLabel.userInteractionEnabled = true
        self.likeNumberLabel.addGestureRecognizer(likeLabelTapRecognizer)
    }
    
    // MARK: Button action
    
    @IBAction func tapLikeButton(sender: UIButton) {
        if(!XAppDelegate.socialManager.isLoggedInFacebook()){
            Utilities.showAlertView(self, title: "", message: "Please login via Facebook to perform this action", tag: 1)
            return
        }
        let label = "type = post, like = 1, info = \(userPost.post_id)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.like, label: label)
        self.likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), forState: .Normal)
        self.likeButton.userInteractionEnabled = false
//        self.likeNumberLabel.text = "\(++userPost.hearts) Likes  \(userPost.shares) Shares"
        self.likeNumberLabel.text = "\(++userPost.hearts) Likes"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sendHeartSuccessful:", name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        XAppDelegate.socialManager.sendHeart(userPost.uid, postId: userPost.post_id, type: SEND_HEART_USER_POST_TYPE)
    }
    
    @IBAction func tapShareButton(sender: UIButton) {
        let name = userPost.user?.name
        let postContent = userPost.message
        let sharingText = String(format: "%@ \n %@", name!, postContent)
        let controller = Utilities.shareViewControllerForType(ShareViewType.ShareViewTypeHybrid, shareType: ShareType.ShareTypeNewsfeed, sharingText: sharingText)
        controller.populateNewsfeedShareData(userPost.post_id, viewType: ShareViewType.ShareViewTypeHybrid, sharingText: sharingText, pictureURL: "", shareUrl: userPost.permalink)
        Utilities.presentShareFormSheetController(self.parentViewController, shareViewController: controller)
    }
    
    func tapLikeLable(sender: UITapGestureRecognizer){
        if sender.state == .Ended {
            
            if SocialManager.sharedInstance.isLoggedInFacebook() {
                let postId = self.userPost.post_id
                SocialManager.sharedInstance.retrieveUsersWhoLikedPost(postId, page: 0) { (result, error) -> Void in
                    if(error != ""){
                        Utilities.showAlert(self.parentViewController, title: "\(self.userPost.hearts) likes", message: "", error: nil)
                    } else {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let viewController = storyBoard.instantiateViewControllerWithIdentifier("LikeDetailTableViewController") as! LikeDetailTableViewController
                        viewController.postId = postId
                        viewController.userProfile = result!.0
                        viewController.parentVC = self.parentViewController
                        self.displayViewController(viewController)
                    }
                }
            } else {
                Utilities.showAlert(self.parentViewController, title: "Action Denied", message: "Please login via Facebook to perform this action", error: nil)
            }
            
        }
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
            self.parentViewController.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
        }
    }
    // MARK: link textview Delegate
    func linkTextView(linkTextView: CCHLinkTextView!, didTapLinkWithValue value: AnyObject!) {
        let urlString = value as! String
        
        if(urlString == "readmore"){
            XAppDelegate.socialManager.getPost(userPost.post_id,ignoreCache: true, completionHandler: { (result, error) -> Void in
                Utilities.hideHUD()
                if let _ = error {
                    
                } else {
                    
                    if let result = result {
                        for post : UserPost in result {
                            let controller = self.parentViewController.storyboard?.instantiateViewControllerWithIdentifier("SinglePostViewController") as! SinglePostViewController
                            controller.userPost = post
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.parentViewController.navigationController?.pushViewController(controller, animated: true)
                            })
                        }
                    }
                }
            })
        } else {
            print("urlString urlString = \(urlString)")
            if let url = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func tapProfile(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            if SocialManager.sharedInstance.isLoggedInFacebook() {
                let profile = userPost.user
                let controller = parentViewController.storyboard?.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
                controller.userProfile = profile!
                parentViewController.navigationController?.pushViewController(controller, animated: true)
            } else {
                Utilities.showAlert(parentViewController, title: "Action Denied", message: "Please login via Facebook to perform this action", error: nil)
            }
        }
    }
    
    //     Notification handler
    func sendHeartSuccessful(notif: NSNotification){
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NOTIFICATION_SEND_HEART_FINISHED, object: nil)
        userPost.hearts++
    }
}
