//
//  PostLoginViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func didLoginSuccessfully()
}

class PostLoginViewController: UIViewController, SocialManagerDelegate {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var delegate: LoginViewControllerDelegate!
    var titleString = "Login to Facebook"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SocialManager.sharedInstance.delegate = self
        titleLabel.text = titleString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginFacebook(_ sender: UIButton) {
        Utilities.showHUD(view)
        SocialManager.sharedInstance.login(self) { (error, permissionGranted) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                if let error = error {
                    Utilities.hideHUD(self.view)
                    Utilities.showAlert(self, title: "Error", message: "Could not log in to Facebook. Please try again later.", error: error)
                    self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
                } else {
                    if permissionGranted {
                        Utilities.hideHUD(self.view)
                        self.mz_dismissFormSheetController(animated: true, completionHandler: { (formSheetController) -> Void in
                            self.delegate.didLoginSuccessfully()
                        })
                    } else {
                        Utilities.hideHUD(self.view)
                        Utilities.showAlert(self, title: "Permission Denied", message: "Please grant permissions and try again", error: nil)
                        self.mz_dismissFormSheetController(animated: true, completionHandler: nil)
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
