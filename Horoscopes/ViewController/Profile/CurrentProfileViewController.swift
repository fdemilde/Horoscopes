//
//  CurrentProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class CurrentProfileViewController: ProfileBaseViewController {
    
    @IBOutlet weak var settingsButtonLeadingSpace: NSLayoutConstraint!
    // MARK: - Property
    
    var loginView: UIView!
    var friends = [UserProfile]()
    let postTypeImages = [
        "newfeeds_post_feel",
        "newfeeds_post_story",
        "newfeeds_post_mind"
    ]
    
    var headerHeight: CGFloat = 0
    var noPostView: PostButtonsView!
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        horoscopeSignView.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "chooseHoroscopeSign:")
        horoscopeSignView.addGestureRecognizer(tapGestureRecognizer)
        
        // Set custom indicator
        tableView.infiniteScrollIndicatorView = CustomInfiniteIndicator(frame: CGRectMake(0, 0, 24, 24))
        
        // Set custom indicator margin
        tableView.infiniteScrollIndicatorMargin = 40
        
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            _ = scrollView as! UITableView
            if self.isLastPostPage || self.currentScope != .Post {
                self.tableView.finishInfiniteScroll()
                return
            }
            self.currentPostPage++
        }
        noPostText = "You have not posted anything. Start posting something!"
        noUsersFollowingText = "You have not followed anyone. Start follow someone!"
        noFollowersText = "You do not have any follower."
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        noPostView = PostButtonsView(frame: tableView.frame)
        noPostView.hostViewController = self
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
            settingsButtonLeadingSpace.constant -= 50
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
    
    @IBAction func openSettings(sender: UIButton) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        controller.parentVC = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func chooseHoroscopeSign(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
            parentViewController!.presentViewController(loginVC, animated: true, completion: nil)
        }
    }
    
    func login(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.login(self) { (error, permissionGranted) -> Void in
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
            Utilities.hideHUD()
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
            Utilities.hideHUD()
            if let error = error {
                completionHandler()
                Utilities.showError(error, viewController: self)
            } else {
                let followers = result!
                self.noFollower = followers.count == 0
                if self.isDataUpdated(self.followers, newData: followers) {
                    self.followers = followers
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                DataStore.sharedInstance.checkFollowStatus(self.followers, completionHandler: { (error, shouldReload) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        if shouldReload {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.tableView.reloadData()
                            })
                        }
                    }
                    completionHandler()
                })
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
        tableView.backgroundView = nil
        if currentScope == .Post {
            if noPost {
                tableView.backgroundView = noPostView
            } else {
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
        }
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if currentScope != .Post {
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
        let user = users[index!]
        SocialManager.sharedInstance.follow(user, completionHandler: { (error) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(error, viewController: self)
            } else {
                user.isFollowed = true
                self.numberOfUsersFollowing += 1
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.followButton.hidden = true
                    self.configureScopeButton()
                })
                Utilities.hideHUD()
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
