//
//  PostTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class PostTableViewCell: UITableViewCell, UIAlertViewDelegate, CCHLinkTextViewDelegate, LoginViewControllerDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var numberOfCommentsView: UIView!
    
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
    
    @IBOutlet weak var btnDownArrow: UIButton!
    
    @IBOutlet weak var viewContentFade: UIView!
    @IBOutlet weak var viewOptions: UIView!
    @IBOutlet weak var imgDropdownTopTriangle: UIImageView!
    
    @IBOutlet weak var lblNumberOfComments: UILabel!
    
    @IBOutlet weak var lblNumberOfCommentsWidth: NSLayoutConstraint!
    
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
    
    @IBOutlet weak var fakeReadmoreLabel: UILabel?
    
    var profilePicturePlaceholder: UIImage!
    
    // MARK: - Property
    let profileImageSize: CGFloat = 60
    let minimumTextViewHeight = UIScreen.main.bounds.height - TABBAR_HEIGHT - ADMOD_HEIGHT - 50 - 350
    var heightConstraint: NSLayoutConstraint!
    var horoscopeSignImageViewLeadingSpaceConstant: CGFloat = 10
    var horoscopeSignImageViewWidthConstant: CGFloat = 18
    var horoscopeSignImageViewTrailingSpaceConstant: CGFloat = 5
    var horoscopeSignLabelTrailingSpaceConstant: CGFloat = 10
    
    var alreadyAddCircle = false
    
    //MARK: Option View
    
    @IBOutlet weak var btnEditPost: UIButton!
    @IBOutlet weak var viewViewOptionLine: UIView!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var viewViewOptionHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.numberOfCommentsView.layer.cornerRadius = self.numberOfCommentsView.layer.frame.height/2
        self.viewOptions.layer.cornerRadius = 4
        textView.linkDelegate = self
        profilePicturePlaceholder = UIImage(named: "default_avatar")
        self.hideOptions()
        
        guard let viewContentFade = viewContentFade else { return }
        let selector: Selector = #selector(hideOptions)
        let tapGesture = UITapGestureRecognizer(target: self, action: selector)
        tapGesture.numberOfTapsRequired = 1
        viewContentFade.addGestureRecognizer(tapGesture)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // should add circle here so it renders at right position
        if profileImageView != nil {
            if (alreadyAddCircle == false){
                let centerPoint = CGPoint(x: profileImageView.frame.origin.x + profileImageView.frame.size.width/2, y: profileImageView.frame.origin.y + profileImageView.frame.height/2)
                let radius = profileImageView.frame.size.width/2 + 5
                let circleLayer = Utilities.layerForCircle(centerPoint, radius: radius, lineWidth: 1)
                circleLayer.fillColor = UIColor.clear.cgColor
                let color = UIColor(red: 227, green: 223, blue: 246, alpha: 1)
                circleLayer.strokeColor = color.cgColor
                profileView.layer.addSublayer(circleLayer)
            }
        }
        if isPostInProfileTab {
            configurePostUi()
        }
    }
    
    // MARK: BINH BINH, need to reset all UI before populating to prevent wrong UI from reusing cell
    func resetUI(){
//        dispatch_async(dispatch_get_main_queue(), {
//            self.profileImageView.image = nil
//            self.profileNameLabel.text = ""
//            self.textView.text = ""
//            self.postDateLabel.text = ""
//            self.likeNumberLabel.text = ""
//        })
    }
    
    // MARK: reuse
    
    override func prepareForReuse() {
        self.profileImageView?.image = profilePicturePlaceholder
    }
    
    fileprivate func configureCell(_ post: UserPost) {
        DispatchQueue.main.async(execute: {
//            SocialManager.sharedInstance.
            self.configureViewOptionForPost(isOwner: false)
            if let userId = XAppDelegate.currentUser.uid as? Int {
                if userId == post.uid {
                    self.configureViewOptionForPost(isOwner: true)
                } 
            }
                
            
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
            ] as [String : Any]
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            att.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, att.string.utf16.count))
            self.textView!.linkTextAttributes = linkAttributes
            self.textView.attributedText = att
            self.textView.font = UIFont(name: "Book Antiqua", size: 14)
            
