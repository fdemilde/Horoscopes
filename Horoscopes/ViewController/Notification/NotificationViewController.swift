//
//  NotificationTableViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NotificationViewController: MyViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let MIN_SCROLL_DISTANCE_TO_HIDE_TABBAR = 30 as CGFloat
    var startPositionY = 0 as CGFloat
    var notifArray = [NotificationObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        
        XAppDelegate.socialManager.getAllNotification(0, completionHandler: { (result) -> Void in
            self.notifArray = result!
            self.tableView.reloadData()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : NotificationTableViewCell!
        cell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as! NotificationTableViewCell
        cell.populateData(notifArray[indexPath.row])
        if(indexPath.row % 2 == 1){
            cell.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            var notifCell = cell as! NotificationTableViewCell
//            XAppDelegate.
            println("cell route == \(notifCell.notification.route)")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: Button actions
    
    @IBAction func refreshButtonTapped(sender: AnyObject) {
        XAppDelegate.socialManager.getAllNotification(0, completionHandler: { (result) -> Void in
            
//            println("getAllNotification result = \(result)")
        })
    }
    
    @IBAction func clearAllTapped(sender: AnyObject) {
        XAppDelegate.socialManager.clearAllNotification()
    }
    
}
