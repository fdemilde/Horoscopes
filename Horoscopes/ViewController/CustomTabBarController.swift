//
//  CustomTabBarVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/3/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarController : UITabBarController, UITabBarControllerDelegate {
    
    var selectedSign = -1
    var lastSelectedIndex = 0
    
    let POST_BUTTON_PADDING = 35 as CGFloat
    let CLOSE_BUTTON_SIZE = CGSizeMake(54,49)
    var postButtonsView: PostButtonsView!
    var overlay : UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a smaller purple background view
//        let view = UIView(frame: CGRectMake(0,2,self.view.frame.size.width, 50))
//        view.backgroundColor = UIColor(red: 97/255.0, green: 96/255.0, blue: 144/255.0, alpha: 1)
//        self.tabBar.addSubview(view)
        
        self.tabBar.backgroundColor = UIColor(red: 97/255.0, green: 96/255.0, blue: 144/255.0, alpha: 1)
        self.setupTabBarItems()
        self.delegate = self
        selectedSign = Int(XAppDelegate.userSettings.horoscopeSign)
        if(selectedSign == -1){
            selectedSign = 8 // default sign
        }
        
        
//        var tabFrame = self.tabBar.frame //self.TabBar is IBOutlet of your TabBar
//        tabFrame.size.height = 52
//        tabFrame.origin.y = self.view.frame.size.height - 52
//        self.tabBar.frame = tabFrame
        
        // make tabbar transparent
        self.tabBar.translucent = true
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        setupAddPostButton()
    }
    
    override func viewWillLayoutSubviews(){
    }
    
    func setupTabBarItems(){
        let dailyItem = self.tabBar.items![0] 
//        let newsFeedItem = self.tabBar.items![1]
        let discoveryItem = self.tabBar.items![1]
        let createPostItem = self.tabBar.items![2]
        let notifItem = self.tabBar.items![3]
        let profileItem = self.tabBar.items![4]
//        let settingItem = self.tabBar.items![4] 
        
        dailyItem.image = UIImage(named: "tabbar_daily" )!.imageWithRenderingMode(.AlwaysOriginal)
//        newsFeedItem.image = UIImage(named: "tabbar_newsfeed")!.imageWithRenderingMode(.AlwaysOriginal)
        discoveryItem.image = UIImage(named: "tabbar_community")!.imageWithRenderingMode(.AlwaysOriginal)
        createPostItem.image = UIImage(named: "tabbar_create_post")!.imageWithRenderingMode(.AlwaysOriginal)
        notifItem.image = UIImage(named: "tabbar_notification")!.imageWithRenderingMode(.AlwaysOriginal)
        profileItem.image = UIImage(named: "tabbar_profile")!.imageWithRenderingMode(.AlwaysOriginal)
//        settingItem.image = UIImage(named: "settings_btn")!.imageWithRenderingMode(.AlwaysOriginal)
        
        dailyItem.selectedImage = UIImage(named: "selected_tabbar_daily" )!.imageWithRenderingMode(.AlwaysOriginal)
//        newsFeedItem.selectedImage = UIImage(named: "selected_tabbar_newsfeed")!.imageWithRenderingMode(.AlwaysOriginal)
        discoveryItem.selectedImage = UIImage(named: "selected_tabbar_community")!.imageWithRenderingMode(.AlwaysOriginal)
        notifItem.selectedImage = UIImage(named: "selected_tabbar_notification")!.imageWithRenderingMode(.AlwaysOriginal)
        profileItem.selectedImage = UIImage(named: "selected_tabbar_profile")!.imageWithRenderingMode(.AlwaysOriginal)
//        settingItem.selectedImage = UIImage(named: "selected_setting_icon")!.imageWithRenderingMode(.AlwaysOriginal)
        
        dailyItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
//        newsFeedItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        discoveryItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        createPostItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        notifItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        profileItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
//        settingItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        // if current selected tab is Daily, when user tap on Daily again, switch to user's favourite sign
        if let viewControllers = self.viewControllers {
            for viewController in viewControllers {
                let nav = viewController as! UINavigationController
                let vc = nav.viewControllers.first!
                if(tabBarController.selectedIndex == 0){ // pop to root view controller which is daily view. This is to make sure when use go back to daily view it'll show daily view instead of Cookie or Archive view
                    if vc.isKindOfClass( DailyTableViewController.classForCoder()) {
                        if(nav.viewControllers.count > 1) { nav.popToRootViewControllerAnimated(true) }
                    }
                }
                
                if lastSelectedIndex == tabBarController.selectedIndex {
                    if tabBarController.selectedIndex == 0 {
                        if vc.isKindOfClass( DailyTableViewController.classForCoder()) {
                            if XAppDelegate.userSettings.horoscopeSign != -1 {
                                let dailyVC = vc as! DailyTableViewController
                                self.selectedSign = Int(XAppDelegate.userSettings.horoscopeSign)
                                dailyVC.selectedSign = self.selectedSign
                                dailyVC.shouldHideNumberOfLike = true
                                dailyVC.reloadData()
                            }
                        }
                    } else if tabBarController.selectedIndex == viewControllers.count - 1 && vc.isKindOfClass(ProfileBaseViewController.classForCoder()) {
                        let controller = vc as! ProfileBaseViewController
                        controller.scrollToTop()
                    } else if tabBarController.selectedIndex == 1 && vc.isKindOfClass(AlternateCommunityViewController.classForCoder()) {
                        let controller = vc as! AlternateCommunityViewController
                        controller.scrollToTop()
                    }
                }
            }
        }
        lastSelectedIndex = tabBarController.selectedIndex
    }
    
    func reload(){
        if let viewControllers = self.viewControllers {
            for nav in viewControllers {
                let nav = nav as! UINavigationController
                let vc = nav.viewControllers.first!
                if vc.isKindOfClass( DailyTableViewController.classForCoder() ) {
                    let dailyVC = vc as! DailyTableViewController
                    dailyVC.selectedSign = self.selectedSign
                    dailyVC.reloadData()
                }
            }
        }
        
    }
    
    func updateNotificationBadge(){
        let notifItem = self.tabBar.items![2]
        if(XAppDelegate.badge == 0){
            notifItem.badgeValue = nil
        } else {
            notifItem.badgeValue = "\(XAppDelegate.badge)"
        }
        
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let nav = viewController as! UINavigationController
        let vc = nav.viewControllers.first!
        if vc.isKindOfClass(DailyTableViewController.classForCoder())  || vc.isKindOfClass(AlternateCommunityViewController.classForCoder()) || vc.isKindOfClass(NotificationViewController.classForCoder()) || vc.isKindOfClass(ProfileBaseViewController.classForCoder()){
            return true
        }
        postButtonTapped()
        return false
    }
    
    func setupAddPostButton() {
        // setup overlay
        overlay = UIView(frame: CGRectMake(0, 0, Utilities.getScreenSize().width, Utilities.getScreenSize().height))
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        overlay.alpha = 0
        
        view.addSubview(overlay)
        view.bringSubviewToFront(overlay)
        
        let overlayTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "overlayTapGestureRecognizer:")
        overlay.addGestureRecognizer(overlayTapGestureRecognizer)
        let postButtonViewFrame = CGRectMake(0, POST_BUTTON_PADDING,  overlay.frame.size.width, overlay.frame.size.height - POST_BUTTON_PADDING*4)
        postButtonsView = PostButtonsView(frame: postButtonViewFrame)
        postButtonsView.setTextColor(UIColor.whiteColor())
        postButtonsView.hostViewController = self
        overlay.addSubview(postButtonsView)
        
        let closeButtonFrame = CGRectMake((overlay.frame.width - CLOSE_BUTTON_SIZE.width)/2, (overlay.frame.height - CLOSE_BUTTON_SIZE.height), CLOSE_BUTTON_SIZE.width, CLOSE_BUTTON_SIZE.height)
        let closeButton = UIButton(frame: closeButtonFrame)
        closeButton.setImage(UIImage(named: "tabbar_close_post"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: "postButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        overlay.addSubview(closeButton)
    }
    
    // MARK: Post buttons handlers
    func postButtonTapped(){
        let isLoggedIn = XAppDelegate.socialManager.isLoggedInFacebook() ? 1 : 0
        let label = "logged_in = \(isLoggedIn)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.postOpen, label: label)
        if(self.overlay.alpha == 1.0){
            overlayFadeout()
        } else {
            overlayFadeIn()
        }
        
        
    }
    
    func overlayTapGestureRecognizer(recognizer: UITapGestureRecognizer){
        overlayFadeout()
    }
    
    func overlayFadeIn(){
        UIView.animateWithDuration(0.2, animations: {
            self.overlay.alpha = 1.0
        })
    }
    
    func overlayFadeout(){
        UIView.animateWithDuration(0.2, animations: {
            self.overlay.alpha = 0
        })
    }
    
}
