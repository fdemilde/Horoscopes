//
//  ProfileBaseViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileBaseViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, SearchViewControllerDelegate, FollowTableViewCellDelegate {
    
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
    var numberOfPosts = 0
    var numberOfUsersFollowing = 0
    var numberOfFollowers = 0
    var baseDispatchGroup: dispatch_group_t!
    var noPost = false
    var currentPostPage: Int = 0 {
        didSet {
            if currentPostPage != 0 {
                SocialManager.sharedInstance.getUserFeed(userProfile.uid, page: currentPostPage) { (result, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        let posts = result!.0
                        let isLastPage = result!.isLastPage
                        self.isLastPostPage = isLastPage
                        self.userPosts += posts
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.finishInfiniteScroll()
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    let postTypeTexts = [
        "How do you feel today?",
        "Share your story",
        "What's on your mind?"
    ]
    var isLastPostPage = false
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
        }()
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        horoscopeSignView!.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        horoscopeSignView!.layer.cornerRadius = 4
        horoscopeSignView!.clipsToBounds = true
        avatarImageView!.layer.cornerRadius = 60 / 2
        avatarImageView!.clipsToBounds = true
        
        postButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followingButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followersButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.layer.cornerRadius = 4
        
        setupInfiniteScroll()
        tableView.addSubview(refreshControl)
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
            })
        })
        nameLabel.text = userProfile.name
    }
    
    func configureScopeButton() {
        postButton.setTitle("Post\n\(numberOfPosts)", forState: .Normal)
        followingButton.setTitle("Following\n\(numberOfUsersFollowing)", forState: .Normal)
        followersButton.setTitle("Followers\n\(numberOfFollowers)", forState: .Normal)
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
        tableView.allowsSelection = true
    }
    
    // MARK: - Action
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        switch currentScope {
        case .Post:
            getFeed({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    refreshControl.endRefreshing()
                })
            })
        case .Following:
            getUsersFollowing({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    refreshControl.endRefreshing()
                })
            })
        case .Followers:
            getFollowers({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    refreshControl.endRefreshing()
                })
            })
        }
    }
    
    @IBAction func tapPostButton(sender: UIButton) {
        if currentScope != .Post {
            currentScope = .Post
            tapScopeButton(sender)
            getFeed({ () -> Void in
                
            })
        }
    }
    
    @IBAction func tapFollowingButton(sender: UIButton) {
        if currentScope != .Following {
            currentScope = .Following
            tapScopeButton(sender)
            getUsersFollowing({ () -> Void in
                
            })
        }
    }
    
    @IBAction func tapFollowersButton(sender: UIButton) {
        if currentScope != .Followers {
            currentScope = .Followers
            tapScopeButton(sender)
            getFollowers({ () -> Void in
                
            })
        }
    }
    
    // MARK: - Convenience
    
    func tapScopeButton(sender: UIButton) {
        highlightScopeButton(sender)
        if currentScope != .Post {
            changeToWhiteTableViewLayout()
        } else {
            changeToClearTableViewLayout()
        }
        tableView.reloadData()
    }
    
    // MARK: - Helper
    
    func setupInfiniteScroll(){
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            _ = scrollView as! UITableView
            if self.isLastPostPage || self.currentScope != .Post {
                self.tableView.finishInfiniteScroll()
                return
            }
            self.currentPostPage++
        }
    }
    
    func getData() {
        getUserProfileCounts()
        switch currentScope {
        case .Post:
            getFeed({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.hidden = false
                })
            })
        case .Following:
            getUsersFollowing({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.hidden = false
                })
            })
        case .Followers:
            getFollowers({ () -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.hidden = false
                })
            })
        }
    }
    
    func getUserProfileCounts() {
        SocialManager.sharedInstance.getProfileCounts([userProfile.uid]) { (result, error) -> Void in
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                if !result!.isEmpty {
                    let count = result![0]
                    self.numberOfPosts = count.numberOfPosts
                    self.numberOfUsersFollowing = count.numberOfUsersFollowing
                    self.numberOfFollowers = count.numberOfFollowers
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.configureScopeButton()
                    })
                }
            }
        }
    }
    
    func getFeed(completionHandler: () -> Void) {
        SocialManager.sharedInstance.getUserFeed(userProfile.uid, completionHandler: { (result, error) -> Void in
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                self.currentPostPage = 0
                let posts = result!.0
                self.noPost = posts.count == 0
                if self.isDataUpdated(self.userPosts, newData: posts) {
                    self.userPosts = posts
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
            completionHandler()
        })
    }
    
    func getUsersFollowing(completionHandler: () -> Void) {
        preconditionFailure("This method must be overridden")
    }
    
    func getFollowers(completionHandler: () -> Void) {
        preconditionFailure("This method must be overridden")
    }
    
    func isDataUpdated<T: SequenceType>(oldData: T, newData: T) -> Bool {
        let oldDataIdSet = setOfDataId(oldData)
        let newDataIdSet = setOfDataId(newData)
        return oldDataIdSet != newDataIdSet
    }
    
    private func setOfDataId<T: SequenceType>(data: T) -> Set<String> {
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
            cell.viewController = self
            cell.configureCellForProfile(post)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
            var profile: UserProfile
            cell.delegate = self
            if currentScope == .Following {
                profile = followingUsers[indexPath.row]
            } else {
                profile = followers[indexPath.row]
            }
            cell.configureCell(profile)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if currentScope == .Post {
            // BINH BINH: check this again, it crashes, this is temporary fix
            if let cell = cell as? PostTableViewCell {
                // -----------------
                let post = userPosts[indexPath.row]
                switch post.type {
                case .OnYourMind:
                    cell.postTypeShadowUpper.backgroundColor = UIColor.newsfeedMindColor()
                    cell.postTypeShadowLower.backgroundColor = UIColor.newsfeedMindColorWithOpacity()
                case .Feeling:
                    cell.postTypeShadowUpper.backgroundColor = UIColor.newsfeedFeelColor()
                    cell.postTypeShadowLower.backgroundColor = UIColor.newsfeedFeelColorWithOpacity()
                case .Story:
                    cell.postTypeShadowUpper.backgroundColor = UIColor.newsfeedStoryColor()
                    cell.postTypeShadowLower.backgroundColor = UIColor.newsfeedStoryColorWithOpacity()
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if currentScope != .Post {
            return 70
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var profile: UserProfile!
        if currentScope == .Following {
            profile = followingUsers[indexPath.row]
        } else if currentScope == .Followers {
            profile = followers[indexPath.row]
        }
        let controller = storyboard?.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
        controller.userProfile = profile!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Delegate
    
    func didChooseUser(profile: UserProfile) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
        controller.userProfile = profile
        presentedViewController?.dismissViewControllerAnimated(false, completion: { () -> Void in
            navigationController?.pushViewController(controller, animated: true)
        })
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
