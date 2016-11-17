//
//  LikeDetailTableViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 11/26/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class LikeDetailTableViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, FollowTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: SearchViewControllerDelegate!
    
    var postId = ""
    var userProfile = [UserProfile]()
    let TABLE_ROW_HEIGHT = 74 as CGFloat
    let HEADER_VIEW_HEIGHT = 40 as CGFloat
    var parentVC : UIViewController!
    var isLastPostPage = false
    var numberOfLike = 0
    
    var currentPostPage: Int = 0 {
        didSet {
            if currentPostPage != 0 {
                SocialManager.sharedInstance.retrieveUsersWhoLikedPost(self.postId, page: currentPostPage) { (result, error) -> Void in
                    if (error != "") {
                        Utilities.showAlert(self.parentVC, title: "Action Denied", message: "\(error)", error: nil)
                    } else {
                        let profiles = result!.0
                        let isLastPage = result!.isLastPage
                        self.isLastPostPage = isLastPage
                        self.userProfile += profiles
                        DispatchQueue.main.async(execute: { () -> Void in
                            self.tableView.reloadData()
                            self.tableView.finishInfiniteScroll()
                        })
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.layer.cornerRadius = 4
        
        DataStore.sharedInstance.checkFollowStatus(userProfile, completionHandler: { (error, shouldReload) -> Void in
            if let error = error {
                Utilities.showError(error, viewController: self)
            } else {
                if shouldReload {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
        })
        
        tableView.addInfiniteScroll { (scrollView) -> Void in
            _ = scrollView as! UITableView
            if self.isLastPostPage {
                self.tableView.finishInfiniteScroll()
                return
            }
            self.currentPostPage += 1
        }
    }
    
    // MARK: table view datasource and delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfile.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TABLE_ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0,y: 0,width: tableView.frame.size.width, height: HEADER_VIEW_HEIGHT))
        view.backgroundColor = UIColor(red: 133.0/255.0, green: 124/255.0, blue: 173/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 0,y: 0,width: 100,height: 100))
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        
        var labelString = ""
        if numberOfLike > 1 {
            labelString = "\(numberOfLike) people like your post"
        } else {
            labelString = "\(numberOfLike) person likes your post"
        }
        label.text = labelString
        label.textColor = UIColor.white
        label.sizeToFit()
        label.frame = CGRect(x: (view.frame.size.width - label.frame.width) / 2, y: (view.frame.size.height - label.frame.height) / 2, width: label.frame.width, height: label.frame.height)
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "FollowTableViewCell", for: indexPath) as! FollowTableViewCell
            cell.delegate = self
            cell.profileNameLabel.text = userProfile[indexPath.row].name
            cell.horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: userProfile[indexPath.row].sign)
            Utilities.getImageFromUrlString(userProfile[indexPath.row].imgURL, completionHandler: { (image) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    cell.profileImageView?.image = image
                })
            })
        
            // BINH modify: comment out all follow button, do not delete commented code
            // let isFollow = (userProfile[indexPath.row].isFollowed || userProfile[indexPath.row].uid == XAppDelegate.currentUser.uid) ? true : false
            // cell.configureFollowButton(isFollow, showFollowButton: true)
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "OtherProfileViewController") as! OtherProfileViewController
        controller.userProfile = userProfile[indexPath.row]
        parentVC.mz_dismissFormSheetController(animated: true, completionHandler:nil)
        parentVC.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_VIEW_HEIGHT
    }
    
    // MARK: cell delegate
    func didTapFollowButton(_ cell: FollowTableViewCell) {
        let index = tableView.indexPath(for: cell)?.row
        let user = userProfile[index!]
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
}
