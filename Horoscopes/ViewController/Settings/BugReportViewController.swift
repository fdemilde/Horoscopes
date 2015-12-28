//
//  BugReportViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/22/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class BugReportViewController : ViewControllerWithAds, UITextViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var textViewBottomSpaceConstraint: NSLayoutConstraint!
    var placeholderLabel : UILabel!
    
    @IBOutlet weak var container: UIView!
    
    let bottomSpacePadding: CGFloat = 10 as CGFloat
    var textPaddingTop: CGFloat = 7
    var textPaddingLeft: CGFloat = 4
    var textViewPadding: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPlaceHolder()
        
        container.layer.cornerRadius = 4
        container.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Notification handlers
    
    func keyboardWillShow(notification: NSNotification) {
        var info = notification.userInfo
        let keyboardSize = info![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let frame = keyboardSize.CGRectValue()
        textViewBottomSpaceConstraint.constant = frame.height + bottomSpacePadding
    }
    
    // MARK: Textview delegate
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = textView.text.characters.count != 0
    }
    
    @IBAction func closeButtonTapped(sender: AnyObject) {
        view.endEditing(true)
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
    }
    
    // MARK: alertview delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(alertView.tag == 1){
            view.endEditing(true)
            self.mz_dismissFormSheetControllerAnimated(true, completionHandler:nil)
        } else {
            return
        }
        
    }
    
    // MARK: Action Handlers
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        Utilities.showHUD()
        if(self.textView.text == ""){
            Utilities.hideHUD()
            Utilities.showAlertView(self, title: "Error", message: "Unable to post empty message.", tag: 2)
            return
        }
        
        XAppDelegate.socialManager.reportIssue(self.textView.text, completionHandler: { (result, error) -> Void in
            Utilities.hideHUD()
            if(error != nil){ // error
                Utilities.showAlertView(self, title: "Error", message: "There was an error while trying to contact the server. Please try again later.", tag: 2)
            } else {
                Utilities.showAlertView(self, title: "Success", message: "Thank you for your report. We will try our best to fix your issue as soon as we can", tag: 1)
            }
        })
        
    }
    
    // MARK: Helpers
    func setupPlaceHolder(){
        let width = Utilities.getScreenSize().width - (textViewPadding * 2) - (textPaddingLeft * 2)
        placeholderLabel = UILabel(frame: CGRectMake(textPaddingLeft, textPaddingTop, width, 100))
        placeholderLabel.text = "Please describe in as much detail as possible"
        placeholderLabel.numberOfLines = 0
        placeholderLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
        placeholderLabel.textColor = UIColor.grayColor()
        textView.addSubview(placeholderLabel)
    }
    
}