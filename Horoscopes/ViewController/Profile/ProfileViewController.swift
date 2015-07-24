//
//  ProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

enum ProfileTab {
    case Post
    case Followers
    case Following
}

class ProfileViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, FollowDelegate, ButtonDelegate, UIAlertViewDelegate, UIScrollViewDelegate {
    // MARK: - Properties
    let FIRST_HEADER_VIEW_TAG = 1
    let SECOND_HEADER_VIEW_TAG = 2
    
    var facebookLoginButton: UIButton?
    var facebookLoginLabel: UILabel?
    var backgroundImage: UIImage!
    
    var tableView: ASTableView?
    let padding: CGFloat = 10
    let tabBarHeight: CGFloat = 49
    let firstSectionHeaderHeight: CGFloat = 54
    let firstSectionCellHeight: CGFloat = 140.5
    var secondSectionHeaderHeight: CGFloat = 80
    
    var userPosts = [UserPost]()
    var currentUser: UserProfile?
    var followingUsers = [UserProfile]()
    var followers = [UserProfile]()
    var isFollowedArray = [Bool]()
    var currentTab = ProfileTab.Post
    
    var isFinishedPostDataSource = false
    var isFinishedFollowersDataSource = false
    var isFinishedFollowingDataSource = false
    var isFirstDataLoad = true
    var successfulFollow = false
    
