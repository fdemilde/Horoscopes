//
//  OtherProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class OtherProfileViewController: ProfileBaseViewController, UISearchBarDelegate {
    
    // MARK: - Outlet
    
    @IBOutlet weak var followButtonLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var newsfeedFollowButton: UIButton!
    
//    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Property
    
    var isLastFollowingPage = false
    var isLastFollowersPage = false
    var isPushedFromNotification = false
    var currentFollowingPage: Int = 0 {
        didSet {
            if currentFollowingPage != 0 {
                SocialManager.sharedInstance.getProfilesOfUsersFollowing(forUser: userProfile.uid, page: currentFollowingPage, completionHandler: { (result, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        self.isLastFollowingPage = result!.1
                        self.followingUsers += result!.0
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                            self.tableView.finishInfiniteScroll()
                        })
                    }
                })
            }
        }
    }
    var currentFollowersPage: Int = 0 {
        didSet {
            if currentFollowersPage != 0 {
                SocialManager.sharedInstance.getProfilesOfFollowers(forUser: userProfile.uid, page: currentFollowersPage, completionHandler: { (result, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        self.followers += result!.0
                        self.isLastFollowersPage = result!.1
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.reloadData()
                            self.tableView.finishInfiniteScroll()
                        })
                    }
                })
            }
        }
    }
    var isFollowed = false
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if userProfile.uid != XAppDelegate.currentUser.uid {
            // BINH modify, we comment out all follow button for this ver sion, please don't delete
            
//            SocialManager.sharedInstance.isFollowing(userProfile.uid, followerId: XAppDelegate.currentUser.uid, completionHandler: { (result, error) -> Void in
//                if let _ = error {
//                    // Do not show newsfeed follow button
//                } else {
//                    self.isFollowed = result!["isfollowing"] as! Int == 1
//                    if self.isFollowed {
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            self.newsfeedFollowButton.setImage(UIImage(named: "follow_check_icon"), forState: .Normal)
//                        })
//                    } else {
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            self.newsfeedFollowButton.setImage(UIImage(named: "follow_btn"), forState: .Normal)
//                        })
//                    }
//                }
//            })
            noPostText = "This person has not posted anything."
            noUsersFollowingText = "This person has not followed anyone."
            noFollowersText = "This person does not have any follower."
        }
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            switch self.currentScope {
            case .Post:
                if self.isLastPostPage {
                    self.tableView.finishInfiniteScroll()
                    return
                }
                self.currentPostPage++
            case .Following:
                if self.isLastFollowingPage {
                    self.tableView.finishInfiniteScroll()
                    return
                }
                self.currentFollowingPage++
            case .Followers:
                if self.isLastFollowersPage {
                    self.tableView.finishInfiniteScroll()
                    return
                }
                self.currentFollowersPage++
            }
        }
        
        // Binh modify
        // hide follow button
        newsfeedFollowButton.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            if SocialManager.sharedInstance.isLoggedInZwigglers() {
                let label = "uid \(userProfile.uid)"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.profileOther, label: label)
                configureProfileView()
                getData()
                return
            }
        }
        navigationController?.popViewControllerAnimated(false)
    }
    
    // MARK: - Action
    
    override func handleRefresh(refreshControl: UIRefreshControl) {
        switch currentScope {
        case .Following:
            self.currentFollowingPage = 0
            self.isLastFollowingPage = false
        case .Followers:
            self.currentFollowersPage = 0
            self.isLastFollowersPage = false
        default:
             break
        }
        super.handleRefresh(refreshControl)
    }
    
    override func tapFollowingButton(sender: UIButton) {
        if currentScope != .Following {
            self.currentFollowingPage = 0
            self.isLastFollowingPage = false
        }
        super.tapFollowingButton(sender)
    }
    
    override func tapFollowersButton(sender: UIButton) {
        if currentScope != .Followers {
            self.currentFollowersPage = 0
            self.isLastFollowersPage = false
        }
        super.tapFollowersButton(sender)
    }
    
    @IBAction func tapBackButton(sender: UIButton) {
//        if isPushedFromNotification {
//            self.dismissViewControllerAnimated(true, completion: nil)
//        } else {
            navigationController?.popViewControllerAnimated(true)
//        }
        
    }
    
    @IBAction func tapFollowButton(sender: UIButton) {
        Utilities.showHUD()
        if isFollowed {
            SocialManager.sharedInstance.unfollow(userProfile, completionHandler: { (error) -> Void in
                if let error = error {
                    Utilities.hideHUD()
                    Utilities.showError(error, viewController: self)
                } else {
                    self.getUserProfileCounts()
                    DataStore.sharedInstance.checkFollowStatus(self.followers, completionHandler: { (error, shouldReload) -> Void in
                        if let error = error {
                            Utilities.hideHUD()
                            Utilities.showError(error, viewController: self)
                        } else {
                            self.isFollowed = !self.isFollowed
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.newsfeedFollowButton.setImage(UIImage(named: "follow_btn"), forState: .Normal)
                            })
                            Utilities.hideHUD()
                        }
                    })
                }
            })
        } else {
            SocialManager.sharedInstance.follow(userProfile, completionHandler: { (error) -> Void in
                if let error = error {
                    Utilities.hideHUD()
                    Utilities.showError(error, viewController: self)
                } else {
                    self.getUserProfileCounts()
                    DataStore.sharedInstance.checkFollowStatus(self.followers, completionHandler: { (error, shouldReload) -> Void in
                        if let error = error {
                            Utilities.hideHUD()
                            Utilities.showError(error, viewController: self)
                        } else {
                            self.isFollowed = !self.isFollowed
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.newsfeedFollowButton.setImage(UIImage(named: "follow_check_icon"), forState: .Normal)
                            })
                            Utilities.hideHUD()
                        }
                    })
                }
            })
        }
    }
    
    // MARK: - Configure UI
    
    override func configureProfileView() {
        super.configureProfileView()
        let sign = userProfile.sign
        if sign >= 0 {
            horoscopeSignLabel.hidden = false
            horoscopeSignImageView.hidden = false
            horoscopeSignView.hidden = false
            horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: sign)
            horoscopeSignImageView.image = Utilities.horoscopeSignIconImage(fromSignNumber: sign)
        } else {
            followButtonLeadingSpace.constant -= 50
            horoscopeSignLabel.hidden = true
            horoscopeSignImageView.hidden = true
            horoscopeSignView.hidden = true
        }
    }
    
    // MARK: - Helper
    
    override func getUsersFollowing(completionHandler: () -> Void) {
        SocialManager.sharedInstance.getProfilesOfUsersFollowing(forUser: userProfile.uid) { (result, error) -> Void in
            Utilities.hideHUD()
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                let users = result!.0
                self.noFollowingUser = users.count == 0
                if self.isDataUpdated(self.followingUsers, newData: users) {
                    self.followingUsers = users
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
            completionHandler()
        }
    }
    
    override func getFollowers(completionHandler: () -> Void) {
        SocialManager.sharedInstance.getProfilesOfFollowers(forUser: userProfile.uid) { (result, error) -> Void in
            Utilities.hideHUD()
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                let users = result!.0
                self.noFollower = users.count == 0
                if self.isDataUpdated(self.followers, newData: users) {
                    self.followers = users
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
            completionHandler()
        }
    }
    
    // MARK: - Delegate
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        controller.delegate = self
        navigationController?.presentViewController(controller, animated: false, completion: nil)
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
