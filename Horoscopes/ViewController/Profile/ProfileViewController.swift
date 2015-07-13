//
//  ProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    
    var profileTableView: ASTableView!
    
    var userPosts = [UserPost]()
    enum Tab {
        case Post
        case Followers
        case Following
    }
    var followingUsers = [UserProfile]()
    var followers = [UserProfile]()
    var currentTab = Tab.Post

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        postButton.titleLabel?.numberOfLines = 2
        followersButton.titleLabel?.numberOfLines = 2
        followingButton.titleLabel?.numberOfLines = 2
        configureProfileTableView()
        view.addSubview(profileTableView)
        
        reloadPostDataSource()
        reloadFollowersDataSource()
        reloadFollowingDataSource()
        
//        SocialManager.sharedInstance.follow(userWithId: 3) { (result, error) -> Void in
//            
//        }
    }
    
    override func viewWillLayoutSubviews() {
        profileTableView.frame = CGRectMake(0, postButton.frame.origin.y + postButton.frame.height, view.frame.width, view.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    @IBAction func touchPostButton(sender: UIButton) {
        currentTab = .Post
        reloadPostDataSource()
    }
    
    @IBAction func touchFollowersButton(sender: UIButton) {
        currentTab = .Followers
        reloadFollowersDataSource()
    }
    
    @IBAction func touchFollowingButton(sender: UIButton) {
        currentTab = .Following
        reloadFollowingDataSource()
    }
    
    // MARK: ConfigureUI
    func configureProfileTableView() {
        profileTableView = ASTableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        profileTableView.asyncDataSource = self
        profileTableView.asyncDelegate = self
        profileTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        profileTableView.backgroundColor = UIColor.clearColor()
        profileTableView.showsHorizontalScrollIndicator = false
        profileTableView.showsVerticalScrollIndicator = false
    }
    
    // MARK: Helper
    func getUserId() -> NSNumber {
        if XAppDelegate.mobilePlatform.userCred.hasToken() {
            return XAppDelegate.mobilePlatform.userCred.getUid()
        } else {
            return -1
        }
    }
    
    func reloadPostDataSource() {
        let uid = getUserId()
        if uid != -1 {
            userPosts.removeAll(keepCapacity: false)
            SocialManager.sharedInstance.getPost(Int(uid), completionHandler: { (result, error) -> Void in
                if let error = error {
                    NSLog("Cannot load user's posts. Error: \(error)")
                } else {
                    let users = result!["users"] as! Dictionary<String, AnyObject>
                    if let posts = result!["posts"] as? Array<AnyObject> {
                        for post in posts {
                            let userPost = UserPost(data: post as! NSDictionary)
                            userPost.user = UserProfile(data: users["\(uid)"] as! NSDictionary)
                            self.userPosts.append(userPost)
                        }
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.postButton.setTitle("Post\n\(self.userPosts.count)", forState: UIControlState.Normal)
                            self.profileTableView.reloadData()
                        })
                    }
                }
            })
        }
    }
    
    func reloadFollowersDataSource() {
        let uid = getUserId()
        if uid != -1 {
            SocialManager.sharedInstance.getFollowers({ (result, error) -> () in
                if let error = error {
                    NSLog("Cannot get followers. Error: \(error)")
                } else {
                    if let followersId = result!["followers"] as? Array<Int> {
                        let followersIdString = followersId.map({"\($0)"})
                        SocialManager.sharedInstance.getProfile(usersIdSeparatedByComma: ",".join(followersIdString), completionHandler: { (result, error) -> Void in
                            if let error = error {
                                NSLog("Cannot get followers. Error: \(error)")
                            } else {
                                for id in followersId {
                                    if let users = result!["result"] as? Dictionary<String, AnyObject> {
                                        let userProfile = UserProfile(data: users[String(id)] as! NSDictionary)
                                        self.followers.append(userProfile)
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.followersButton.setTitle("Followers\n\(self.followers.count)", forState: UIControlState.Normal)
                                    self.profileTableView.reloadData()
                                })
                            }
                        })
                    }
                }
            })
        }
    }
    
    func reloadFollowingDataSource() {
        let uid = getUserId()
        if uid != -1 {
            followingUsers.removeAll(keepCapacity: false)
            SocialManager.sharedInstance.getFollowing({ (result, error) -> () in
                if let error = error {
                    NSLog("Cannot get following users. Error: \(error)")
                } else {
                    if let followingUsersId = result!["following"] as? Array<Int> {
                        let followingUsersIdString = followingUsersId.map({"\($0)"})
                        SocialManager.sharedInstance.getProfile(usersIdSeparatedByComma: ",".join(followingUsersIdString), completionHandler: { (result, error) -> Void in
                            if let error = error {
                                NSLog("Cannot get profile. Error: \(error)")
                            } else {
                                for id in followingUsersId {
                                    if let users = result!["result"] as? Dictionary<String, AnyObject> {
                                        let userProfile = UserProfile(data: users[String(id)] as! NSDictionary)
                                        self.followingUsers.append(userProfile)
                                    }
                                }
                                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                    self.followingButton.setTitle("Following\n\(self.followingUsers.count)", forState: UIControlState.Normal)
                                    self.profileTableView.reloadData()
                                })
                            }
                        })
                    }
                }
            })
        }
    }
    
    // MARK: Datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentTab {
        case .Followers:
            return followers.count
        case .Following:
            return followingUsers.count
        default:
            return userPosts.count
        }
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let cellObject = userPosts[indexPath.row] as UserPost
        return ProfileCellNode(cellObject: cellObject, type: .Post)
        // TODO: Implement table cell layout for followers and following then uncomment.
//        let cellObject: AnyObject
//        let cell: ASCellNode
//        switch currentTab {
//        case .Followers:
//            cellObject = followers[indexPath.row] as UserProfile
//            cell = ProfileCellNode(cellObject: cellObject, type: .Followers)
//        case .Following:
//            cellObject = followingUsers[indexPath.row] as UserProfile
//            cell = ProfileCellNode(cellObject: cellObject, type: .Following)
//        default:
//            cellObject = userPosts[indexPath.row] as UserPost
//            cell = ProfileCellNode(cellObject: cellObject, type: .Post)
//        }
//        return cell
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
