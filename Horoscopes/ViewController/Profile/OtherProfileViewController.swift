//
//  OtherProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class OtherProfileViewController: ProfileBaseViewController {
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
//        navigationController?.view.backgroundColor = UIColor.redColor()
//        navigationController?.navigationBar.backgroundColor = UIColor.redColor()
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Bordered, target: self, action: "back")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureUi()
        getData()
    }
    
    // MARK: - Action
    
    @IBAction func tapBackButton(sender: UIButton) {
        navigationController?.popViewControllerAnimated(true)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
