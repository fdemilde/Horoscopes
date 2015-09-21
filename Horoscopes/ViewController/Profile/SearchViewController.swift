//
//  SearchViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/4/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate {
    func didChooseUser(profile: UserProfile)
}

class SearchViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FollowTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredResult = [UserProfile]()
    var friends = [UserProfile]()
    var searchText = ""
    var delegate: SearchViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        tableView.layer.cornerRadius = 4
        tableView.registerClass(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "UITableViewHeaderFooterView")
        
        searchBar.tintColor = UIColor.whiteColor()
        let textField = searchBar.valueForKey("searchField") as! UITextField
        textField.textColor = UIColor.whiteColor()
        textField.layer.cornerRadius = 14
        
        SocialManager.sharedInstance.retrieveFriendList { (result, error) -> Void in
            if let error = error {
                Utilities.showError(self, error: error)
            } else {
                self.friends = result!
            }
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
        if searchText == "" {
            filteredResult = DataStore.sharedInstance.recentSearchedProfile
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Action
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - Table view data source and delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResult.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
        cell.delegate = self
        cell.resetUi()
        let friend = filteredResult[indexPath.row]
        cell.profileNameLabel.text = friend.name
        cell.horoscopeSignLabel.text = friend.horoscopeSignString
        Utilities.getImageFromUrlString(friend.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.profileImageView?.image = image
            })
        })
        SocialManager.sharedInstance.isFollowing(friend.uid, followerId: XAppDelegate.currentUser.uid) { (result, error) -> Void in
            if let error = error {
                Utilities.showError(self, error: error)
            } else {
                let isFollowing = result!["isfollowing"] as! Int == 1
                if isFollowing {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.configureFollowButton(true, showFollowButton: true)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.configureFollowButton(false, showFollowButton: true)
                    })
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let profile = filteredResult[indexPath.row]
        DataStore.sharedInstance.saveSearchedProfile(profile)
        delegate.didChooseUser(profile)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchText == "" && filteredResult.count != 0 {
            return 26
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterViewWithIdentifier("UITableViewHeaderFooterView")!
        view.textLabel!.text = "Recent Searches"
        return view
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 0 {
            let headerView = view as! UITableViewHeaderFooterView
            headerView.textLabel!.font = UIFont.systemFontOfSize(11)
            headerView.textLabel!.textColor = UIColor.grayColor()
            headerView.contentView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    // MARK: - Delegate
    
    func didTapFollowButton(cell: FollowTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        let uid = filteredResult[index!].uid
        Utilities.showHUD()
        SocialManager.sharedInstance.follow(uid, completionHandler: { (error) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(self, error: error)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                    Utilities.hideHUD()
                })
            }
        })
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filteredResult.removeAll(keepCapacity: false)
        if searchText == "" {
            filteredResult = DataStore.sharedInstance.recentSearchedProfile
        } else {
            filteredResult = friends.filter({ $0.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil })
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
