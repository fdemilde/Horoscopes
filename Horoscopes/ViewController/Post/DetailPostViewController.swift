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
    var placeholer: String?
    var isEdited: Bool = false
    var tapRecognizer: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let backgroundImage = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "dismissPost:", name: NOTIFICATION_CREATE_POST_FINISHED, object: nil)
        textView.text = placeholer
        textView.layer.cornerRadius = 5
        textView.layer.masksToBounds = true
        tapRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func post(sender: UIButton) {
        if isEdited {
            let socialManager = SocialManager()
            socialManager.createPost(type!, message: textView.text)
        } else {
            let alert = UIAlertController(title: "Post Alert", message: "Please make change to post!", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func dismissPost(notification: NSNotification) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if !isEdited {
            textView.text = ""
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        isEdited = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if !isEdited {
            textView.text = placeholer
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        textViewBottomSpaceConstraint.constant += keyboardSize.CGRectValue().height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        textViewBottomSpaceConstraint.constant -= keyboardSize.CGRectValue().height
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
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
