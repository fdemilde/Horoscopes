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
    let PADDING = 20 as CGFloat
    let HEADER_HEIGHT: CGFloat = 130 as CGFloat
    let FOOTER_HEIGHT: CGFloat = 80 as CGFloat
    
    let defaultEstimatedRowHeight: CGFloat = 400
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillDisappear(animated: Bool) {
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Setup View
    func setupView(){
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
    }
    
    // MARK: - Table view data source and delegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return getAboutCellHeight(userPost.message)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SinglePostTableViewCell", forIndexPath: indexPath) as! PostTableViewCell
        cell.configureCellForNewsfeed(userPost)
        cell.viewController = self
        return cell
    }
    
    // MARK: Table Cell Helpers
    
    func getAboutCellHeight(text : String) -> CGFloat {
        let font = UIFont(name: "Book Antiqua", size: 14)
        let attrs = NSDictionary(object: font!, forKey: NSFontAttributeName)
        let string = NSMutableAttributedString(string: text, attributes: attrs as? [String : AnyObject])
        let textViewWidth = Utilities.getScreenSize().width - (PADDING * 2)
        let textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        return textViewHeight + HEADER_HEIGHT + FOOTER_HEIGHT + PADDING * 3
    }
    
    func calculateTextViewHeight(string: NSAttributedString, width: CGFloat) ->CGFloat {
        let textviewForCalculating = UITextView()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let att = string.mutableCopy() as! NSMutableAttributedString
        att.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, att.string.characters.count))
        textviewForCalculating.attributedText = att
        let size = textviewForCalculating.sizeThatFits(CGSizeMake(width, CGFloat.max))
        let height = ceil(size.height)
        return height
    }
    
    // MARK: Button Actions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}