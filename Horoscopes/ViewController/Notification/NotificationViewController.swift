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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 10
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : NotificationTableViewCell!
        cell = tableView.dequeueReusableCellWithIdentifier("NotificationTableViewCell", forIndexPath: indexPath) as! NotificationTableViewCell
        cell.populateData()
        if(indexPath.row % 2 == 1){
            cell.backgroundColor = UIColor(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: Title Hide/show
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        startPositionY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(scrollView.contentOffset.y <= 0){
            //            showTabbar(true)
            //            println("at top or over top of table view")
        } else if (scrollView.contentOffset.y + scrollView.frame.size.height >= scrollView.contentSize.height - 5) { // then we are at the end
            //            println("at the end of table view")
            //            showTabbar(true)
        } else if ((scrollView.contentOffset.y - startPositionY) > MIN_SCROLL_DISTANCE_TO_HIDE_TABBAR){
            //            println("scroll down")
            
        } else if ((startPositionY - scrollView.contentOffset.y) > MIN_SCROLL_DISTANCE_TO_HIDE_TABBAR){
            //            showTabbar(true)
            //            println("scroll up")
        }
    }
}
