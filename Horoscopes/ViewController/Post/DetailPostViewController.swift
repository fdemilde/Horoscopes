//
//  DetailPostViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/7/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class DetailPostViewController: ViewControllerWithAds, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var postTitle: UILabel!
    @IBOutlet weak var postTitleBackgroundView: UIView!
    
    var type: String?
    var placeholder: String?
    var keyboardHeight: CGFloat = 0
    var placeholderLabel: UILabel = UILabel()
    var bottomSpaceConstraint: CGFloat = 0
    var parentVC : NewNewsfeedViewController!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.layer.cornerRadius = 4
        contentView.clipsToBounds = true
        // Do any additional setup after loading the view.
        let backgroundImage = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        postTitle.text = placeholder
        placeholderLabel.text = placeholder
        placeholderLabel.font = textView.font
        placeholderLabel.frame.origin = CGPointMake(textView.frame.origin.x + 4, textView.frame.origin.y + 7)
        placeholderLabel.textColor = UIColor.grayColor()
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        self.setTitleBackgroundColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        bottomSpaceConstraint = textViewBottomSpaceConstraint.constant
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        textView.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setTitleBackgroundColor(){
        if(type == "feeling"){
            postTitleBackgroundView.backgroundColor = UIColor(red: 243/255.0, green: 156/255.0, blue: 18/255.0, alpha: 1)
        } else if(type == "story"){
            postTitleBackgroundView.backgroundColor = UIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1)
        } else {
            postTitleBackgroundView.backgroundColor = UIColor(red: 52/255.0, green: 152/255.0, blue: 219/255.0, alpha: 1)
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        view.endEditing(true)
//        parentVC.navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func post() {
        let createPost = { () -> Void in
            Utilities.showHUD()
            SocialManager.sharedInstance.createPost(self.type!, message: self.textView.text, completionHandler: { (result, error) -> Void in
                if let error = error {
                    Utilities.hideHUD()
                    Utilities.showAlert(self, title: "Post Error", message: "Your post cannot be created.", error: error)
                } else {
                    self.finishPost()
                }
            })
        }
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            if SocialManager.sharedInstance.isLoggedInZwigglers() {
                createPost()
            } else {
                SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        Utilities.showAlert(self, title: "Server Error", message: "There is an error on server. Please try again later.", error: error)
                    } else {
                        createPost()
                    }
                })
            }
        } else {
            showLoginFormSheet()
        }
    }
    
    func finishPost() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            Utilities.hideHUD()
            self.view.endEditing(true)
//            self.parentVC.navigationController?.popViewControllerAnimated(true)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func showLoginFormSheet() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PostLoginViewController") as! PostLoginViewController
        controller.detailPostViewController = self
        let formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.cornerRadius = 5
        self.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.text.characters.count != 0
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        textViewBottomSpaceConstraint.constant = bottomSpaceConstraint + keyboardSize.CGRectValue().height
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
