//
//  SinglePostViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 9/3/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class SinglePostViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var userPost : UserPost!
    
    @IBOutlet weak var navigationView: UIView!
    let defaultEstimatedRowHeight: CGFloat = 400
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.popViewControllerAnimated(true)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SinglePostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        cell.resetUI()
        print("cellForRowAtIndexPath userPost == \(userPost)")
        cell.configureCellForNewsfeed(userPost)
        cell.viewController = self
        
        return cell
    }
    
    // MARK: Button Actions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}