    var temporarySecondSectionHeaderView: ProfileSecondSectionHeaderView?

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
        backgroundImage = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        if SocialManager.sharedInstance.isLoggedInZwigglers() {
            getCurrentUserProfile()
        } else {
            configureLoginView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ConfigureUI
    
    func configureUI() {
        reloadPostDataSource()
        reloadFollowersDataSource()
        reloadFollowingDataSource()
        tableView?.hidden = false
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
    
    func configureTableView() {
        tableView = ASTableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        tableView?.hidden = true
        tableView!.asyncDataSource = self
        tableView!.asyncDelegate = self
        tableView!.showsHorizontalScrollIndicator = false
        tableView!.showsVerticalScrollIndicator = false
        tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView!.backgroundColor = UIColor.clearColor()
        tableView!.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height - tabBarHeight)
        view.addSubview(tableView!)
    }
    
    // MARK: - Helper
    
    func reloadButton() {
        if let headerView = tableView?.viewWithTag(SECOND_HEADER_VIEW_TAG) as? ProfileSecondSectionHeaderView {
            switch currentTab {
            case .Post:
                headerView.reloadButtonTitleLabel(headerView.postButton)
            case .Followers:
                headerView.reloadButtonTitleLabel(headerView.followersButton)
            case .Following:
                headerView.reloadButtonTitleLabel(headerView.followingButton)
            }
        }
    }
    
    func reloadSection(section: Int, withRowAnimation: UITableViewRowAnimation) {
        let range = NSMakeRange(section, 1)
        let section = NSIndexSet(indexesInRange: range)
        tableView?.reloadSections(section, withRowAnimation: withRowAnimation)
    }
    
    func getCurrentUserProfile() {
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
        SocialManager.sharedInstance.getProfile("\(uid)", completionHandler: { (result, error) -> Void in
            if let error = error {
                
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentUser = result![0]
                    self.configureTableView()
                    self.configureUI()
                })
            }
        })
    }
    
    func login(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.login { (error) -> Void in
            if let error = error {
                
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
        if let error = error {
            
        } else {
            if isFirstDataLoad {
                loadDataInitially()
            } else {
                reloadData()
                isFinishedPostDataSource = false
            }
        }
    }
    
    func finishLoadingFollowersDataSource(error: NSError?) {
        isFinishedFollowersDataSource = true
        if let error = error {
            
        } else {
            if isFirstDataLoad {
                loadDataInitially()
            } else if successfulFollow {
                resetSection()
                populateIsFollowedArray()
            } else {
                reloadData()
                isFinishedFollowersDataSource = false
            }
        }
    }
    
    func finishLoadingFollowingDataSource(error: NSError?) {
        isFinishedFollowingDataSource = true
        if let error = error {
            
        } else {
            if isFirstDataLoad {
                loadDataInitially()
            } else if successfulFollow {
                resetSection()
                populateIsFollowedArray()
            } else {
                reloadData()
                isFinishedFollowingDataSource = false
            }
        }
    }
    
    func loadDataInitially() {
        if isFinishedPostDataSource && isFinishedFollowersDataSource && isFinishedFollowingDataSource {
            currentTab = .Post
            reloadButton()
            populateIsFollowedArray()
            isFirstDataLoad = false
            isFinishedPostDataSource = false
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
                reloadButton()
            }
            reloadSection(1, withRowAnimation: UITableViewRowAnimation.Automatic)
            isFinishedFollowersDataSource = false
            isFinishedFollowingDataSource = false
            successfulFollow = false
            Utilities.hideHUD()
        }
    }
    
    func showFirstSection() {
        if let var headerView = tableView?.viewWithTag(FIRST_HEADER_VIEW_TAG) as? ProfileFirstSectionHeaderView {
            headerView.show()
        }
    }
    
    func hideSecondSection() {
        if let var headerView = tableView?.viewWithTag(SECOND_HEADER_VIEW_TAG) as? ProfileSecondSectionHeaderView {
            if !headerView.hidden {
                headerView.hidden = true
            }
        }
    }
    
    func showSecondSection() {
        if let var headerView = tableView?.viewWithTag(SECOND_HEADER_VIEW_TAG) as? ProfileSecondSectionHeaderView {
            if headerView.hidden {
                headerView.hidden = false
            }
        }
    }
    
    func addTempSecondSection() {
        if temporarySecondSectionHeaderView == nil {
            temporarySecondSectionHeaderView = ProfileSecondSectionHeaderView(frame: CGRectMake(0, 0, tableView!.bounds.size.width, secondSectionHeaderHeight), userProfile: currentUser!, parentViewController: self)
            temporarySecondSectionHeaderView?.buttonDelegate = self
            temporarySecondSectionHeaderView?.backgroundColor = UIColor(patternImage: backgroundImage!)
            temporarySecondSectionHeaderView?.show()
            view.addSubview(temporarySecondSectionHeaderView!)
        }
    }
    
    func removeTempSecondSection() {
        if temporarySecondSectionHeaderView != nil {
            temporarySecondSectionHeaderView!.removeFromSuperview()
            temporarySecondSectionHeaderView = nil
        }
    }
    
    func hideTempSecondSection() {
        if let headerView = temporarySecondSectionHeaderView {
            if headerView.frame.origin.y == 0 {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    headerView.frame.origin.y -= self.secondSectionHeaderHeight
                })
            }
        }
    }
    
    func showTempSecondSection() {
        if let headerView = temporarySecondSectionHeaderView {
            if headerView.frame.origin.y != 0 {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    headerView.frame.origin.y = 0
                })
            }
        }
    }
    
    // MARK: - Convenience
    
    func resetSection() {
        showFirstSection()
        showSecondSection()
        removeTempSecondSection()
    }
    
    func reloadData() {
        resetSection()
        reloadButton()
        reloadSection(1, withRowAnimation: UITableViewRowAnimation.Automatic)
        Utilities.hideHUD()
    }
    
    // MARK: - Datasource and delegate
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
            let firstSectionHeader = ProfileFirstSectionHeaderView(frame: CGRectMake(tableView!.bounds.origin.x, tableView!.bounds.origin.y, tableView!.bounds.size.width, firstSectionHeaderHeight))
            firstSectionHeader.tag = FIRST_HEADER_VIEW_TAG
            return firstSectionHeader
        } else {
            let secondSectionHeader = ProfileSecondSectionHeaderView(frame: CGRectMake(tableView!.bounds.origin.x, firstSectionHeaderHeight + firstSectionCellHeight, tableView!.bounds.size.width, secondSectionHeaderHeight), userProfile: currentUser!, parentViewController: self)
            secondSectionHeader.buttonDelegate = self
            secondSectionHeader.tag = SECOND_HEADER_VIEW_TAG
            return secondSectionHeader
        }
    }
    
    func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return firstSectionHeaderHeight
        } else {
            return secondSectionHeaderHeight
        }
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        if indexPath.section == 0 {
            if let currentUser = currentUser {
                let cell = ProfileFirstSectionCellNode(userProfile: currentUser)
                return cell
            }
            return nil
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
        if currentTab != .Post {
            currentTab = .Post
            reloadButton()
            reloadPostDataSource()
        }
    }
    
    func didTapFollowersButton(sender: UIButton) {
        if currentTab != .Followers {
            currentTab = .Followers
            reloadButton()
            reloadFollowersDataSource()
        }
    }
    
    func didTapFollowingButton(sender: UIButton) {
        if currentTab != .Following {
            currentTab = .Following
            reloadButton()
            reloadFollowingDataSource()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let headerView = tableView?.viewWithTag(FIRST_HEADER_VIEW_TAG) as? ProfileFirstSectionHeaderView {
            let position: CGFloat = max(scrollView.contentOffset.y, 0)
            let percent: CGFloat = min(position / firstSectionCellHeight, 1)
            headerView.addButton.alpha = 1 - percent
            headerView.settingsButton.alpha = 1 - percent
        }
        
        if scrollView.contentOffset.y >= firstSectionHeaderHeight + firstSectionCellHeight {
            hideSecondSection()
            addTempSecondSection()
        } else {
            showSecondSection()
            removeTempSecondSection()
        }
        
        if scrollView.contentOffset.y >= firstSectionHeaderHeight + firstSectionCellHeight + secondSectionHeaderHeight {
            hideTempSecondSection()
        } else {
            showTempSecondSection()
        }
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
