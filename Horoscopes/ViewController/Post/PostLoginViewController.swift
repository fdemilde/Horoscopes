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
        SocialManager.sharedInstance.loginFacebook { (result, error) -> () in
            if error != nil { // error occured
                self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
            } else {
                self.mz_dismissFormSheetControllerAnimated(true, completionHandler: { (formSheetController) -> Void in
                    self.detailPostViewController.post()
                })
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
