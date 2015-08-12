//
//  PostLoginViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class PostLoginViewController: UIViewController, SocialManagerDelegate, UIAlertViewDelegate {
    
    var detailPostViewController : DetailPostViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        SocialManager.sharedInstance.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginFacebook(sender: UIButton) {
        SocialManager.sharedInstance.login { (error, permissionGranted) -> Void in
            if let error = error {
                Utilities.showAlert(self, title: "Log In Error", message: "Could not log in to Facebook. Please try again later.", error: error)
                self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
            } else {
                if permissionGranted {
                    self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (formSheetController) -> Void in
                        self.detailPostViewController.post()
                    })
                } else {
                    Utilities.showAlert(self, title: "Permission Denied", message: "Not enough permission is granted.", error: nil)
                    self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
                }
            }
        }
    }
    
    func facebookLoginFinished(result: [NSObject : AnyObject]?, error: NSError?) {
        if let error = error {
            NSLog("Cannot log in to Facebook. Error: \(error)")
            Utilities.showAlertView(self, title: "Error occured", message: "Please try again later")
        } else {
            self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (formsheetViewController) -> Void in
                    self.detailPostViewController.post()
            })
        }
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
