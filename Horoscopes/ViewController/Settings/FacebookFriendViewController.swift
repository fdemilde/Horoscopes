//
//  FacebookFriendViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 12/22/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import UIKit

class FacebookFriendViewController: ViewControllerWithAds, UITableViewDelegate, UITableViewDataSource, FollowTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleBackgroundView: UIView!
    
    var friends = [UserProfile]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        titleBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
        titleBackgroundView.layer.shadowRadius = 2.0
        titleBackgroundView.layer.shadowColor = UIColor.black.cgColor
        titleBackgroundView.layer.shadowOpacity = 0.2
        // Do any additional setup after loading the view.
        tableView.layer.cornerRadius = 4
        tableView.rowHeight = 66
        showFriendList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        showFriendList()
    }
    
    func showFriendList() {
        Utilities.showHUD(self.view)
        SocialManager.sharedInstance.retrieveFriendList { (result, error) -> Void in
            
            if let error = error {
                Utilities.hideHUD(self.view)
                Utilities.showError(error)
            } else {
                let label = "no_friends = \(result!.count)"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbFriendsResult, label: label)
                self.friends = result!
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                })
                Utilities.hideHUD(self.view)
//                DataStore.sharedInstance.checkFollowStatus(self.friends, completionHandler: { (error, shouldReload) -> Void in
//                    if let error = error {
//                        Utilities.hideHUD(self.view)
//                        Utilities.showError(error)
//                    } else if shouldReload {
//                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                            Utilities.hideHUD(self.view)
//                            self.tableView.reloadData()
//                        })
//                    }
//                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
        let friend = friends[indexPath.row]
        cell.profileNameLabel.text = friend.name
        cell.horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: friend.sign)
        Utilities.getImageFromUrlString(friend.imgURL) { (image) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                cell.profileImageView.image = image
            })
        }
//        cell.configureFollowButton(friend.isFollowed, showFollowButton: true)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        controller.userProfile = friend
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func didTapFollowButton(_ cell: FollowTableViewCell) {
        let index = tableView.indexPath(for: cell)?.row
        let friend = friends[index!]
        Utilities.showHUD()
        SocialManager.sharedInstance.follow(friend) { (error) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(error)
            } else {
                friend.isFollowed = true
                DispatchQueue.main.async(execute: { () -> Void in
                    self.tableView.reloadData()
                })
                Utilities.hideHUD()
            }
        }
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
