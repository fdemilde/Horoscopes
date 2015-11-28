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
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.tableView.finishInfiniteScroll()
                            self.tableView.reloadData()
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
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            }
        })
        
        tableView.addInfiniteScrollWithHandler { (scrollView) -> Void in
            _ = scrollView as! UITableView
            if self.isLastPostPage {
                self.tableView.finishInfiniteScroll()
                return
            }
            self.currentPostPage++
        }
    }
    
    // MARK: table view datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfile.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return TABLE_ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0,0,tableView.frame.size.width, HEADER_VIEW_HEIGHT))
        view.backgroundColor = UIColor(red: 133.0/255.0, green: 124/255.0, blue: 173/255.0, alpha: 1)
        let label = UILabel(frame: CGRectMake(0,0,100,100))
        label.font = UIFont(name: "HelveticaNeue", size: 11)
        
        var labelString = ""
        if(userProfile.count > 1){
            labelString = "\(userProfile.count) people like your post"
        } else {
            labelString = "\(userProfile.count) person likes your post"
        }
        label.text = labelString
        label.textColor = UIColor.whiteColor()
        label.sizeToFit()
        label.frame = CGRectMake((view.frame.size.width - label.frame.width) / 2, (view.frame.size.height - label.frame.height) / 2, label.frame.width, label.frame.height)
        view.addSubview(label)
        return view
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("FollowTableViewCell", forIndexPath: indexPath) as! FollowTableViewCell
            cell.delegate = self
            cell.profileNameLabel.text = userProfile[indexPath.row].name
            cell.horoscopeSignLabel.text = Utilities.horoscopeSignString(fromSignNumber: userProfile[indexPath.row].sign)
            Utilities.getImageFromUrlString(userProfile[indexPath.row].imgURL, completionHandler: { (image) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    cell.profileImageView?.image = image
                })
            })
            let isFollow = (userProfile[indexPath.row].isFollowed || userProfile[indexPath.row].uid == XAppDelegate.currentUser.uid) ? true : false
            cell.configureFollowButton(isFollow, showFollowButton: true)
            return cell
        }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("OtherProfileViewController") as! OtherProfileViewController
        controller.userProfile = userProfile[indexPath.row]
        parentVC.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
        parentVC.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HEADER_VIEW_HEIGHT
    }
    
    // MARK: cell delegate
    func didTapFollowButton(cell: FollowTableViewCell) {
        let index = tableView.indexPathForCell(cell)?.row
        let user = userProfile[index!]
        Utilities.showHUD(self.view)
        SocialManager.sharedInstance.follow(user, completionHandler: { (error) -> Void in
            if let error = error {
                Utilities.hideHUD()
                Utilities.showError(error, viewController: self)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    user.isFollowed = true
                    cell.followButton.hidden = true
                    self.tableView.reloadData()
                    Utilities.hideHUD(self.view)
                })
            }
        })
    }
}