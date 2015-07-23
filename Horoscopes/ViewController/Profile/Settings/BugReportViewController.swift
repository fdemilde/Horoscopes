//
//  BugReportViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/22/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class BugReportViewController : MyViewController, UITextViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var textView : UITextView!
    @IBOutlet weak var textViewBottomSpaceConstraint: NSLayoutConstraint!
    var placeholderLabel : UILabel!
    
    let bottomSpacePadding: CGFloat = 10 as CGFloat
    var textPaddingTop: CGFloat = 7
    var textPaddingLeft: CGFloat = 4
    var textViewPadding: CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPlaceHolder()
        
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
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
        var frame = keyboardSize.CGRectValue()
        textViewBottomSpaceConstraint.constant = frame.height + bottomSpacePadding
    }
    
    // MARK: Textview delegate
    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = count(textView.text) != 0
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
            Utilities.showAlertView(self, title: "Error", message: "Cannot send empty message", tag: 2)
            return
        }
        
        XAppDelegate.socialManager.reportIssue(self.textView.text, completionHandler: { (result, error) -> Void in
            Utilities.hideHUD()
            if(error != nil){ // error
                Utilities.showAlertView(self, title: "Error", message: "There's an error when trying to send the data, please try again later!", tag: 2)
            } else {
                Utilities.showAlertView(self, title: "Success", message: "Thank you for your report. We will try our best to fix your issue as soon as we can", tag: 1)
            }
        })
        
    }
    
    // MARK: Helpers
    func setupPlaceHolder(){
        var width = Utilities.getScreenSize().width - (textViewPadding * 2) - (textPaddingLeft * 2)
        placeholderLabel = UILabel(frame: CGRectMake(textPaddingLeft, textPaddingTop, width, 100))
        placeholderLabel.text = "Please describe your issue in as much detail as possible"
        placeholderLabel.numberOfLines = 0
        placeholderLabel.lineBreakMode = NSLineBreakMode.ByCharWrapping
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
        placeholderLabel.textColor = UIColor.grayColor()
        textView.addSubview(placeholderLabel)
    }
    
}