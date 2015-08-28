//
//  NewProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewProfileViewController: ViewControllerWithAds, UITableViewDataSource, ProfilePostTableViewCellDelegate {

    @IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet weak var horoscopeSignView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var horoscopeSignImageView: UIImageView!
    @IBOutlet weak var horoscopeSignLabel: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var loginView: UIView!
    
    enum ProfileType {
        case CurrentUser
        case OtherUser
    }
    enum Tab {
        case Post
        case Followers
        case Following
    }
    var profileType: ProfileType = .CurrentUser
    var userProfile = UserProfile()
    var userPosts = [UserPost]()
    var followers = [UserProfile]()
    var followingUsers = [UserProfile]()
    var currentTab = Tab.Post
    static let postDateFormat = "MMMM dd, yyyy"
//    var isFirstDataLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        if profileType == .CurrentUser {
            if SocialManager.sharedInstance.isLoggedInFacebook() {
                if SocialManager.sharedInstance.isLoggedInZwigglers() {
                    getProfileAndData()
                } else {
                    SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                        if let error = error {
                            Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                        } else {
                            self.getProfileAndData()
                        }
                    })
                }
            } else {
                configureLoginView()
            }
        } else {
            getDataInitially()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Configure UI
    
    func configureTableView() {
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        horoscopeSignView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        horoscopeSignView.layer.cornerRadius = 4
        horoscopeSignView.clipsToBounds = true
    }
    
    func configureLoginView() {
        tableHeaderView.hidden = true
        
        let loginFrame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + ADMOD_HEIGHT, width: view.frame.width, height: view.frame.height - ADMOD_HEIGHT - TABBAR_HEIGHT)
        loginView = UIView(frame: loginFrame)
        let padding: CGFloat = 8
        
        let facebookLoginButton = UIButton()
        let facebookLoginImage = UIImage(named: "fb_login_icon")
        facebookLoginButton.setImage(facebookLoginImage, forState: UIControlState.Normal)
        facebookLoginButton.sizeToFit()
        facebookLoginButton.frame = CGRectMake(loginFrame.width/2 - facebookLoginButton.frame.width/2, loginFrame.height/2 - facebookLoginButton.frame.height/2, facebookLoginButton.frame.width, facebookLoginButton.frame.height)
        facebookLoginButton.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
        loginView.addSubview(facebookLoginButton)
        
        let facebookLoginLabel = UILabel()
        facebookLoginLabel.text = "You need to login to Facebook\nto enjoy this feature"
        facebookLoginLabel.textColor = UIColor.lightTextColor()
        facebookLoginLabel.numberOfLines = 2
        facebookLoginLabel.sizeToFit()
        facebookLoginLabel.textAlignment = NSTextAlignment.Center
        facebookLoginLabel.frame = CGRectMake(loginFrame.width/2 - facebookLoginLabel.frame.width/2, facebookLoginButton.frame.origin.y + facebookLoginButton.frame.height + padding, facebookLoginLabel.frame.width, facebookLoginLabel.frame.height)
        loginView.addSubview(facebookLoginLabel)
        
        view.addSubview(loginView)
    }
    
    func configureCell(cell: ProfilePostTableViewCell, post: UserPost) {
        switch post.type {
        case .OnYourMind:
            cell.headerView.backgroundColor = UIColor.newsfeedMindColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_mind")
        case .Feeling:
            cell.headerView.backgroundColor = UIColor.newsfeedFeelColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_feel")
        case .Story:
            cell.headerView.backgroundColor = UIColor.newsfeedStoryColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_story")
        }
        cell.postDateLabel.text = Utilities.getDateStringFromTimestamp(NSTimeInterval(post.ts), dateFormat: NewProfileViewController.postDateFormat)
        cell.textView.text = post.message
    }
    
    // MARK: - Action
    func login(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.login { (error, permissionGranted) -> Void in
            if let error = error {
                Utilities.showAlert(self, title: "Log In Error", message: "Could not log in to Facebook. Please try again later.", error: error)
            } else {
                if permissionGranted {
                    self.getProfileAndData()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.loginView.removeFromSuperview()
                        self.tableHeaderView.hidden = false
                        self.tableView.hidden = false
                    })
                } else {
                    Utilities.showAlert(self, title: "Permission Denied", message: "Not enough permission is granted.", error: nil)
                }
            }
        }
    }
    
    // MARK: - Data handler
    
    func profileOfCurrentUser() -> UserProfile? {
        var result: UserProfile?
        if XAppDelegate.currentUser.uid == -1 {
            SocialManager.sharedInstance.persistUserProfile({ (error) -> Void in
                if let error = error {
                    Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                } else {
                    result = XAppDelegate.currentUser
                }
            })
        } else {
            result = XAppDelegate.currentUser
        }
        return result
    }
    
    func getDataInitially() {
        Utilities.showHUD()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.configureTableView()
            var getDataGroup = dispatch_group_create()
            
            self.getUserPosts(getDataGroup)
            self.getFollowers(getDataGroup)
            self.getFollowingUsers(getDataGroup)
            
            dispatch_group_notify(getDataGroup, dispatch_get_main_queue()) { () -> Void in
                self.tableView.reloadData()
                Utilities.hideHUD()
            }
        })
    }
    
    func getUserPosts(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.getPost(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.userPosts = result!
            }
            if let group = dispatchGroup {
                dispatch_group_leave(group)
            }
        })
    }
    
    func getFollowers(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        if profileType == .CurrentUser {
            SocialManager.sharedInstance.getCurrentUserFollowersProfile { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.followers = result!
                }
                if let group = dispatchGroup {
                    dispatch_group_leave(group)
                }
            }
        } else {
            SocialManager.sharedInstance.getOtherUserFollowersProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.followers = result!
                }
                if let group = dispatchGroup {
                    dispatch_group_leave(group)
                }
            })
        }
    }
    
    func getFollowingUsers(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        if profileType == .CurrentUser {
            SocialManager.sharedInstance.getCurrentUserFollowingProfile { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.followingUsers = result!
                }
                if let group = dispatchGroup {
                    dispatch_group_leave(group)
                }
            }
        } else {
            SocialManager.sharedInstance.getOtherUserFollowingProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
                if let error = error {
                    
                } else {
                    self.followingUsers = result!
                }
                if let group = dispatchGroup {
                    dispatch_group_leave(group)
                }
            })
        }
    }
    
    // MARK: - Helper
    
    func getProfileAndData() {
        if let profile = profileOfCurrentUser() {
            userProfile = profile
            getDataInitially()
        } else {
            let uid = XAppDelegate.mobilePlatform.userCred.getUid()
            SocialManager.sharedInstance.getProfile("\(uid)", completionHandler: { (result, error) -> Void in
                if let error = error {
                    // TODO: Try getting user profile again
                } else {
                    self.userProfile = result![0]
                    self.getDataInitially()
                }
            })
        }
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTab {
        case .Post:
            return userPosts.count
        case .Followers:
            return followers.count
        case .Following:
            return followingUsers.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch currentTab {
        case .Post:
            let post = userPosts[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfilePostTableViewCell", forIndexPath: indexPath) as! ProfilePostTableViewCell
            configureCell(cell, post: post)
            cell.delegate = self
            return cell
        case .Followers:
            let follower = followers[indexPath.row]
        case .Following:
            let followingUser = followingUsers[indexPath.row]
        }
        return UITableViewCell()
    }
    
    // MARK: - Delegate
    
    func didTapShareButton(profileName: String?, postContent: String) {
        let name = userProfile.name
        let sharingText = String(format: "%@ \n %@", name, postContent)
        let controller = Utilities.shareViewControllerForType(ShareViewType.ShareViewTypeHybrid, shareType: ShareType.ShareTypeNewsfeed, sharingText: sharingText)
        Utilities.presentShareFormSheetController(self, shareViewController: controller)
    }

}
