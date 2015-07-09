//
//  PostViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/7/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit
class PostViewController: MyViewController, UITableViewDataSource, UITableViewDelegate {
    
    let postTypes = [
        ["What's on your mind?", "post_type_mind", "onyourmind"],
        ["How do you feel today?", "post_type_feel", "feeling"],
        ["Share a story", "post_type_story", "story"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
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
    
    // MARK: - Table view datasource and delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postTypes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PostTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.text = postTypes[indexPath.row][0]
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.imageView?.image = UIImage(named: postTypes[indexPath.row][1])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("DetailPostViewController") as! DetailPostViewController
        controller.type = postTypes[indexPath.row][2]
        controller.placeholder = postTypes[indexPath.row][0]
        self.presentViewController(controller, animated: true, completion: nil)
//        let formSheetController = MZFormSheetController(viewController: controller)
//        self.mz_presentFormSheetController(formSheetController, animated: true, completionHandler: nil)
    }
}
