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
        let label = "post_id = \(userPost.post_id)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.singlePostOpen, label: label)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    // MARK: Setup View
    func setupView(){
        // Do any additional setup after loading the view.
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        view.backgroundColor = UIColor(patternImage: backgroundImage)
        
    }
    
    // MARK: - Table view data source and delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getAboutCellHeight(userPost.message)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SinglePostTableViewCell", for: indexPath) as! PostTableViewCell
        cell.configureCellForNewsfeed(userPost)
        cell.viewController = self
        return cell
    }
    
    // MARK: Table Cell Helpers
    
    func getAboutCellHeight(_ text : String) -> CGFloat {
        let font = UIFont(name: "Book Antiqua", size: 14)
        let attrs = NSDictionary(object: font!, forKey: NSFontAttributeName as NSCopying)
        let string = NSMutableAttributedString(string: text, attributes: attrs as? [String : AnyObject])
        let textViewWidth = Utilities.getScreenSize().width - (PADDING * 2)
        let textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        return textViewHeight + HEADER_HEIGHT + FOOTER_HEIGHT + PADDING * 3
    }
    
    func calculateTextViewHeight(_ string: NSAttributedString, width: CGFloat) ->CGFloat {
        let textviewForCalculating = UITextView()
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let att = string.mutableCopy() as! NSMutableAttributedString
        att.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, att.string.utf16.count))
        textviewForCalculating.attributedText = att
        let size = textviewForCalculating.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let height = ceil(size.height)
        return height
    }
    
    // MARK: Button Actions
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
