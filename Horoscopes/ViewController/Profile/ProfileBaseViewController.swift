//
//  ProfileBaseViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileBaseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchViewControllerDelegate, FollowTableViewCellDelegate {
    
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
    @IBOutlet weak var locationLabel: UILabel!
    
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
    var noFollowingUser = false
    var noFollower = false
    var noPostText = ""
    var noUsersFollowingText = ""
    var noFollowersText = ""
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
    var topCorner: CAShapeLayer!
    var bottomCorner: CAShapeLayer!
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        horoscopeSignView!.layer.cornerRadius = 4
        horoscopeSignView!.clipsToBounds = true
        avatarImageView!.layer.cornerRadius = 60 / 2
        avatarImageView!.clipsToBounds = true
        
        
        let centerPoint = CGPoint(x: avatarImageView.frame.origin.x + avatarImageView.frame.size.width/2, y: avatarImageView.frame.origin.y + avatarImageView.frame.height/2)
        let radius = avatarImageView.frame.size.width/2 + 5
        let circleLayer = Utilities.layerForCircle(centerPoint, radius: radius, lineWidth: 1)
        circleLayer.fillColor = UIColor.clearColor().CGColor
        let color = UIColor(red: 227, green: 223, blue: 246, alpha: 1)
        circleLayer.strokeColor = color.CGColor
        profileView.layer.addSublayer(circleLayer)
        
        topCorner = CAShapeLayer()
        bottomCorner = CAShapeLayer()
        
        postButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followingButton.titleLabel?.textAlignment = NSTextAlignment.Center
        followersButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.infiniteScrollIndicatorStyle = .White
        tableView.addSubview(refreshControl)
        highlightScopeButton(postButton)
        
        tableView.registerClass(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "HeaderFooterView")
        
        tableView.clipsToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if userProfile.uid != -1 {
            self.getUserProfileCounts()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topCorner.path = UIBezierPath(roundedRect: profileView.bounds, byRoundingCorners: UIRectCorner.TopLeft.union(.TopRight), cornerRadii: CGSize(width: 4, height: 4)).CGPath
        profileView.layer.mask = topCorner
//        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC)))
//        bottomCorner.path = UIBezierPath(roundedRect: tableView.bounds, byRoundingCorners: UIRectCorner.BottomLeft.union(.BottomRight), cornerRadii: CGSize(width: 4, height: 4)).CGPath
//        dispatch_after(delayTime, dispatch_get_main_queue()) {
//            self.tableView.layer.mask = self.bottomCorner
//        }
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
        locationLabel.text = userProfile.location
    }
    
    func configureScopeButton() {
        postButton.setAttributedTitle(stringForTitle("Post", number: numberOfPosts), forState: .Normal)
        followingButton.setAttributedTitle(stringForTitle("Following", number: numberOfUsersFollowing), forState: .Normal)
        followersButton.setAttributedTitle(stringForTitle("Followers", number: numberOfFollowers), forState: .Normal)
    }
    
    private func stringForTitle(title: String, number: Int) -> NSMutableAttributedString {
        var font: UIFont
        if #available(iOS 8.2, *) {
            font = UIFont.systemFontOfSize(11, weight: UIFontWeightLight)
        } else {
            font = UIFont.systemFontOfSize(11)
        }
        var fontForNumber: UIFont
        if #available(iOS 8.2, *) {
            fontForNumber = UIFont.systemFontOfSize(15, weight: UIFontWeightMedium)
        } else {
            fontForNumber = UIFont.systemFontOfSize(15)
        }
        let attributes = [
            NSFontAttributeName: font
        ]
        let string = NSMutableAttributedString(attributedString: NSAttributedString(string: "\(title): \(number)", attributes: attributes))
        string.setAttributes([NSFontAttributeName: fontForNumber], range: NSMakeRange(title.characters.count + 2, String(number).characters.count))
        return string
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
    }
    
    func changeToWhiteTableViewLayout() {
        tableLeadingSpaceLayoutConstraint.constant = 10
        tableTrailingSpaceLayoutConstraint.constant = 10
        tableBottomSpaceLayoutConstraint.constant = 8
        tableView.backgroundColor = UIColor.whiteColor()
    }
    
    // MARK: - Action
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        switch currentScope {
        case .Post:
            currentPostPage = 0
            isLastPostPage = false
            getFeed(true, completionHandler: { () -> Void in
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
            tableView.allowsSelection = false
            tapScopeButton(sender)
            currentPostPage = 0
            isLastPostPage = false
            getFeed(completionHandler: { () -> Void in
                
            })
            tableView.layer.cornerRadius = 0
        }
    }
    
    @IBAction func tapFollowingButton(sender: UIButton) {
        if currentScope != .Following {
            currentScope = .Following
            tableView.allowsSelection = true
            tapScopeButton(sender)
            getUsersFollowing({ () -> Void in
                
            })
            tableView.layer.cornerRadius = 4
        }
    }
    
    @IBAction func tapFollowersButton(sender: UIButton) {
        if currentScope != .Followers {
            currentScope = .Followers
            tableView.allowsSelection = true
            tapScopeButton(sender)
            getFollowers({ () -> Void in
                
            })
            tableView.layer.cornerRadius = 4
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
    
    func getData() {
        getUserProfileCounts()
        switch currentScope {
        case .Post:
            getFeed(completionHandler: { () -> Void in
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
    
    func getFeed(isRefreshed: Bool = false, completionHandler: () -> Void) {
        if currentPostPage == 0 {
            SocialManager.sharedInstance.getUserFeed(userProfile.uid, page: currentPostPage, isRefreshed: isRefreshed, completionHandler: { (result, error) -> Void in
                if let error = error {
                    Utilities.showError(error, viewController: self)
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        let posts = result!.0
                        self.noPost = posts.count == 0
                        self.userPosts = posts
                        self.tableView.reloadData()
                    })
                }
                completionHandler()
            })
        }
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (currentScope == .Post && noPost) || (currentScope == .Following && noFollowingUser) || (currentScope == .Followers && noFollower) {
            return 26
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderFooterView")!
        switch currentScope {
        case .Post:
            view.textLabel!.text = noPostText
        case .Following:
            view.textLabel!.text = noUsersFollowingText
        case .Followers:
            view.textLabel!.text = noFollowersText
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
    
    func didChooseUser(profile: UserProfile) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
        controller.userProfile = profile
        presentedViewController?.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.navigationController?.pushViewController(controller, animated: true)
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
