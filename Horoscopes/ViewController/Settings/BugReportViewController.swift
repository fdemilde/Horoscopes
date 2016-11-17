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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let image = Utilities.getImageToSupportSize("background", size: self.view.frame.size, frame: self.view.bounds)
        self.view.backgroundColor = UIColor(patternImage: image)
        NotificationCenter.default.addObserver(self, selector: #selector(BugReportViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Notification handlers
    
    func keyboardWillShow(_ notification: Notification) {
        var info = notification.userInfo
        let keyboardSize = info![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let frame = keyboardSize.cgRectValue
        textViewBottomSpaceConstraint.constant = frame.height + bottomSpacePadding
    }
    
    // MARK: Textview delegate
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textView.text.characters.count != 0
    }
    
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        view.endEditing(true)
        self.mz_dismissFormSheetController(animated: true, completionHandler:nil)
    }
    
    // MARK: alertview delegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
        if(alertView.tag == 1){
            view.endEditing(true)
            self.mz_dismissFormSheetController(animated: true, completionHandler:nil)
        } else {
            return
        }
        
    }
    
    // MARK: Action Handlers
    
    @IBAction func sendButtonTapped(_ sender: AnyObject) {
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
        placeholderLabel = UILabel(frame: CGRect(x: textPaddingLeft, y: textPaddingTop, width: width, height: 100))
        placeholderLabel.text = "Please describe in as much detail as possible"
        placeholderLabel.numberOfLines = 0
        placeholderLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
        placeholderLabel.textColor = UIColor.gray
        textView.addSubview(placeholderLabel)
    }
    
}
