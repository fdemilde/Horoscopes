//
//  ProfileBaseViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileBaseViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlet
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var horoscopeSignImageView: UIImageView!
    @IBOutlet weak var horoscopeSignLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var horoscopeSignView: UIView!
    @IBOutlet weak var tableLeadingSpaceLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableTrailingSpaceLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomSpaceLayoutConstraint: NSLayoutConstraint!
    
    // MARK: - Property
    
    enum Scope {
        case Post
        case Following
        case Followers
    }
    var currentScope = Scope.Post
    var userProfile = UserProfile()
    var userPosts = [UserPost]()
    var followingUsers = [UserProfile]()
    var followers = [UserProfile]()
    let dispatchGroup = dispatch_group_create()
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configure UI
    
    func configureProfileView() {
        Utilities.getImageFromUrlString(userProfile.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.avatarImageView.image = image
                self.avatarImageView.layer.cornerRadius = 60 / 2
                self.avatarImageView.clipsToBounds = true
            })
        })
        nameLabel.text = userProfile.name
        horoscopeSignView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        horoscopeSignView.layer.cornerRadius = 4
        horoscopeSignView.clipsToBounds = true
        horoscopeSignLabel.text = userProfile.horoscopeSignString
        horoscopeSignImageView.image = userProfile.horoscopeSignImage
    }
    
    func configureTabButton() {
        postButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followersButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followingButton.titleLabel?.textAlignment = NSTextAlignment.Center
    }
    
    func configureTableView() {
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.layer.cornerRadius = 4
    }
    
    func highlightScopeButton(sender: UIButton) {
        for button in [postButton, followersButton, followingButton] {
            if button == sender {
                button.alpha = 1
            } else {
                button.alpha = 0.5
            }
        }
    }
    
    func setScopeButtonTitleLabel(sender: UIButton) {
        if sender == postButton {
            postButton.setTitle("Post\n\(userPosts.count)", forState: .Normal)
        } else if sender == followingButton {
            followingButton.titleLabel?.text = "Following\n\(followingUsers.count)"
            followingButton.setTitle("Following\n\(followingUsers.count)", forState: .Normal)
        } else {
            followersButton.titleLabel?.text = "Followers\n\(followers.count)"
            followersButton.setTitle("Followers\n\(followers.count)", forState: .Normal)
        }
    }
    
    func configurePostTableViewCell(cell: PostTableViewCell, post: UserPost) {
        cell.configureUserPostUi()
        switch post.type {
        case .OnYourMind:
            cell.headerView.backgroundColor = UIColor.newsfeedMindColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_mind")
        case .Feeling:
            cell.headerView.backgroundColor = UIColor.newsfeedFeelColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_feel")
        case .Story:
            cell.headerView.backgroundColor = UIColor.newsfeedStoryColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_story")
        }
        cell.postDateLabel.text = Utilities.getDateStringFromTimestamp(NSTimeInterval(post.ts), dateFormat: NewProfileViewController.postDateFormat)
        cell.textView.text = post.message
    }
    
    func configureFollowTableViewCell(cell: FollowTableViewCell, profile: UserProfile) {
        cell.profileNameLabel.text = profile.name
        cell.horoscopeSignLabel.text = profile.horoscopeSignString
        Utilities.getImageFromUrlString(profile.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.profileImageView?.image = image
            })
        })
    }
    
    func changeToClearTableViewLayout() {
        tableLeadingSpaceLayoutConstraint.constant = 0
        tableTrailingSpaceLayoutConstraint.constant = 0
        tableBottomSpaceLayoutConstraint.constant = 0
        tableView.backgroundColor = UIColor.clearColor()
        tableView.allowsSelection = false
    }
    
    func changeToWhiteTableViewLayout() {
        tableLeadingSpaceLayoutConstraint.constant = 10
        tableTrailingSpaceLayoutConstraint.constant = 10
        tableBottomSpaceLayoutConstraint.constant = 8
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.allowsSelection = false
    }
    
    // MARK: - Action
    
    @IBAction func tapPostButton(sender: UIButton) {
        currentScope = .Post
        highlightScopeButton(sender)
        updateTableViewLayout()
        tableView.reloadData()
        getUserPosts(nil)
    }
    
    @IBAction func tapFollowingButton(sender: UIButton) {
        currentScope = .Following
        highlightScopeButton(sender)
        updateTableViewLayout()
        tableView.reloadData()
        getFollowingUsers(nil)
    }
    
    @IBAction func tapFollowersButton(sender: UIButton) {
        currentScope = .Followers
        highlightScopeButton(sender)
        updateTableViewLayout()
        tableView.reloadData()
        getFollowers(nil)
    }
    
    // MARK: - Convenience
    
    func configureUi() {
        configureProfileView()
        configureTabButton()
        configureTableView()
    }
    
    func configureUiAndGetData() {
        configureUi()
        getData()
    }
    
    func updateTableViewLayout() {
        if currentScope != .Post {
            changeToWhiteTableViewLayout()
        } else {
            changeToClearTableViewLayout()
        }
    }
    
    // MARK: - Helper
    
    func getData() {
        Utilities.showHUD()
        getUserPosts(dispatchGroup)
        getFollowingUsers(dispatchGroup)
        getFollowers(dispatchGroup)
//        getFriends(group)
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue()) { () -> Void in
            self.tableView.hidden = false
            Utilities.hideHUD()
        }
    }
    
    func getUserPosts(dispatchGroup: dispatch_group_t?) {
        if let group = dispatchGroup {
            dispatch_group_enter(group)
        }
        SocialManager.sharedInstance.getUserFeed(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                Utilities.showError(self, error: error)
            } else {
                self.handleData(dispatchGroup, oldData: &self.userPosts, newData: result!, button: self.postButton)
            }
            if let group = dispatchGroup {
                dispatch_group_leave(group)
            }
        })
    }
    
    func getFollowingUsers(dispatchGroup: dispatch_group_t?) {
        preconditionFailure("This method must be overridden")
    }
    
    func getFollowers(dispatchGroup: dispatch_group_t?) {
        preconditionFailure("This method must be overridden")
    }
    
    func handleData<T: SequenceType>(group: dispatch_group_t?, inout oldData: T, newData: T, button: UIButton) {
        if isDataUpdated(oldData, newData: newData) {
            oldData = newData
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.setScopeButtonTitleLabel(button)
                self.tableView.reloadData()
            })
        }
    }
    
    func isDataUpdated<T: SequenceType>(oldData: T, newData: T) -> Bool {
        let oldDataIdSet = getDataIds(oldData)
        let newDataIdSet = getDataIds(newData)
        return oldDataIdSet != newDataIdSet
    }
    
    func getDataIds<T: SequenceType>(data: T) -> Set<String> {
        var result = Set<String>()
        for item in data {
            if let post = item as? UserPost {
                result.insert(post.post_id)
            } else if let profile = item as? UserProfile {
                result.insert("\(profile.uid)")
            }
        }
        return result
    }
    
    func checkFollowStatus() {
        for follower in followers {
            for followingUser in followingUsers {
                if followingUser.uid == follower.uid {
                    follower.isFollowed = true
                    break
                }
            }
        }
    }

    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentScope {
        case .Post:
            return userPosts.count
        case .Following:
            return followingUsers.count
        case .Followers:
            return followers.count
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch currentScope {
        case .Post:
            let post = userPosts[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
//            cell.delegate = self
            configurePostTableViewCell(cell, post: post)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
            //            cell.delegate = self
            var profile: UserProfile
            if currentScope == .Following {
                profile = followingUsers[indexPath.row]
            } else {
                profile = followers[indexPath.row]
            }
            configureFollowTableViewCell(cell, profile: profile)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if currentScope != .Post {
            return 70
        }
        return UITableViewAutomaticDimension
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
