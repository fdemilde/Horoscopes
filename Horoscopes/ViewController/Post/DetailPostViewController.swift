//
//  DetailPostViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/7/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class DetailPostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomSpaceConstraint: NSLayoutConstraint!
    
    var type: String?
    var placeholder: String?
    var keyboardHeight: CGFloat = 0
    var placeholderLabel: UILabel = UILabel()
    var bottomSpaceConstraint: CGFloat!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundImage = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        
        bottomSpaceConstraint = textViewBottomSpaceConstraint.constant
        
        placeholderLabel.text = placeholder
        placeholderLabel.font = textView.font
        placeholderLabel.frame.origin = CGPointMake(textView.frame.origin.x + 4, textView.frame.origin.y + 7)
        placeholderLabel.textColor = UIColor.grayColor()
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        
        self.view.addSubview(activityIndicator)
        
//        XAppDelegate.mobilePlatform.userModule.logoutWithCompleteBlock({ (result, error) -> Void in
//            println("logging out...")
//        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func post(sender: UIButton) {
        if XAppDelegate.mobilePlatform.userCred.hasToken() {
            activityIndicator.startAnimating()
            SocialManager.sharedInstance.createPost(type!, message: textView.text, completionHandler: { (response, error) -> Void in
                if let error = error {
                    self.displayError(error)
                } else {
                    self.finishPost()
                }
            })
        } else {
            self.handleLogin()
        }
    }
    
    func displayError(error: NSError) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.activityIndicator.isAnimating() {
                self.activityIndicator.stopAnimating()
            }
            let alert = UIAlertController(title: "Post Error", message: "\(error)", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func finishPost() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.activityIndicator.isAnimating() {
                self.activityIndicator.stopAnimating()
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    func handleLogin() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PostLoginViewController") as! PostLoginViewController
        let formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.cornerRadius = 5
        MZFormSheetController.sharedBackgroundWindow()
        self.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = count(textView.text) != 0
    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        textViewBottomSpaceConstraint.constant = bottomSpaceConstraint + keyboardSize.CGRectValue().height + 16
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
