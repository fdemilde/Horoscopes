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
    
    @IBOutlet weak var newsfeedFollowButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let textField = searchBar.valueForKey("searchField") as! UITextField
        textField.textColor = UIColor.whiteColor()
        searchBar.placeholder = "\(userProfile.name)"
        searchBar.setShowsCancelButton(false, animated: true)
        if userProfile.uid != XAppDelegate.currentUser.uid {
            SocialManager.sharedInstance.isFollowing(userProfile.uid, followerId: XAppDelegate.currentUser.uid, completionHandler: { (result, error) -> Void in
                if let _ = error {
                    // Do not show newsfeed follow button
                } else {
                    if result!["isfollowing"] as! Int != 1 {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.newsfeedFollowButton.hidden = false
                        })
                    }
                }
            })
        }
        Utilities.showHUD()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureProfileView()
        getData()
    }
    
    // MARK: - Action
    
    @IBAction func tapBackButton(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func tapFollowButton(sender: UIButton) {
        Utilities.showHUD()
        SocialManager.sharedInstance.follow(userProfile.uid, completionHandler: { (error) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(self, error: error)
            } else {
                self.getUserProfileCounts()
                self.getFollowers(nil)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.newsfeedFollowButton.removeFromSuperview()
                })
                Utilities.hideHUD()
            }
        })
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
            horoscopeSignImageView.image = Utilities.horoscopeSignImage(fromSignNumber: sign)
        } else {
            horoscopeSignLabel.hidden = true
            horoscopeSignImageView.hidden = true
            horoscopeSignView.hidden = true
        }
    }
    
    // MARK: - Helper
    
    override func getFollowingUsers(group: dispatch_group_t?) {
        if let group = group {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.getOtherUserFollowingProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                Utilities.showError(self, error: error)
            } else {
                self.handleData(group, oldData: &self.followingUsers, newData: result!, button: self.followingButton)
            }
            if let group = group {
                dispatch_group_leave(group)
            }
        })
    }
    
    override func getFollowers(group: dispatch_group_t?) {
        if let group = group {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.getOtherUserFollowersProfile(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                Utilities.showError(self, error: error)
            } else {
                self.handleData(group, oldData: &self.followers, newData: result!, button: self.followersButton)
            }
            if let group = group {
                dispatch_group_leave(group)
            }
        })
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
