//
//  AddFriendViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/27/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class AddFriendViewController : MyViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBackground: UIView!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchFBHolderLabel: UILabel!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    var friendList = [UserProfile]()
    var followingUsers = [UserProfile]()
    var parentVC : ProfileViewController!
    var followingCheckArray = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            self.loadFriendList()
        
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        
        searchBackground.layer.cornerRadius = 25 / 2
        searchBackground.layer.masksToBounds = true
        
    }
    
    // MARK: Setting and load data
    func loadFriendList(){
        Utilities.showHUD(viewToShow: self.view)
        XAppDelegate.socialManager.retrieveFriendList { (result, error) -> Void in
            if let error = error {
                println("retrieveFriendList error == \(error)")
            } else {
                dispatch_async(dispatch_get_main_queue(),{
                    self.friendList = result
                    // after get friend list, should loop through the list and check if user is following or not
                    
                    for user in self.friendList{
                        self.checkAndAddToFollowingArray(user.uid)
                    }
                    self.tableView.reloadData()
                    Utilities.hideHUD(viewToHide: self.view)
                })
            }
        }
        
    }
    
    // after get friend list, should loop through the list and check if user is following or not
    func checkAndAddToFollowingArray(uid : Int){
        for user in parentVC.followingUsers{
            if(user.uid == uid){
                followingCheckArray.append(true)
                return
            }
        }
        followingCheckArray.append(false)
    }
    
    // MARK: Table view delegate & data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return friendList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("AddFriendTableCell", forIndexPath: indexPath) as! AddFriendTableCell
        // need to update profile view controller when tap on follow button, we store its reference
        cell.setupCell(friendList[indexPath.row], isFollowing: followingCheckArray[indexPath.row], profileVC: parentVC)
        return cell
    }
    
    // MARK: Button action
    
    @IBAction func backButonTapped(sender: AnyObject) {
        mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
}