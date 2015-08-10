//
//  ProfileFirstSectionHeaderView.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileFirstSectionHeaderView: UIView {
    
    var addButton: UIButton!
    var settingsButton: UIButton!
    var backButton: UIButton?
    let margin: CGFloat = 10
    let buttonHeight: CGFloat = 44
    var parentViewController : ProfileViewController!
    
    init(frame: CGRect, parentViewController: ProfileViewController) {
        super.init(frame: frame)
        self.parentViewController = parentViewController
        if parentViewController.profileType == ProfileType.CurrentUser {
            addButton = UIButton()
            addButton.setImage(UIImage(named: "add_btn"), forState: UIControlState.Normal)
            addButton.sizeToFit()
            addButton.frame = CGRectMake(margin, margin, addButton.bounds.size.width, buttonHeight)
            addButton.addTarget(self, action: "addFriendButtonTapped", forControlEvents: .TouchUpInside)
            addSubview(addButton)
            
            settingsButton = UIButton()
            settingsButton.setImage(UIImage(named: "settings_btn"), forState: UIControlState.Normal)
            settingsButton.sizeToFit()
            settingsButton.frame = CGRectMake(bounds.size.width - settingsButton.bounds.size.width - margin, margin, settingsButton.bounds.size.width, buttonHeight)
            settingsButton.addTarget(self, action: "settingsButtonTapped", forControlEvents: .TouchUpInside)
            addSubview(settingsButton)
        } else {
            backButton = UIButton()
            backButton?.setImage(UIImage(named: "back_button"), forState: .Normal)
            backButton?.sizeToFit()
            backButton?.frame = CGRectMake(margin, margin, backButton!.frame.width, backButton!.frame.height)
            backButton?.addTarget(self, action: "backButtonTapped:", forControlEvents: .TouchUpInside)
            addSubview(backButton!)
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helpers
    func show() {
        self.addButton.alpha = 1
        self.settingsButton.alpha = 1
    }
    
    // MARK: Buttons action
    func settingsButtonTapped(){
        let settingViewController = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        var formSheet = MZFormSheetController(viewController: settingViewController)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom;
        formSheet.cornerRadius = 0.0;
        formSheet.portraitTopInset = 0.0;
        formSheet.presentedFormSheetSize = CGSizeMake(self.window!.frame.size.width, self.window!.frame.size.height);
        let tabBarVC = self.window?.rootViewController as! UITabBarController
        parentViewController.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    func addFriendButtonTapped(){
        let addFriendVC = parentViewController.storyboard!.instantiateViewControllerWithIdentifier("AddFriendTableViewController") as! AddFriendTableViewController
        addFriendVC.parentVC = parentViewController
        self.parentViewController.navigationController?.pushViewController(addFriendVC, animated: true)
//        Utilities.showFormSheet(addFriendVC, fromVC: parentViewController)
    }
    
    func backButtonTapped(sender: UIButton) {
        parentViewController.navigationController?.popViewControllerAnimated(true)
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
