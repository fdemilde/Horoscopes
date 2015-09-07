//
//  SearchViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/4/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var filteredResult = [UserProfile]()
    var friends = [UserProfile]()
    var searchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
        tableView.layer.cornerRadius = 4
        
        searchBar.tintColor = UIColor.whiteColor()
        let textField = searchBar.valueForKey("searchField") as! UITextField
        textField.textColor = UIColor.whiteColor()
        searchBar.becomeFirstResponder()
        
        SocialManager.sharedInstance.retrieveFriendList { (result, error) -> Void in
            if let error = error {
                
            } else {
                self.friends = result!
                self.filteredResult.removeAll(keepCapacity: false)
                self.filteredResult = self.friends.filter({ $0.name.lowercaseString.rangeOfString(self.searchText.lowercaseString) != nil })
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
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
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResult.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
        let friend = filteredResult[indexPath.row]
        cell.profileNameLabel.text = friend.name
        cell.horoscopeSignLabel.text = friend.horoscopeSignString
        Utilities.getImageFromUrlString(friend.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.profileImageView?.image = image
            })
        })
        return cell
    }
    
    // MARK: - Delegate
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filteredResult.removeAll(keepCapacity: false)
        filteredResult = friends.filter({ $0.name.lowercaseString.rangeOfString(searchText.lowercaseString) != nil })
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
