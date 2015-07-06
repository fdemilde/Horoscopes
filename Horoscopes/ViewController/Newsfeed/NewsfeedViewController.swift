//
//  NewsfeedViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class NewsfeedViewController : UIViewController, ASTableViewDataSource, ASTableViewDelegate  {
    
    @IBOutlet weak var selectHoroscopeSignButton: UIButton!
    @IBOutlet weak var followingButton: UIButton!
    var userProfileArray = [UserProfile]()
    var userPostArray = [UserPost]()
    
    var feedsDisplayNode = ASDisplayNode()
    var tableView = ASTableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        self.setupTableView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshViewWithNewData:", name: NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
        XAppDelegate.socialManager.getGlobalNewsfeed(0)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(animated)
    }
    
    func setupTableView(){
        self.tableView = ASTableView(frame: CGRectMake(0, selectHoroscopeSignButton.frame.height + 40, Utilities.getScreenSize().width, Utilities.getScreenSize().height - 40), style: UITableViewStyle.Plain)
        tableView.bounces = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.asyncDataSource = self
        tableView.asyncDelegate =  self
        self.view.addSubview(tableView)
    }
    
    // MARK: layout
    
    
    // MARK: Table datasource and delegate
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        var post = userPostArray[indexPath.row] as UserPost
        var cell = NewsfeedCellNode(post: post)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return userPostArray.count
    }
    
    // MARK: Notification Handlers
    
    func refreshViewWithNewData(notif : NSNotification){
        var newDataArray = notif.object as! [UserPost]
        userPostArray = newDataArray
        self.tableView.reloadData()
    }
    
    // MARK: Button Actions
    
    @IBAction func selectSignBtnTapped(sender: AnyObject) {
    }
    
    @IBOutlet weak var followingButtonTapped: UIButton!
}