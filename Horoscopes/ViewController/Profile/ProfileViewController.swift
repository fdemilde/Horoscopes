//
//  ProfileViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    
    var tableView: ASTableView!
    var userPosts = [UserPost]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupTableView()
        self.view.addSubview(tableView)
        // TODO: - Populate user post
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupTableView() {
        tableView = ASTableView(frame: CGRectZero, style: UITableViewStyle.Plain)
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
//        println("numberOfRowsInSection numberOfRowsInSection \(userPostArray.count) ")
        return userPosts.count
    }
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        let userPost = userPosts[indexPath.row] as UserPost
        let cell = PostCellNode(userPost: userPost)
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
