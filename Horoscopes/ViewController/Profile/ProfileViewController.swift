//
//  ProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, FollowDelegate, ButtonDelegate, UIAlertViewDelegate {
    
    var facebookLoginButton: UIButton?
    var facebookLoginLabel: UILabel?
    
    var profileTableView: ASTableView?
    let padding: CGFloat = 10
    let tabBarHeight: CGFloat = 49
    
    var userPosts = [UserPost]()
    enum Tab {
        case Post
        case Followers
        case Following
    }
    var currentUser: UserProfile?
    var followingUsers = [UserProfile]()
    var followers = [UserProfile]()
    var isFollowedArray = [Bool]()
    var currentTab = Tab.Post
    
    let postButtonTitleLabel = "Post"
    let followersButtonTitleLabel = "Followers"
    let followingButtonTitleLabel = "Following"
    
    var isFinishedPostDataSource = false
    var isFinishedFollowersDataSource = false
    var isFinishedFollowingDataSource = false
    
    var isFirstDataLoad = true
    
    var successfulFollow = false
    
    var firstSectionHeader: ProfileFirstSectionHeaderView?
    var secondSectionHeader: ProfileSecondSectionHeaderView?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        SocialManager.sharedInstance.unfollow(8, completionHandler: { (error) -> Void in
//            if let error = error {
//                println("unfollow unsuccessfully")
//            }
//        })
//        SocialManager.sharedInstance.follow(3, completionHandler: { (error) -> Void in
//            if let error = error {
//                println("unfollow unsuccessfully")
//            }
//        })
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        view.backgroundColor = UIColor(patternImage: image)
        
        configureProfileTableView()
        view.addSubview(profileTableView!)
        
        if SocialManager.sharedInstance.isLoggedInZwigglers() {
            getCurrentUserProfile()
        } else {
            configureLoginView()
        }
    }
    
    override func viewWillLayoutSubviews() {
        if profileTableView != nil {
            profileTableView!.frame = CGRectMake(padding, 0, view.bounds.width - padding*2, view.bounds.height - tabBarHeight)
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ConfigureUI
    
    func configureUI() {
        profileTableView?.hidden = false
        reloadPostDataSource()
        reloadFollowersDataSource()
        reloadFollowingDataSource()
    }
    
    func configureLoginView() {
        facebookLoginButton = UIButton()
        let facebookLoginImage = UIImage(named: "fb_login_icon")
        facebookLoginButton!.setImage(facebookLoginImage, forState: UIControlState.Normal)
        facebookLoginButton!.sizeToFit()
        facebookLoginButton!.frame.origin = CGPointMake(view.frame.width/2 - facebookLoginButton!.frame.width/2, view.frame.height/2 - facebookLoginButton!.frame.height/2)
        facebookLoginButton!.addTarget(self, action: "login:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(facebookLoginButton!)
        facebookLoginLabel = UILabel()
        facebookLoginLabel!.text = "You need to login to Facebook\nto enjoy this feature"
        facebookLoginLabel!.textColor = UIColor.lightTextColor()
        facebookLoginLabel!.numberOfLines = 2
        facebookLoginLabel!.sizeToFit()
        facebookLoginLabel!.textAlignment = NSTextAlignment.Center
        facebookLoginLabel!.frame.origin = CGPointMake(view.frame.width/2 - facebookLoginLabel!.frame.width/2, facebookLoginButton!.frame.origin.y + facebookLoginButton!.frame.size.height + 8)
        view.addSubview(facebookLoginLabel!)
    }
    
    func configureProfileTableView() {
        profileTableView = ASTableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        profileTableView?.hidden = true
        profileTableView!.asyncDataSource = self
        profileTableView!.asyncDelegate = self
        profileTableView!.showsHorizontalScrollIndicator = false
        profileTableView!.showsVerticalScrollIndicator = false
        profileTableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        profileTableView!.backgroundColor = UIColor.clearColor()
    }
    
    // MARK: - Helper
    
    func reloadSection(section: Int, withRowAnimation: UITableViewRowAnimation) {
        let range = NSMakeRange(section, 1)
        let section = NSIndexSet(indexesInRange: range)
        profileTableView?.reloadSections(section, withRowAnimation: withRowAnimation)
    }
    
    func getCurrentUserProfile() {
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
        SocialManager.sharedInstance.getProfile("\(uid)", completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentUser = result![0]
                    self.configureUI()
                })
            }
        })
    }
    
    func changeButtonTitleLabel(buttonToBeHighlighted sender: UIButton) {
        let postButton = secondSectionHeader!.postButton
        let followersButton = secondSectionHeader!.followersButton
        let followingButton = secondSectionHeader!.followingButton
        let buttons = [postButton, followersButton, followingButton]
        for button in buttons {
            var string = NSMutableAttributedString()
            switch button {
            case postButton:
                let title = "\(postButtonTitleLabel)\n\(userPosts.count)"
                string.appendAttributedString(NSAttributedString(string: title))
                if button == sender {
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(postButtonTitleLabel)))
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightTextColor(), range: NSMakeRange(count(postButtonTitleLabel), count(title) - count(postButtonTitleLabel)))
                } else {
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 68/255.0, green: 66/255.0, blue: 96/255.0, alpha: 1), range: NSMakeRange(0, count(title)))
                }
            case followersButton:
                let title = "\(followersButtonTitleLabel)\n\(followers.count)"
                string.appendAttributedString(NSAttributedString(string: title))
                if button == sender {
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(followersButtonTitleLabel)))
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightTextColor(), range: NSMakeRange(count(followersButtonTitleLabel), count(title) - count(followersButtonTitleLabel)))
                } else {
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 68/255.0, green: 66/255.0, blue: 96/255.0, alpha: 1), range: NSMakeRange(0, count(title)))
                }
            case followingButton:
                let title = "\(followingButtonTitleLabel)\n\(followingUsers.count)"
                string.appendAttributedString(NSAttributedString(string: title))
                if button == sender {
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor(), range: NSMakeRange(0, count(followingButtonTitleLabel)))
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor.lightTextColor(), range: NSMakeRange(count(followingButtonTitleLabel), count(title) - count(followingButtonTitleLabel)))
                } else {
                    string.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 68/255.0, green: 66/255.0, blue: 96/255.0, alpha: 1), range: NSMakeRange(0, count(title)))
                }
            default:
                print("Unrecognized button.")
            }
            button.setAttributedTitle(string, forState: UIControlState.Normal)
        }
    }
    
    func login(sender: UIButton) {
        SocialManager.sharedInstance.login { (error) -> Void in
            if let error = error {
                // TODO: Let user try again
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.facebookLoginButton?.removeFromSuperview()
                    self.facebookLoginLabel?.removeFromSuperview()
                    self.getCurrentUserProfile()
                })
            }
        }
    }
    
    func finishLoadingPostDataSource(error: NSError?) {
        isFinishedPostDataSource = true
        if isFirstDataLoad {
            loadDataInitially()
        } else {
            changeButtonTitleLabel(buttonToBeHighlighted: secondSectionHeader!.postButton)
            reloadSection(1, withRowAnimation: UITableViewRowAnimation.Automatic)
            isFinishedPostDataSource = false
            Utilities.hideHUD()
        }
    }
    
    func finishLoadingFollowersDataSource(error: NSError?) {
        isFinishedFollowersDataSource = true
        if isFirstDataLoad {
            loadDataInitially()
        } else if successfulFollow {
            populateIsFollowedArray()
            reloadSection(1, withRowAnimation: UITableViewRowAnimation.None)
        } else {
            changeButtonTitleLabel(buttonToBeHighlighted: secondSectionHeader!.followersButton)
            reloadSection(1, withRowAnimation: UITableViewRowAnimation.Automatic)
            isFinishedFollowersDataSource = false
            Utilities.hideHUD()
        }
    }
    
    func finishLoadingFollowingDataSource(error: NSError?) {
        isFinishedFollowingDataSource = true
        if isFirstDataLoad {
            loadDataInitially()
        } else if successfulFollow {
            populateIsFollowedArray()
            reloadSection(1, withRowAnimation: UITableViewRowAnimation.None)
        } else {
            changeButtonTitleLabel(buttonToBeHighlighted: secondSectionHeader!.followingButton)
            reloadSection(1, withRowAnimation: UITableViewRowAnimation.Automatic)
            isFinishedFollowingDataSource = false
            Utilities.hideHUD()
        }
    }
    
    func loadDataInitially() {
        if isFinishedPostDataSource && isFinishedFollowersDataSource && isFinishedFollowingDataSource {
            isFirstDataLoad = false
            changeButtonTitleLabel(buttonToBeHighlighted: secondSectionHeader!.postButton)
            isFinishedPostDataSource = false
            populateIsFollowedArray()
            reloadSection(0, withRowAnimation: UITableViewRowAnimation.Automatic)
            reloadSection(1, withRowAnimation: UITableViewRowAnimation.Automatic)
            Utilities.hideHUD()
        }
    }
    
    func reloadPostDataSource() {
        Utilities.showHUD()
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
        userPosts.removeAll(keepCapacity: false)
        SocialManager.sharedInstance.getPost(Int(uid), completionHandler: { (result, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.finishLoadingPostDataSource(error)
                })
            } else {
                self.userPosts = result!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.finishLoadingPostDataSource(nil)
                })
            }
        })
    }
    
    func reloadFollowersDataSource() {
        Utilities.showHUD()
        followers.removeAll(keepCapacity: false)
        SocialManager.sharedInstance.getFollowersProfile { (result, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.finishLoadingFollowersDataSource(error)
                })
            } else {
                self.followers = result!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.finishLoadingFollowersDataSource(nil)
                })
            }
        }
    }
    
    func reloadFollowingDataSource() {
        Utilities.showHUD()
        followingUsers.removeAll(keepCapacity: false)
        SocialManager.sharedInstance.getFollowingUsersProfile { (result, error) -> Void in
            if let error = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.finishLoadingFollowingDataSource(error)
                })
            } else {
                self.followingUsers = result!
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.finishLoadingFollowingDataSource(nil)
                })
            }
        }
    }
    
    func populateIsFollowedArray() {
        if isFinishedFollowersDataSource && isFinishedFollowingDataSource {
            isFollowedArray.removeAll(keepCapacity: true)
            for follower in followers {
                var isFollowed = false
                for followingUser in followingUsers {
                    if follower.uid == followingUser.uid {
                        isFollowed = true
                        break
                    }
                }
                isFollowedArray.append(isFollowed)
            }
            if successfulFollow {
                changeButtonTitleLabel(buttonToBeHighlighted: secondSectionHeader!.followersButton)
            }
            isFinishedFollowersDataSource = false
            isFinishedFollowingDataSource = false
            successfulFollow = false
        }
    }
    
    // MARK: Datasource and delegate
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            switch currentTab {
            case .Followers:
                return followers.count
            case .Following:
                return followingUsers.count
            default:
                return userPosts.count
            }
        }
    }
    
    func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        if section == 0 {
            firstSectionHeader = ProfileFirstSectionHeaderView(frame: CGRectMake(profileTableView!.bounds.origin.x, profileTableView!.bounds.origin.y, profileTableView!.bounds.size.width, 54))
            return firstSectionHeader
        } else {
            secondSectionHeader = ProfileSecondSectionHeaderView(frame: CGRectMake(profileTableView!.bounds.origin.x, 174.5, profileTableView!.bounds.size.width, 80))
            secondSectionHeader!.buttonDelegate = self
            return secondSectionHeader
        }
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 54
        } else {
            return 80
        }
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        if indexPath.section == 0 {
            if let currentUser = currentUser {
                let cell = ProfileFirstSectionCellNode(userProfile: currentUser)
                return cell
            }
            return ASCellNode()
        } else {
            switch currentTab {
            case .Followers:
                let follower = followers[indexPath.row] as UserProfile
                let cell = ProfileFollowCellNode(user: follower, isFollowed: isFollowedArray[indexPath.row])
                cell.followDelegate = self
                return cell
            case .Following:
                let followingUser = followingUsers[indexPath.row] as UserProfile
                let cell = ProfileFollowCellNode(user: followingUser)
                return cell
            default:
                let userPost = userPosts[indexPath.row] as UserPost
                let cell = ProfilePostCellNode(userPost: userPost)
                return cell
            }
        }
    }
    
    func didClickFollowButton(uid: Int) {
        SocialManager.sharedInstance.follow(uid, completionHandler: { (error) -> Void in
            if let error = error {
                
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.successfulFollow = true
                    self.reloadFollowersDataSource()
                    self.reloadFollowingDataSource()
                })
            }
        })
    }
    
    func didTapPostButton(sender: UIButton) {
        currentTab = .Post
        reloadPostDataSource()
        changeButtonTitleLabel(buttonToBeHighlighted: sender)
    }
    
    func didTapFollowersButton(sender: UIButton) {
        currentTab = .Followers
        reloadFollowersDataSource()
        changeButtonTitleLabel(buttonToBeHighlighted: sender)
    }
    
    func didTapFollowingButton(sender: UIButton) {
        currentTab = .Following
        reloadFollowingDataSource()
        changeButtonTitleLabel(buttonToBeHighlighted: sender)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
