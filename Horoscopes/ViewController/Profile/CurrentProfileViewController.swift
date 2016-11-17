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
    var LOGIN_VIEW_PADDING: CGFloat = 10
    
    let SETTINGS_BTN_SIZE = CGSize(width: 40,height: 30)
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        horoscopeSignView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CurrentProfileViewController.chooseHoroscopeSign(_:)))
        horoscopeSignView.addGestureRecognizer(tapGestureRecognizer)
        noPostText = "You have not posted anything. Start posting something!"
        noUsersFollowingText = "You have not followed anyone. Start follow someone!"
        noFollowersText = "You do not have any follower."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let isLoggedIn = XAppDelegate.socialManager.isLoggedInFacebook() ? 1 : 0
        let label = "logged_in \(isLoggedIn)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.profileOwn, label: label)
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            if SocialManager.sharedInstance.isLoggedInZwigglers() {
                removeLoginView()
                userProfile = XAppDelegate.currentUser
                configureProfileView()
                getData()
            } else {
                SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.current().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        self.userProfile = XAppDelegate.currentUser
                        DispatchQueue.main.async(execute: { () -> Void in
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
        noPostView = PostButtonsView(frame: tableView.frame, forceChangeButtonSize: true)
        noPostView.hostViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configure UI
    
    override func configureProfileView() {
        super.configureProfileView()
        if profileView.isHidden {
            profileView.isHidden = false
        }
        let sign = Int(XAppDelegate.userSettings.horoscopeSign)
        if sign >= 0 {
            horoscopeSignLabel.isHidden = false
            horoscopeSignImageView.isHidden = false
            horoscopeSignView.isHidden = false
            horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: sign)
            horoscopeSignImageView.image = Utilities.horoscopeSignIconImage(fromSignNumber: sign)
            
        } else {
            settingsButtonLeadingSpace.constant -= 50
            horoscopeSignLabel.isHidden = true
            horoscopeSignImageView.isHidden = true
            horoscopeSignView.isHidden = true
        }
    }
    
    func configureLoginView() {
        if loginView == nil {
            profileView.isHidden = true
            tableView.isHidden = true
            
            let loginFrame = CGRect(x: view.frame.origin.x + LOGIN_VIEW_PADDING, y: view.frame.origin.y + ADMOD_HEIGHT + LOGIN_VIEW_PADDING, width: view.frame.width - LOGIN_VIEW_PADDING * 2, height: view.frame.height - ADMOD_HEIGHT - TABBAR_HEIGHT - LOGIN_VIEW_PADDING * 2)
            loginView = UIView(frame: loginFrame)
            loginView.backgroundColor = UIColor(red: 97/255.0, green: 96/255.0, blue: 144/255.0, alpha: 1)
            
            // add corner radius
            loginView.layer.cornerRadius = 4
            
            // add shadow
            loginView.layer.shadowColor = UIColor.black.cgColor
            loginView.layer.shadowOffset = CGSize(width: 0, height: 3)
            loginView.layer.shadowRadius = 2
            loginView.layer.shadowOpacity = 0.3
            
            // Create setting button
            let buttonPadding: CGFloat = 10
            let settingsButton = UIButton(frame: CGRect(x: loginFrame.size.width - buttonPadding - SETTINGS_BTN_SIZE.width, y: buttonPadding, width: SETTINGS_BTN_SIZE.width, height: SETTINGS_BTN_SIZE.height))
            settingsButton.setImage(UIImage(named: "settings_btn"), for: UIControlState())
            settingsButton.addTarget(self, action: #selector(CurrentProfileViewController.openSettings(_:)), for: UIControlEvents.touchUpInside)
            loginView.addSubview(settingsButton)
            let padding: CGFloat = 8
            
            let facebookLoginButton = UIButton()
            let facebookLoginImage = UIImage(named: "fb_login_icon")
            facebookLoginButton.setImage(facebookLoginImage, for: UIControlState())
            facebookLoginButton.sizeToFit()
            facebookLoginButton.frame = CGRect(x: loginFrame.width/2 - facebookLoginButton.frame.width/2, y: loginFrame.height/2 - facebookLoginButton.frame.height/2 - 20, width: facebookLoginButton.frame.width, height: facebookLoginButton.frame.height)
            facebookLoginButton.addTarget(self, action: #selector(CurrentProfileViewController.login(_:)), for: UIControlEvents.touchUpInside)
            loginView.addSubview(facebookLoginButton)
            
            let facebookLoginLabel = UILabel()
            facebookLoginLabel.font = UIFont(name: "HelveticaNeue", size: 11)
            facebookLoginLabel.text = "Login via Facebook to unlock your Horoscopes profile"
            facebookLoginLabel.textColor = UIColor.white
            facebookLoginLabel.numberOfLines = 2
            facebookLoginLabel.sizeToFit()
            facebookLoginLabel.textAlignment = NSTextAlignment.center
            facebookLoginLabel.frame = CGRect(x: loginFrame.width/2 - facebookLoginLabel.frame.width/2, y: facebookLoginButton.frame.origin.y + facebookLoginButton.frame.height + padding, width: facebookLoginLabel.frame.width, height: facebookLoginLabel.frame.height)
            loginView.addSubview(facebookLoginLabel)
            
            view.addSubview(loginView)
        }
    }
    
    // MARK: - Action
    
    @IBAction func openSettings(_ sender: UIButton) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        controller.parentVC = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func chooseHoroscopeSign(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            parent!.present(loginVC, animated: true, completion: nil)
        }
    }
    
    func login(_ sender: UIButton) {
        Utilities.showHUD()
        currentPostPage = 0;
        SocialManager.sharedInstance.login(self) { (error, permissionGranted) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(error, viewController: self)
            } else {
                if permissionGranted {
                    self.userProfile = XAppDelegate.currentUser
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.removeLoginView()
                        self.configureProfileView()
                    })
                    self.getData()
                } else {
                    Utilities.hideHUD()
                    Utilities.showAlert(self, title: "Permission Denied", message: "Please grant permissions and try again", error: nil)
                }
            }
        }
    }
    
    // MARK: - Helper
    
    func refreshPostAndScrollToTop() {
        if currentScope != .post {
            currentScope = .post
            tableView.allowsSelection = false
            tapScopeButton(postButton)
            tableView.isPagingEnabled = true
        }
        currentPostPage = 0
        isLastPostPage = false
        if userProfile.uid != -1 {
            self.getUserProfileCounts()
            getFeed(true, completionHandler: { () -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.scrollToTop()
                })
            })
        }
    }
    
    func removeLoginView() {
        if loginView != nil {
            loginView.removeFromSuperview()
            loginView = nil
        }
    }
    
    override func getData() {
        super.getData()
//        getFriends()
    }
    
    override func getUsersFollowing(_ completionHandler: () -> Void) {
        SocialManager.sharedInstance.getProfilesOfUsersFollowing { (result, error) -> Void in
            Utilities.hideHUD()
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                DataStore.sharedInstance.usersFollowing = result!
                self.noFollowingUser = result!.count == 0
                if self.isDataUpdated(self.followingUsers, newData: result!) {
                    self.followingUsers = result!
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
            completionHandler()
        }
    }
    
    override func getFollowers(_ completionHandler: @escaping () -> Void) {
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
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                DataStore.sharedInstance.checkFollowStatus(self.followers, completionHandler: { (error, shouldReload) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        if shouldReload {
                            DispatchQueue.main.async(execute: { () -> Void in
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
    
    func configureNoPostTableViewCell(_ cell: UITableViewCell, index: Int) {
        cell.textLabel?.text = postTypeText[index]
        cell.textLabel?.textColor = UIColor.gray
        cell.imageView?.image = UIImage(named: postTypeImages[index])
    }
    
    func reloadFeeds(){
        currentPostPage = 0
        isLastPostPage = false
        getFeed(true, completionHandler: { () -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
            })
        })
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundView = nil
        if currentScope == .post {
            if noPost {
                tableView.backgroundView = noPostView
            } else {
            }
        } else if currentScope == .following && noFollowingUser {
            return friends.count
        }
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if currentScope != .post {
            if currentScope == .following && noFollowingUser {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
                cell.delegate = self
                let friend = friends[indexPath.row]
                cell.configureCell(friend)
                // BINH modify: comment out all follow button, do not delete commented code
                // cell.configureFollowButton(friend.isFollowed, showFollowButton: true)
                return cell
            } else {
                let cell = super.tableView(tableView, cellForRowAt: indexPath) as! FollowTableViewCell
                cell.delegate = self
                // BINH modify: comment out all follow button, do not delete commented code
//                if currentScope == .Following {
//                    cell.configureFollowButton(false, showFollowButton: false)
//                } else {
//                    cell.configureFollowButton(followers[indexPath.row].isFollowed, showFollowButton: true)
//                }
                return cell
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentScope != .post {
            var profile: UserProfile!
            if currentScope == .following {
                if noFollowingUser {
                    profile = friends[indexPath.row]
                } else {
                    profile = followingUsers[indexPath.row]
                }
            } else if currentScope == .followers {
                profile = followers[indexPath.row]
            }
            let controller = storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
            controller.userProfile = profile!
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    // MARK: - Delegate
    
    func didTapFollowButton(_ cell: FollowTableViewCell) {
        let index = tableView.indexPath(for: cell)?.row
        var users: [UserProfile]!
        if currentScope == .followers {
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
                DispatchQueue.main.async(execute: { () -> Void in
                    cell.followButton.isHidden = true
                    self.configureScopeButton()
                })
                Utilities.hideHUD()
            }
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "searchFriend" {
            let controller = segue.destination as! SearchViewController
            controller.delegate = self
        }
    }

}