//            self.likeNumberLabel.text = "\(post.hearts) Likes  \(post.shares) Shares"
            self.likeNumberLabel.text = "\(post.hearts) Likes"
            if UserDefaults.standard.bool(forKey: String(post.post_id)) {
                self.likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), for: UIControlState())
                self.likeButton.isUserInteractionEnabled = false
            } else {
                self.likeButton.setImage(UIImage(named: "newsfeed_heart_icon"), for: UIControlState())
                self.likeButton.isUserInteractionEnabled = true
            }
            
            let likeLabelTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.tapLikeLable(_:)))
            self.likeNumberLabel.isUserInteractionEnabled = true
            self.likeNumberLabel.addGestureRecognizer(likeLabelTapRecognizer)
            
            self.fakeReadmoreLabel?.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.readmoreTapped))
            self.fakeReadmoreLabel?.addGestureRecognizer(tapGesture)
            self.fakeReadmoreLabel?.font = UIFont(name: "Book Antiqua", size: 14)
            if(!self.viewController.isKind(of: SinglePostViewController.classForCoder())){
                self.setupTextViewMaxLines()
            }
            
            // fake a read more button if it should be truncate on client side
            if(Utilities.shouldBeTruncatedOnClient(post.message)){
                self.fakeReadmoreLabel?.isHidden = false
            } else {
                self.fakeReadmoreLabel?.isHidden = true
            }
            self.textView.contentInset = UIEdgeInsets(top: 0, left: 2, bottom: 0,right: 2)
            
            guard let lblNumberOfComments = self.lblNumberOfComments else { return }
            let comments = post.comments
            lblNumberOfComments.text = "\(comments)"
            if comments > 9 {
                self.lblNumberOfCommentsWidth.constant = 21
                
            } else {
                self.lblNumberOfCommentsWidth.constant = 12
            }
            
            
        })
    }
    
    func configureCellForNewsfeed(_ post: UserPost) {
        DispatchQueue.main.async(execute: {
            self.configureNewsfeedUi()
            self.configureCell(post)
            self.horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: (post.user?.sign)!)
            self.horoscopeSignImageView.image = Utilities.horoscopeSignIconImage(fromSignNumber: (post.user?.sign)!)
            if(post.user?.sign >= 0){
                self.horoscopeSignView.isHidden = false
            } else {
                self.horoscopeSignView.isHidden = true
            }
            Utilities.getImageFromUrlString(post.user!.imgURL, completionHandler: { (image) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.profileImageView.image = image
                })
            })
            self.locationLabel.text = post.user?.location
            self.profileNameLabel.text = post.user?.name
            
        })
    }
    
    func configureCellForProfile(_ post: UserPost) {
        isPostInProfileTab = true
        configureCell(post)
    }
    
    fileprivate func configurePostUi() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: containerView.bounds, byRoundingCorners: UIRectCorner.bottomLeft.union(.bottomRight), cornerRadii: CGSize(width: 4, height: 4)).cgPath
        containerView.layer.mask = maskLayer
    }
    
    func configureNewsfeedUi() {
        DispatchQueue.main.async(execute: {
            self.headerBackgroundImage = Utilities.makeCornerRadius(self.headerBackgroundImage, maskFrame: self.headerBackgroundImage.bounds, roundOptions: [.topLeft , .topRight], radius: 4) as! UIImageView
            self.actionView = Utilities.makeCornerRadius(self.actionView, maskFrame: self.actionView.bounds, roundOptions: [.bottomLeft , .bottomRight], radius: 4)
            self.horoscopeSignView.layer.cornerRadius = 4
            self.horoscopeSignView.clipsToBounds = true
            
            self.profileImageView.layer.cornerRadius = self.profileImageSize / 2
            self.profileImageView.clipsToBounds = true
            
            let nameGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.tapProfile(_:)))
            self.profileNameLabel.isUserInteractionEnabled = true
            self.profileNameLabel.addGestureRecognizer(nameGestureRecognizer)
            
            let nameGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.tapProfile(_:)))
            self.locationLabel.isUserInteractionEnabled = true
            self.locationLabel.addGestureRecognizer(nameGestureRecognizer2)
            
            let nameGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(PostTableViewCell.tapProfile(_:)))
            self.horoscopeSignView.isUserInteractionEnabled = true
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
    
    func tapProfile(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if SocialManager.sharedInstance.isLoggedInFacebook() {
                let profile = post.user
                let controller = viewController.storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
                controller.userProfile = profile!
                viewController.navigationController?.pushViewController(controller, animated: true)
            } else {
                Utilities.showAlert(viewController, title: "Action Denied", message: "Please login via Facebook to perform this action", error: nil)
            }
        }
    }
    
    @IBAction func tapLikeButton(_ sender: UIButton) {
        if(!XAppDelegate.socialManager.isLoggedInFacebook()){
//            Utilities.showAlertView(self, title: "", message: "Please login via Facebook to perform this action", tag: 1)
            showLoginFormSheet()
            return
        }
        likePost()
    }

    @IBAction func tapShareButton(_ sender: UIButton) {
        let name = post.user?.name
        let postContent = post.message
        let sharingText = String(format: "%@ \n %@", name!, postContent)
        let controller = Utilities.getShareViewController()
        controller.populateNewsfeedShareData(post.post_id, viewType: ShareViewType.shareViewTypeHybrid, sharingText: sharingText, pictureURL: "", shareUrl: post.permalink)
        Utilities.presentShareFormSheetController(viewController, shareViewController: controller)
    }
    
    func tapLikeLable(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            
                if SocialManager.sharedInstance.isLoggedInFacebook() {
                    let postId = self.post.post_id
                    Utilities.showHUD(viewController.view)
                    SocialManager.sharedInstance.retrieveUsersWhoLikedPost(postId, page: 0) { (result, error) -> Void in
                        if(error != ""){
                            Utilities.hideHUD(self.viewController.view)
                            Utilities.showAlert(self.viewController, title: "\(self.post.hearts) likes", message: "", error: nil)
                        } else {
                            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                            let viewController = storyBoard.instantiateViewController(withIdentifier: "LikeDetailTableViewController") as! LikeDetailTableViewController
                            viewController.postId = postId
                            viewController.userProfile = result!.0
                            viewController.parentVC = self.viewController
                            viewController.numberOfLike = self.post.hearts
                            Utilities.hideHUD(self.viewController.view)
                            self.displayViewController(viewController)
                        }
                    }
                } else {
                    Utilities.showAlert(self.viewController, title: "\(self.post.hearts) likes", message: "", error: nil)
                }
            
        }
    }
    
    //     Notification handler
    func sendHeartSuccessful(_ notif: Notification){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: NOTIFICATION_SEND_HEART_FINISHED), object: nil)
        post.hearts += 1
    }
    
    // MARK: link textview Delegate
    func linkTextView(_ linkTextView: CCHLinkTextView!, didTapLinkWithValue value: AnyObject!) {
        let urlString = value as! String
        
        self.tapOnLink(urlString)
    }
    
    // MARK: display View controller
    func displayViewController(_ viewController : UIViewController){
        DispatchQueue.main.async {
        let paddingTop = (DeviceType.IS_IPHONE_4_OR_LESS) ? 50 : 70 as CGFloat
        let formSheet = MZFormSheetController(viewController: viewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.fade
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.portraitTopInset = paddingTop;
            formSheet.presentedFormSheetSize = CGSize(width: Utilities.getScreenSize().width - 20, height: Utilities.getScreenSize().height - paddingTop * 2)
        self.viewController.mz_present(formSheet, animated: true, completionHandler: nil)
        }
    }
    
    // MARK: Text view Max Lines
    func setupTextViewMaxLines(){
        self.textView.textContainer.maximumNumberOfLines = Utilities.getTextViewMaxLines()
    }
    
    //MARK: Read more action
    
    func readmoreTapped(){
        tapOnLink("readmore")
    }
    
    func tapOnLink(_ urlString : String){
        Utilities.showHUD()
        XAppDelegate.socialManager.getPost(post.post_id,ignoreCache: true, completionHandler: { (result, error) -> Void in
            Utilities.hideHUD()
            if let _ = error {
                
            } else {
                if(urlString == "readmore"){
                    if let result = result {
                        for post : UserPost in result {
                            let controller = self.viewController.storyboard?.instantiateViewController(withIdentifier: "SinglePostViewController") as! SinglePostViewController
                            controller.userPost = post
                            DispatchQueue.main.async(execute: { () -> Void in
                                self.viewController.navigationController?.pushViewController(controller, animated: true)
                            })
                        }
                    }
                } else {
                    print("urlString urlString = \(urlString)")
                    if let url = URL(string: urlString) {
                        UIApplication.shared.openURL(url)
                    }
                    
                }
                
            }
        })
    }
    
    // MARK: FB Login dialog
    
    func showLoginFormSheet() {
        let controller = viewController.storyboard?.instantiateViewController(withIdentifier: "PostLoginViewController") as! PostLoginViewController
        controller.delegate = self
        controller.titleString = "Login to Facebook to like this post"
        let formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.cornerRadius = 5
        formSheet.shouldCenterVertically = true
        formSheet.presentedFormSheetSize = CGSize(width: formSheet.view.frame.width, height: 150)
        viewController.mz_present(formSheet, animated: true, completionHandler: nil)
    }
    
    func didLoginSuccessfully() {
        likePost()
    }
    
    // MARK: Like post 
    
    func likePost(){
        let label = "type = post, like = 1, info = \(post.post_id)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.like, label: label)
        self.likeButton.setImage(UIImage(named: "newsfeed_red_heart_icon"), for: UIControlState())
        self.likeButton.isUserInteractionEnabled = false
        //        self.likeNumberLabel.text = "\(++post.hearts) Likes  \(post.shares) Shares"
        self.likeNumberLabel.text = "\(post.hearts += 1) Likes"
        NotificationCenter.default.addObserver(self, selector: #selector(PostTableViewCell.sendHeartSuccessful(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_SEND_HEART_FINISHED), object: nil)
        XAppDelegate.socialManager.sendHeart(post.uid, postId: post.post_id, type: SEND_HEART_USER_POST_TYPE)
    }
    
    @IBAction func btnDownArrowDidTouch(_ sender: Any) {
        self.showOptions()
    }
    
    func showOptions() {
        guard let triangle = imgDropdownTopTriangle else { return }
        self.imgDropdownTopTriangle.isHidden = false
        self.viewOptions.isHidden = false
        self.viewContentFade.alpha = 0.7
        
        let rectShape = CAShapeLayer()
        let radii = 4
        rectShape.bounds = self.viewContentFade.frame
        rectShape.position = self.viewContentFade.center
        rectShape.path = UIBezierPath(roundedRect: self.viewContentFade.bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: radii, height: radii)).cgPath
        self.viewContentFade.layer.mask = rectShape
    }
    
    func hideOptions() {
        guard let triangle = imgDropdownTopTriangle else { return }
        self.imgDropdownTopTriangle.isHidden = true
        self.viewOptions.isHidden = true
        self.viewContentFade.alpha = 0
    }
    
    //Option View Buttons
    @IBAction func btnEditDidTouch(_ sender: Any) {
    }
    
    @IBAction func btnDeleteDidTouch(_ sender: Any) {
    }
    
    @IBAction func btnReportDidTouch(_ sender: Any) {
    }
    
    func configureViewOptionForPost(isOwner: Bool) {
        if !isOwner {
            self.btnEditPost.isHidden = true
            self.viewViewOptionLine.isHidden = true
            self.btnDelete.isHidden = true
            self.btnReport.isHidden = false
            self.viewViewOptionHeight.constant = 60
        } else {
            self.btnEditPost.isHidden = false
            self.viewViewOptionLine.isHidden = false
            self.btnDelete.isHidden = false
            self.btnReport.isHidden = true
            self.viewViewOptionHeight.constant = 120
        }
    }
}

