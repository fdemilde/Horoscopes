//
//  CurrentProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class CurrentProfileViewController: ProfileBaseViewController {
    
    // MARK: - Property
    
    var loginView: UIView!
    var friends = [UserProfile]()
    var noFollowingUser = false
    var noFollower = false
    let postTypeImages = [
        "newfeeds_post_feel",
        "newfeeds_post_story",
        "newfeeds_post_mind"
    ]
    let postTypes = [
        "feeling",
        "story",
        "onyourmind"
    ]
    var headerHeight: CGFloat = 0
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.registerClass(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "CurrentProfileHeaderFooterView")
        horoscopeSignView.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseHoroscopeSign:")
        horoscopeSignView.addGestureRecognizer(tapGestureRecognizer)
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            _ = scrollView as! UITableView
            if self.isLastPostPage || self.currentScope != .Post {
                self.tableView.finishInfiniteScroll()
                return
            }
            self.currentPostPage++
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            if SocialManager.sharedInstance.isLoggedInZwigglers() {
                removeLoginView()
                userProfile = XAppDelegate.currentUser
                configureProfileView()
                getData()
            } else {
                SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        self.userProfile = XAppDelegate.currentUser
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.removeLoginView()
                            self.configureProfileView()
                            self.getData()
                        })
                    }
                })
            }
        } else {
            configureLoginView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configure UI
    
    override func configureProfileView() {
        super.configureProfileView()
        if profileView.hidden {
            profileView.hidden = false
        }
        let sign = Int(XAppDelegate.userSettings.horoscopeSign)
        if sign >= 0 {
            horoscopeSignLabel.hidden = false
            horoscopeSignImageView.hidden = false
            horoscopeSignView.hidden = false
            horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: sign)
            horoscopeSignImageView.image = Utilities.horoscopeSignImage(fromSignNumber: sign)
        } else {
            horoscopeSignLabel.hidden = true
            horoscopeSignImageView.hidden = true
            horoscopeSignView.hidden = true
        }
    }
    
    func configureLoginView() {
        if loginView == nil {
            profileView.hidden = true
            tableView.hidden = true
            
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
    }
    
    // MARK: - Action
    
    func chooseHoroscopeSign(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
            parentViewController!.presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    func login(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.login { (error, permissionGranted) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(error, viewController: self)
            } else {
                if permissionGranted {
                    self.userProfile = XAppDelegate.currentUser
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.removeLoginView()
                        self.configureProfileView()
                    })
                    self.getData()
                } else {
                    Utilities.hideHUD()
                    Utilities.showAlert(self, title: "Permission Denied", message: "Not enough permission is granted.", error: nil)
                }
            }
        }
    }
    
    // MARK: - Helper
    
    func removeLoginView() {
        if loginView != nil {
            loginView.removeFromSuperview()
            loginView = nil
        }
    }
    
    override func getData() {
        super.getData()
        getFriends()
    }
    
    override func getUsersFollowing(completionHandler: () -> Void) {
        SocialManager.sharedInstance.getProfilesOfUsersFollowing { (result, error) -> Void in
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                DataStore.sharedInstance.usersFollowing = result!
                self.noFollowingUser = result!.count == 0
                if self.isDataUpdated(self.followingUsers, newData: result!) {
                    self.followingUsers = result!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
            completionHandler()
        }
    }
    
    override func getFollowers(completionHandler: () -> Void) {
        SocialManager.sharedInstance.getProfilesOfFollowers { (result, error) -> Void in
            if let error = error {
                completionHandler()
                Utilities.showError(error, viewController: self)
            } else {
                let followers = result!
                self.noFollower = followers.count == 0
                if self.isDataUpdated(self.followers, newData: result!) {
                    self.followers = followers
                    DataStore.sharedInstance.checkFollowStatus(self.followers, completionHandler: { (error) -> Void in
                        if let error = error {
                            Utilities.showError(error, viewController: self)
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                        completionHandler()
                    })
                } else {
                    completionHandler()
                }
            }
        }
    }
    
    func getFriends() {
        SocialManager.sharedInstance.retrieveFriendList { (result, error) -> Void in
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                self.friends = result!
            }
        }
    }
    
    func configureNoPostTableViewCell(cell: UITableViewCell, index: Int) {
        cell.textLabel?.text = postTypeTexts[index]
        cell.textLabel?.textColor = UIColor.grayColor()
        cell.imageView?.image = UIImage(named: postTypeImages[index])
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentScope == .Post {
            if noPost {
                changeToWhiteTableViewLayout()
                return 3
            } else {
                changeToClearTableViewLayout()
            }
        } else if currentScope == .Following && noFollowingUser {
            return friends.count
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if currentScope != .Post {
            if currentScope == .Following && noFollowingUser {
                let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
                cell.delegate = self
                let friend = friends[indexPath.row]
                cell.configureCell(friend)
                cell.configureFollowButton(friend.isFollowed, showFollowButton: true)
                return cell
            } else {
                let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! FollowTableViewCell
                cell.delegate = self
                if currentScope == .Following {
                    cell.configureFollowButton(false, showFollowButton: false)
                } else {
                    cell.configureFollowButton(followers[indexPath.row].isFollowed, showFollowButton: true)
                }
                return cell
            }
        } else {
            if noPost {
                if let cell = tableView.dequeueReusableCellWithIdentifier("NoPostTableViewCell") {
                    configureNoPostTableViewCell(cell, index: indexPath.row)
                    return cell
                } else {
                    let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "NoPostTableViewCell")
                    configureNoPostTableViewCell(cell, index: indexPath.row)
                    return cell
                }
            }
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if noPost {
            return 64
        }
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch currentScope {
        case .Post:
            if noPost {
                let controller = storyboard?.instantiateViewControllerWithIdentifier("DetailPostViewController") as! DetailPostViewController
                controller.type = postTypes[indexPath.row]
                controller.placeholder = postTypeTexts[indexPath.row]
                self.presentViewController(controller, animated: true, completion: nil)
            }
        default:
            var profile: UserProfile!
            if currentScope == .Following {
                if noFollowingUser {
                    profile = friends[indexPath.row]
                } else {
                    profile = followingUsers[indexPath.row]
                }
            } else if currentScope == .Followers {
                profile = followers[indexPath.row]
            }
            let controller = storyboard?.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
            controller.userProfile = profile!
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (currentScope == .Post && noPost) || (currentScope == .Following && noFollowingUser) || (currentScope == .Followers && noFollower) {
            return 26
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("CurrentProfileHeaderFooterView")!
        switch currentScope {
        case .Post:
            view.textLabel!.text = "You have not posted anything. Start posting something!"
        case .Following:
            view.textLabel!.text = "You have not followed anyone. Start follow someone!"
        case .Followers:
            view.textLabel!.text = "You do not have any follower."
        }
        return view
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.font = UIFont.systemFontOfSize(11)
        headerView.textLabel!.textColor = UIColor.grayColor()
        headerView.contentView.backgroundColor = UIColor.whiteColor()
    }
    
    // MARK: - Delegate
    
    func didTapFollowButton(cell: FollowTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        var users: [UserProfile]!
        if currentScope == .Followers {
            users = followers
        } else {
            users = friends
        }
        Utilities.showHUD()
        SocialManager.sharedInstance.follow(users[index!], completionHandler: { (error) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(error, viewController: self)
            } else {
                self.getUserProfileCounts()
                DataStore.sharedInstance.checkFollowStatus(users, completionHandler: { (error) -> Void in
                    if let error = error {
                        Utilities.hideHUD()
                        Utilities.showError(error, viewController: self)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                        })
                        Utilities.hideHUD()
                    }
                })
            }
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "searchFriend" {
            let controller = segue.destinationViewController as! SearchViewController
            controller.delegate = self
        }
    }

}
