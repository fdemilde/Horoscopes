//
//  DiscoverTableCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 11/20/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class DiscoverTableCell : UITableViewCell, CCHLinkTextViewDelegate {
    
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
    
    @IBOutlet weak var headerView: UIView!
    var parentViewController : DiscoverViewController!
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
            self.headerView.layer.addSublayer(circleLayer)
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
    
    // MARK: Button action
    
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
                Utilities.showAlert(parentViewController, title: "Action Denied", message: "You have to login to Facebook to view profile!", error: nil)
            }
        }
    }
}
