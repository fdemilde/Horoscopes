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
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            if SocialManager.sharedInstance.isLoggedInZwigglers() {
                userProfile = XAppDelegate.currentUser
                configureUi()
                getData()
            } else {
                SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        Utilities.showError(self, error: error)
                    } else {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.configureUi()
                        })
                        self.getData()
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
    
    func login(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.login { (error, permissionGranted) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(self, error: error)
            } else {
                if permissionGranted {
                    self.userProfile = XAppDelegate.currentUser
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if self.loginView != nil {
                            self.loginView.removeFromSuperview()
                            self.profileView.hidden = false
                        }
                        self.configureUi()
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
    
    override func getData() {
        super.getData()
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue()) { () -> Void in
            self.checkFollowStatus()
        }
    }
    
    override func getFollowingUsers(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.getCurrentUserFollowingProfile { (result, error) -> Void in
            if let error = error {
                Utilities.showError(self, error: error)
            } else {
                self.handleData(dispatchGroup, oldData: &self.followingUsers, newData: result!, button: self.followingButton)
            }
            if let group = dispatchGroup {
                dispatch_group_leave(group)
            }
        }
    }
    
    override func getFollowers(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.getCurrentUserFollowersProfile { (result, error) -> Void in
            if let error = error {
                Utilities.showError(self, error: error)
            } else {
                self.handleData(dispatchGroup, oldData: &self.followers, newData: result!, button: self.followersButton)
            }
            if let group = dispatchGroup {
                dispatch_group_leave(group)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        if currentScope == .Followers {
            
        } else {
            
        }
        return cell
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
