//
//  NewNewsfeedViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/21/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewNewsfeedViewController: ViewControllerWithAds, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let defaultEstimatedRowHeight: CGFloat = 400
    let spaceBetweenCell: CGFloat = 11
    let addButtonSize: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        tableView.estimatedRowHeight = defaultEstimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
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
    
    // MARK: - Table view data source and delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewsfeedTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return spaceBetweenCell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        let addButton = UIButton(frame: CGRect(x: tableView.frame.width - addButtonSize, y: tableView.frame.height - addButtonSize, width: addButtonSize, height: addButtonSize))
//        addButton.frame.origin.y = scrollView.contentOffset.y + tableView.frame.height - addButton.frame.height
//        view.bringSubviewToFront(addButton)
//    }

}
