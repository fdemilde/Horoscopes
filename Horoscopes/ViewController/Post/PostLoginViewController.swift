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
        Utilities.showHUD(view)
        SocialManager.sharedInstance.login(self) { (error, permissionGranted) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let error = error {
                    Utilities.hideHUD(self.view)
                    Utilities.showAlert(self, title: "Log In Error", message: "Could not log in to Facebook. Please try again later.", error: error)
                    self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
                } else {
                    if permissionGranted {
                        Utilities.hideHUD(self.view)
                        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (formSheetController) -> Void in
                            self.detailPostViewController.post()
                        })
                    } else {
                        Utilities.hideHUD(self.view)
                        Utilities.showAlert(self, title: "Permission Denied", message: "Not enough permission is granted.", error: nil)
                        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
                    }
                }
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
