//
//  LikeDetailTableViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 11/26/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class LikeDetailTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var postId = ""
    var userProfile = [UserProfile]()
    
    var currentPostPage: Int = 0 {
        didSet {
            if currentPostPage != 0 {
                SocialManager.sharedInstance.retrieveUsersWhoLikedPost(self.postId, page: currentPostPage) { (result, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        //                        let posts = result!.0
                        //                        let isLastPage = result!.isLastPage
                        //                        self.isLastPostPage = isLastPage
                        //                        self.userPosts += posts
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.finishInfiniteScroll()
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        tableView.layer.cornerRadius = 4
        
        
    }
    
    // MARK: table view datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            return UITableViewCell()
        }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}