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
    let CLOSE_BUTTON_SIZE = CGSize(width: 54,height: 49)
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
        self.tabBar.isTranslucent = true
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().shadowImage = UIImage()
        setupAddPostButton()
    }
    
    override func viewWillLayoutSubviews(){
    }
    
    func setupTabBarItems(){
        let dailyItem = self.tabBar.items![0]
        let discoveryItem = self.tabBar.items![1]
        let createPostItem = self.tabBar.items![2]
        let notifItem = self.tabBar.items![3]
        let profileItem = self.tabBar.items![4]
        
        dailyItem.image = UIImage(named: "tabbar_daily" )!.withRenderingMode(.alwaysOriginal)
        discoveryItem.image = UIImage(named: "tabbar_community")!.withRenderingMode(.alwaysOriginal)
        createPostItem.image = UIImage(named: "tabbar_create_post")!.withRenderingMode(.alwaysOriginal)
        notifItem.image = UIImage(named: "tabbar_notification")!.withRenderingMode(.alwaysOriginal)
        profileItem.image = UIImage(named: "tabbar_profile")!.withRenderingMode(.alwaysOriginal)
        
        dailyItem.selectedImage = UIImage(named: "selected_tabbar_daily" )!.withRenderingMode(.alwaysOriginal)
        discoveryItem.selectedImage = UIImage(named: "selected_tabbar_community")!.withRenderingMode(.alwaysOriginal)
        notifItem.selectedImage = UIImage(named: "selected_tabbar_notification")!.withRenderingMode(.alwaysOriginal)
        profileItem.selectedImage = UIImage(named: "selected_tabbar_profile")!.withRenderingMode(.alwaysOriginal)
        
        dailyItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        discoveryItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        createPostItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        notifItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        profileItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // if current selected tab is Daily, when user tap on Daily again, switch to user's favourite sign
        if let viewControllers = self.viewControllers {
            for viewController in viewControllers {
                let nav = viewController as! UINavigationController
                let vc = nav.viewControllers.first!
                if(tabBarController.selectedIndex == 0){ // pop to root view controller which is daily view. This is to make sure when use go back to daily view it'll show daily view instead of Cookie or Archive view
                    if vc.isKind( of: DailyTableViewController.classForCoder()) {
                        if(nav.viewControllers.count > 1) { nav.popToRootViewController(animated: true) }
                    }
                }
                
                if lastSelectedIndex == tabBarController.selectedIndex {
                    if tabBarController.selectedIndex == 0 {
                        if vc.isKind( of: DailyTableViewController.classForCoder()) {
                            if XAppDelegate.userSettings.horoscopeSign != -1 {
                                let dailyVC = vc as! DailyTableViewController
                                self.selectedSign = Int(XAppDelegate.userSettings.horoscopeSign)
                                dailyVC.selectedSign = self.selectedSign
                                dailyVC.shouldHideNumberOfLike = true
                                dailyVC.reloadData()
                            }
                        }
                    } else if tabBarController.selectedIndex == viewControllers.count - 1 && vc.isKind(of: ProfileBaseViewController.classForCoder()) {
                        let controller = vc as! ProfileBaseViewController
                        controller.scrollToTop()
                    } else if tabBarController.selectedIndex == 1 && vc.isKind(of: AlternateCommunityViewController.classForCoder()) {
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
                if vc.isKind( of: DailyTableViewController.classForCoder() ) {
                    let dailyVC = vc as! DailyTableViewController
                    dailyVC.selectedSign = self.selectedSign
                    dailyVC.reloadData()
                }
            }
        }
        
    }
    
    func updateNotificationBadge(){
        let notifItem = self.tabBar.items![3]
        if(XAppDelegate.badge == 0){
            notifItem.badgeValue = nil
        } else {
            notifItem.badgeValue = "\(XAppDelegate.badge)"
        }
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let nav = viewController as! UINavigationController
        let vc = nav.viewControllers.first!
        if vc.isKind(of: DailyTableViewController.classForCoder())  || vc.isKind(of: AlternateCommunityViewController.classForCoder()) || vc.isKind(of: NotificationViewController.classForCoder()) || vc.isKind(of: ProfileBaseViewController.classForCoder()){
            return true
        }
        postButtonTapped()
        return false
    }
    
    func setupAddPostButton() {
        // setup overlay
        overlay = UIView(frame: CGRect(x: 0, y: 0, width: Utilities.getScreenSize().width, height: Utilities.getScreenSize().height))
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        overlay.alpha = 0
        
        view.addSubview(overlay)
        view.bringSubview(toFront: overlay)
        
        let overlayTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CustomTabBarController.overlayTapGestureRecognizer(_:)))
        overlay.addGestureRecognizer(overlayTapGestureRecognizer)
        let postButtonViewFrame = CGRect(x: 0, y: POST_BUTTON_PADDING,  width: overlay.frame.size.width, height: overlay.frame.size.height - POST_BUTTON_PADDING*4)
        postButtonsView = PostButtonsView(frame: postButtonViewFrame)
        postButtonsView.setTextColor(UIColor.white)
        postButtonsView.hostViewController = self
        overlay.addSubview(postButtonsView)
        
        let closeButtonFrame = CGRect(x: (overlay.frame.width - CLOSE_BUTTON_SIZE.width)/2, y: (overlay.frame.height - CLOSE_BUTTON_SIZE.height), width: CLOSE_BUTTON_SIZE.width, height: CLOSE_BUTTON_SIZE.height)
        let closeButton = UIButton(frame: closeButtonFrame)
        closeButton.setImage(UIImage(named: "tabbar_close_post"), for: UIControlState())
        closeButton.addTarget(self, action: #selector(CustomTabBarController.postButtonTapped), for: UIControlEvents.touchUpInside)
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
    
    func overlayTapGestureRecognizer(_ recognizer: UITapGestureRecognizer){
        overlayFadeout()
    }
    
    func overlayFadeIn(){
        UIView.animate(withDuration: 0.2, animations: {
            self.overlay.alpha = 1.0
        })
    }
    
    func overlayFadeout(){
        UIView.animate(withDuration: 0.2, animations: {
            self.overlay.alpha = 0
        })
    }
    
}
