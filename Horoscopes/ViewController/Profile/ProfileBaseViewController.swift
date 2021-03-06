//
//  ProfileBaseViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


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
    @IBOutlet weak var locationLabel: UILabel!
    
    // MARK: - Property
    
    enum Scope {
        case post
        case following
        case followers
    }
    var currentScope = Scope.post
    var userProfile = UserProfile()
    var userPosts = [UserPost]()
    var followingUsers = [UserProfile]()
    var followers = [UserProfile]()
    var numberOfPosts = 0
    var numberOfUsersFollowing = 0
    var numberOfFollowers = 0
    var baseDispatchGroup: DispatchGroup!
    var noPost = false
    var noFollowingUser = false
    var noFollower = false
    var noPostText = ""
    var noUsersFollowingText = ""
    var noFollowersText = ""
    var needToRefreshFeed = false // this help when we need to refresh feed right at view did load
    var currentPostPage: Int = 0 {
        didSet {
            if currentPostPage != 0 {
                let label = "page = \(currentPostPage)"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.profileLoadmore, label: label)
                SocialManager.sharedInstance.getUserFeed(userProfile.uid, page: currentPostPage) { (result, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        let posts = result!.0
                        let isLastPage = result!.isLastPage
                        self.isLastPostPage = isLastPage
                        self.userPosts += posts
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.tableView.reloadData()
                            // TODO: remove this later
//                            self.tableView.finishInfiniteScroll()
//                            if let indexes = self.tableView.indexPathsForVisibleRows {
//                                let targetRow = indexes[indexes.count - 1].row
//                                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: targetRow, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
//                            }
                        })
                    }
                }
            }
        }
    }
    let postTypeText = [
        postTypes[NewsfeedType.howHoroscope]!.1,
        postTypes[NewsfeedType.shareAdvice]!.1,
        postTypes[NewsfeedType.onYourMind]!.1
    ]
    var isLastPostPage = false
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(ProfileBaseViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
        }()
    var topCorner: CAShapeLayer!
    var bottomCorner: CAShapeLayer!
    var lastContentOffset: CGFloat!
    
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
        circleLayer.fillColor = UIColor.clear.cgColor
        let color = UIColor(red: 227, green: 223, blue: 246, alpha: 1)
        circleLayer.strokeColor = color.cgColor
        profileView.layer.addSublayer(circleLayer)
        
        topCorner = CAShapeLayer()
        bottomCorner = CAShapeLayer()
        
        postButton.titleLabel?.textAlignment = NSTextAlignment.center
        followingButton.titleLabel?.textAlignment = NSTextAlignment.center
        followersButton.titleLabel?.textAlignment = NSTextAlignment.center
        highlightScopeButton(postButton)
        
        // Temporarily hide 2 button in header, disable post button
        postButton.isEnabled = false
        followingButton.isHidden = true
        followersButton.isHidden = true
        
        tableView.infiniteScrollIndicatorStyle = .white
        tableView.addSubview(refreshControl)
        
        tableView.register(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "HeaderFooterView")
        
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 4
        tableView.isPagingEnabled = true
        
        lastContentOffset = tableView.contentOffset.y
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        topCorner.path = UIBezierPath(roundedRect: profileView.bounds, byRoundingCorners: UIRectCorner.topLeft.union(.topRight), cornerRadii: CGSize(width: 4, height: 4)).cgPath
        profileView.layer.mask = topCorner
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configure UI
    
    func scrollToTop() {
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    func configureProfileView() {
        Utilities.getImageFromUrlString(userProfile.imgURL, completionHandler: { (image) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                self.avatarImageView.image = image
            })
        })
        nameLabel.text = userProfile.name
        locationLabel.text = userProfile.location
    }
    
    func configureScopeButton() {
        postButton.setAttributedTitle(stringForTitle("Post", number: numberOfPosts), for: UIControlState())
        followingButton.setAttributedTitle(stringForTitle("Following", number: numberOfUsersFollowing), for: UIControlState())
        followersButton.setAttributedTitle(stringForTitle("Followers", number: numberOfFollowers), for: UIControlState())
    }
    
    fileprivate func stringForTitle(_ title: String, number: Int) -> NSMutableAttributedString {
        var font: UIFont
        if #available(iOS 8.2, *) {
            font = UIFont.systemFont(ofSize: 11, weight: UIFontWeightLight)
        } else {
            font = UIFont.systemFont(ofSize: 11)
        }
        var fontForNumber: UIFont
        if #available(iOS 8.2, *) {
            fontForNumber = UIFont.systemFont(ofSize: 15, weight: UIFontWeightMedium)
        } else {
            fontForNumber = UIFont.systemFont(ofSize: 15)
        }
        let attributes = [
            NSFontAttributeName: font
        ]
        let string = NSMutableAttributedString(attributedString: NSAttributedString(string: "\(title): \(number)", attributes: attributes))
        string.setAttributes([NSFontAttributeName: fontForNumber], range: NSMakeRange(title.characters.count + 2, String(number).characters.count))
        return string
    }
    
    func highlightScopeButton(_ sender: UIButton) {
        for button in [postButton, followersButton, followingButton] {
            if button == sender {
                button?.alpha = 1
            } else {
                button?.alpha = 0.5
            }
        }
    }
    
    func changeToClearTableViewLayout() {
        tableLeadingSpaceLayoutConstraint.constant = 0
        tableTrailingSpaceLayoutConstraint.constant = 0
        tableBottomSpaceLayoutConstraint.constant = 0
        tableView.backgroundColor = UIColor.clear
    }
    
    func changeToWhiteTableViewLayout() {
        tableLeadingSpaceLayoutConstraint.constant = 8
        tableTrailingSpaceLayoutConstraint.constant = 8
        tableBottomSpaceLayoutConstraint.constant = 8
        tableView.backgroundColor = UIColor.white
    }
    
    // MARK: - Action
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        switch currentScope {
        case .post:
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.profileReload, label: nil)
            currentPostPage = 0
            isLastPostPage = false
            getFeed(true, completionHandler: { () -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    refreshControl.endRefreshing()
                })
            })
        case .following:
            getUsersFollowing({ () -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    refreshControl.endRefreshing()
                })
            })
        case .followers:
            getFollowers({ () -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    refreshControl.endRefreshing()
                })
            })
        }
    }
    
    @IBAction func tapPostButton(_ sender: UIButton) {
        if currentScope != .post {
            currentScope = .post
            tableView.allowsSelection = false
            tapScopeButton(sender)
            currentPostPage = 0
            isLastPostPage = false
            getFeed(completionHandler: { () -> Void in
                
            })
            tableView.isPagingEnabled = true
        }
    }
    
    @IBAction func tapFollowingButton(_ sender: UIButton) {
        if currentScope != .following {
            currentScope = .following
            tableView.allowsSelection = true
            tapScopeButton(sender)
            getUsersFollowing({ () -> Void in
                
            })
            tableView.isPagingEnabled = false
        }
    }
    
    @IBAction func tapFollowersButton(_ sender: UIButton) {
        if currentScope != .followers {
            currentScope = .followers
            tableView.allowsSelection = true
            tapScopeButton(sender)
            getFollowers({ () -> Void in
                
            })
            tableView.isPagingEnabled = false
        }
    }
    
    // MARK: - Convenience
    
    func tapScopeButton(_ sender: UIButton) {
        highlightScopeButton(sender)
        if currentScope != .post {
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
        case .post:
            getFeed(needToRefreshFeed, completionHandler: { () -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.isHidden = false
                    self.needToRefreshFeed = false
                })
            })
        case .following:
            getUsersFollowing({ () -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.isHidden = false
                })
            })
        case .followers:
            getFollowers({ () -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.isHidden = false
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
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.configureScopeButton()
                    })
                }
            }
        }
    }
    
    func getFeed(_ isRefreshed: Bool = false, completionHandler: @escaping () -> Void) {
        if currentPostPage == 0 {
            SocialManager.sharedInstance.getUserFeed(userProfile.uid, page: currentPostPage, isRefreshed: isRefreshed, completionHandler: { (result, error) -> Void in
                if let error = error {
                    Utilities.showError(error, viewController: self)
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
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
    
    func getUsersFollowing(_ completionHandler: () -> Void) {
        if followingUsers.count != numberOfUsersFollowing {
            Utilities.showHUD()
        }
        preconditionFailure("This method must be overridden")
    }
    
    func getFollowers(_ completionHandler: () -> Void) {
        if followers.count != numberOfFollowers {
            Utilities.showHUD()
        }
        preconditionFailure("This method must be overridden")
    }
    
    func isDataUpdated<T: Sequence>(_ oldData: T, newData: T) -> Bool {
        let oldDataIdSet = setOfDataId(oldData)
        let newDataIdSet = setOfDataId(newData)
        return oldDataIdSet != newDataIdSet
    }
    
    fileprivate func setOfDataId<T: Sequence>(_ data: T) -> Set<String> {
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.isScrollEnabled = true
        switch currentScope {
        case .post:
            if noPost {
                tableView.isScrollEnabled = false
                changeToWhiteTableViewLayout()
            } else {
                changeToClearTableViewLayout()
            }
            return userPosts.count
        case .following:
            return followingUsers.count
        case .followers:
            return followers.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentScope {
        case .post:
            let post = userPosts[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell", for: indexPath) as! PostTableViewCell
            cell.viewController = self
            cell.configureCellForProfile(post)
            if(indexPath.row == userPosts.count - 1){ // last row
                loadDataForNextPage()
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
            var profile: UserProfile
            cell.delegate = self
            if currentScope == .following {
                profile = followingUsers[indexPath.row]
            } else {
                profile = followers[indexPath.row]
            }
            cell.configureCell(profile)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if currentScope != .post {
            return 70
        }
        return tableView.frame.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var profile: UserProfile!
        if currentScope == .following {
            profile = followingUsers[indexPath.row]
        } else if currentScope == .followers {
            profile = followers[indexPath.row]
        }
        let controller = storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        controller.userProfile = profile!
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (currentScope == .post && noPost) || (currentScope == .following && noFollowingUser) || (currentScope == .followers && noFollower) {
            return 26
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderFooterView")!
        switch currentScope {
        case .post:
            view.textLabel!.text = noPostText
        case .following:
            view.textLabel!.text = noUsersFollowingText
        case .followers:
            view.textLabel!.text = noFollowersText
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel!.font = UIFont.systemFont(ofSize: 11)
        headerView.textLabel!.textColor = UIColor.gray
        headerView.contentView.backgroundColor = UIColor.white
    }
    
    // MARK: - Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrolledUp = lastContentOffset > scrollView.contentOffset.y ? 1 : 0
        let label = "up = \(isScrolledUp)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.profileSwipe, label: label)
        lastContentOffset = scrollView.contentOffset.y
    }
    
    func didChooseUser(_ profile: UserProfile) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        controller.userProfile = profile
        presentedViewController?.dismiss(animated: false, completion: { () -> Void in
            self.navigationController?.pushViewController(controller, animated: true)
        })
    }
    
    
    
    // MARK: Load Next Page
    
    func loadDataForNextPage(){
        if self.isLastPostPage || self.currentScope != .post {
            return
        }
        self.currentPostPage += 1
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
