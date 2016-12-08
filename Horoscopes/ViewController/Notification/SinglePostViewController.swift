//
//  SinglePostViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 9/3/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class SinglePostViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var userPost : UserPost!
    let PADDING = 20 as CGFloat
    let HEADER_HEIGHT: CGFloat = 130 as CGFloat
    let FOOTER_HEIGHT: CGFloat = 80 as CGFloat
    
    let defaultEstimatedRowHeight: CGFloat = 400
    var comments = [UserPostComment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        let label = "post_id = \(userPost.post_id)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.singlePostOpen, label: label)
        
        
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
        getComments()
    }
    
    
    // MARK: Setup View
    func setupView(){
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
    }
    
    // MARK: - Table view data source and delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return getAboutCellHeight(userPost.message)
        } else if indexPath.row == 1 {
            return 50
        } else {
            return 170
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + comments.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePostTableViewCell", for: indexPath) as! PostTableViewCell
            cell.configureCellForNewsfeed(userPost)
            cell.viewController = self
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentBtnTVC", for: indexPath) as! CommentBtnTVC
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTVC", for: indexPath) as! CommentTVC
            let comment = comments[indexPath.row - 2]
            cell.configureCell(userComment: comment)
            return cell
        }
        
    }

    
    // MARK: Table Cell Helpers
    
    func getAboutCellHeight(_ text : String) -> CGFloat {
        let font = UIFont(name: "Book Antiqua", size: 14)
        let attrs = NSDictionary(object: font!, forKey: NSFontAttributeName as NSCopying)
        let string = NSMutableAttributedString(string: text, attributes: attrs as? [String : AnyObject])
        let textViewWidth = Utilities.getScreenSize().width - (PADDING * 2)
        let textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        return textViewHeight + HEADER_HEIGHT + FOOTER_HEIGHT + PADDING * 3
    }
    
    func calculateTextViewHeight(_ string: NSAttributedString, width: CGFloat) ->CGFloat {
        let textviewForCalculating = UITextView()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let att = string.mutableCopy() as! NSMutableAttributedString
        att.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, att.string.utf16.count))
        textviewForCalculating.attributedText = att
        let size = textviewForCalculating.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let height = ceil(size.height)
        return height
    }
    
    func getComments() {
        let post_id = self.userPost.post_id
        
        SocialManager.sharedInstance.postGetComments(post_id, page: 0) { (comments, error) in
            if error != nil {
                print(error)
            } else {
                guard let comments = comments else { return }
                self.comments = comments
                self.tableView.reloadData()
            }
        }
        
    }
    
//    // MARK: infinite scrolling support
//    func insertRowsAtBottom(_ newData : [UserPost]){
//        self.tableView.beginUpdates()
//        let deltaCalculator = BKDeltaCalculator(equalityTest: { (post1 , post2) -> Bool in
//            let p1 = post1 as! UserPost
//            let p2 = post2 as! UserPost
//            return (p1.post_id == p2.post_id);
//        })
//        
//        let delta = deltaCalculator?.delta(fromOldArray: XAppDelegate.dataStore.newsfeedGlobal, toNewArray:newData)
//        delta?.applyUpdates(to: self.tableView,inSection:0,with:UITableViewRowAnimation.middle)
//        XAppDelegate.dataStore.newsfeedGlobal = newData
//        self.tableView.endUpdates()
//        if let indexes = tableView.indexPathsForVisibleRows {
//            let targetRow = indexes[indexes.count - 1].row
//            tableView.scrollToRow(at: IndexPath(row: targetRow, section: 0), at: UITableViewScrollPosition.top, animated: true)
//        }
//    }
//    
//    // MARK: Helpers
//    
//    func setupInfiniteScroll(){
//        tableView.infiniteScrollIndicatorStyle = .white
//        tableView.addInfiniteScroll { (scrollView) -> Void in
//            
//            if(XAppDelegate.dataStore.isLastPage){
//                self.tableView.finishInfiniteScroll()
//                return
//            } // last page dont need to request more
//            let label = "page = \(self.currentPage)"
//            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commLoadmore, label: label)
//            self.tableView.finishInfiniteScroll()
//        }
//    }
//    
//    func loadDataForNextPage(){
//        if(XAppDelegate.dataStore.isLastPage){
//            return
//        }
//        self.currentPage += 1
//        let label = "page = \(self.currentPage)"
//        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commLoadmore, label: label)
//        XAppDelegate.socialManager.getGlobalNewsfeed(self.currentPage, isAddingData: true)
//    }
//    
//    func handleRefresh(_ refreshControl: UIRefreshControl) {
//        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.commReload, label: nil)
//        self.currentPage = 0
//        XAppDelegate.socialManager.getGlobalNewsfeed(0, isAddingData: false, isRefreshing : true)
//        NotificationCenter.default.addObserver(self, selector: #selector(AlternateCommunityViewController.feedsFinishedLoading(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED), object: nil)
//        
//        tableView.reloadData()
//        refreshControl.endRefreshing()
//    }
//    
//    // func check page 0 cache
//    
//    func isFirstPageExpired() -> Bool {
//        let postData = NSMutableDictionary()
//        let pageString = String(format:"%d", 0)
//        postData.setObject(pageString, forKey: "page" as NSCopying)
//        if(CacheManager.isCacheExpired(GET_GLOBAL_FEED, postData: postData)){
//            return true
//        } else {
//            return false
//        }
//        
//    }
//    
//    func scrollToTop() {
//        tableView.setContentOffset(CGPoint.zero, animated: true)
//    }
    
    // MARK: Button Actions
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
