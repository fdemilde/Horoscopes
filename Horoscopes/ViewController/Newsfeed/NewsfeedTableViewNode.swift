//
//  NewsfeedTableViewNode.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/7/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class NewsfeedTableViewNode : ASTableView, ASTableViewDataSource, ASTableViewDelegate, UIAlertViewDelegate {
    
    var userProfileArray = [UserProfile]()
    var userPostArray = [UserPost]()
    
//    convenience init() {
//        self.init(style: UITableViewStyle.Plain)
//        self.bounces = true
//        self.separatorStyle = UITableViewCellSeparatorStyle.None
//        self.backgroundColor = UIColor.clearColor()
//        self.showsHorizontalScrollIndicator = false
//        self.showsVerticalScrollIndicator = false
//        self.asyncDataSource = self
//        self.asyncDelegate =  self
//    }
    
    override init!(frame: CGRect, style: UITableViewStyle, asyncDataFetching asyncDataFetchingEnabled: Bool) {
        
        super.init(frame: frame, style: style, asyncDataFetching: asyncDataFetchingEnabled)
        self.bounces = true
        self.separatorStyle = UITableViewCellSeparatorStyle.None
        self.backgroundColor = UIColor.clearColor()
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.asyncDataSource = self
        self.asyncDelegate =  self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Table datasource and delegate
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        println("tableView tableView nodeForRowAtIndexPath \([indexPath.row])")
        var post = userPostArray[indexPath.row] as UserPost
        var cell = NewsfeedCellNode(post: post)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        println("numberOfSectionsInTableView numberOfSectionsInTableView")
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        println("numberOfRowsInSection numberOfRowsInSection \(userPostArray.count) ")
        return userPostArray.count
    }
    
    // MARK: Table Helpers
    
    func reloadTable(newDataArray : [UserPost]){
        
        self.userPostArray = newDataArray
        println("self.userPostArray self.userPostArray  = \(self.userPostArray)")
        dispatch_async(dispatch_get_main_queue(),{
            self.tableReloadDataWithAnimation()
            
        })
    }
    
    func tableReloadDataWithAnimation(){
        self.beginUpdates()
        var range = NSMakeRange(0, self.numberOfSections());
        var sections = NSIndexSet(indexesInRange: range);
        self.reloadSections(sections, withRowAnimation: UITableViewRowAnimation.None)
        self.endUpdates()
    }
}