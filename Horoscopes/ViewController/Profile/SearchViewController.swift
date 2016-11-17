//
//  SearchViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/4/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate {
    func didChooseUser(_ profile: UserProfile)
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
        tableView.register(UITableViewHeaderFooterView.classForCoder(), forHeaderFooterViewReuseIdentifier: "UITableViewHeaderFooterView")
        
        searchBar.tintColor = UIColor.white
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        textField.textColor = UIColor.white
        textField.layer.cornerRadius = 14
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.handleTap(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        SocialManager.sharedInstance.retrieveFriendList { (result, error) -> Void in
            if let error = error {
                DispatchQueue.main.async(execute: { () -> Void in
                    hud.hide(true)
                })
                Utilities.showError(error, viewController: self)
            } else {
                self.friends = result!
                if let users = DataStore.sharedInstance.usersFollowing {
                    for friend in self.friends {
                        for user in users {
                            if friend.uid == user.uid {
                                friend.isFollowed = true
                                break
                            }
                        }
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    hud.hide(true)
                })
            }
        }
        searchBar.becomeFirstResponder()
        if searchText == "" {
            filteredResult = DataStore.sharedInstance.recentSearchedProfile
            tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    
    func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - Table view data source and delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        cell.delegate = self
        let friend = filteredResult[indexPath.row]
        cell.profileNameLabel.text = friend.name
        cell.horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: friend.sign)
        Utilities.getImageFromUrlString(friend.imgURL, completionHandler: { (image) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                cell.profileImageView?.image = image
            })
        })
        
        // BINH modify: comment out all follow button, do not delete commented code
        // cell.configureFollowButton(friend.isFollowed, showFollowButton: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profile = filteredResult[indexPath.row]
        DataStore.sharedInstance.saveSearchedProfile(profile)
        delegate?.didChooseUser(profile)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchText == "" && filteredResult.count != 0 {
            return 26
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "UITableViewHeaderFooterView")!
        view.textLabel!.text = "Recent Searches"
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if section == 0 {
            let headerView = view as! UITableViewHeaderFooterView
            headerView.textLabel!.font = UIFont.systemFont(ofSize: 11)
            headerView.textLabel!.textColor = UIColor.gray
            headerView.contentView.backgroundColor = UIColor.white
        }
    }
    
    // MARK: - Delegate
    
    func didTapFollowButton(_ cell: FollowTableViewCell) {
        let index = tableView.indexPath(for: cell)?.row
        let user = filteredResult[index!]
        Utilities.showHUD(self.view)
        SocialManager.sharedInstance.follow(user, completionHandler: { (error) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(error, viewController: self)
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    user.isFollowed = true
                    cell.followButton.isHidden = true
                    self.tableView.reloadData()
                    Utilities.hideHUD(self.view)
                })
            }
        })
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filteredResult.removeAll(keepingCapacity: false)
        if searchText == "" {
            filteredResult = DataStore.sharedInstance.recentSearchedProfile
        } else {
            filteredResult = friends.filter({ $0.name.lowercased().range(of: searchText.lowercased()) != nil })
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        dismiss(animated: true, completion: nil)
    }

}
