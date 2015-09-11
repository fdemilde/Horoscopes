//
//  SinglePostViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 9/3/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class SinglePostViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, PostTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var userPost : UserPost!
    
    @IBOutlet weak var navigationView: UIView!
    let defaultEstimatedRowHeight: CGFloat = 400
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: Setup View
    func setupView(){
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        navigationView.layer.shadowOffset = CGSize(width: 0, height: 3)
        navigationView.layer.shadowOpacity = 0.2
        navigationView.layer.shadowRadius = 1
        tableView.estimatedRowHeight = defaultEstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    // MARK: - Table view data source and delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        cell.delegate = self
        if let post = userPost {
            configureCell(cell, post: userPost)
        }
        
        return cell
    }
    
    // MARK: configuration
    
    func configureCell(cell: PostTableViewCell, post: UserPost) {
        switch post.type {
        case .OnYourMind:
            cell.profileView.backgroundColor = UIColor.newsfeedMindColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_mind")
        case .Feeling:
            cell.profileView.backgroundColor = UIColor.newsfeedFeelColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_feel")
        case .Story:
            cell.profileView.backgroundColor = UIColor.newsfeedStoryColor()
            cell.postTypeImageView.image = UIImage(named: "post_type_story")
        }
        cell.postDateLabel.text = Utilities.getDateStringFromTimestamp(NSTimeInterval(post.ts), dateFormat: NewProfileViewController.postDateFormat)
        cell.textView.text = post.message
        Utilities.getImageFromUrlString(post.user!.imgURL, completionHandler: { (image) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.profileImageView.image = image
            })
        })
        cell.profileNameLabel.text = post.user?.name
        cell.configureNewsfeedUi(nil)
    }
    
    // MARK: - Post Cell Delegate
    
    func didTapShareButton(cell: PostTableViewCell) {
        let name = userPost.user!.name
        let postContent = userPost.message
        let sharingText = String(format: "%@ \n %@", name, postContent)
        let controller = Utilities.shareViewControllerForType(ShareViewType.ShareViewTypeHybrid, shareType: ShareType.ShareTypeNewsfeed, sharingText: sharingText)
        Utilities.presentShareFormSheetController(self, shareViewController: controller)
    }
    
    // MARK: Button Actions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}