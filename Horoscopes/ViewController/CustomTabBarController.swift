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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTabBarItems()
        self.delegate = self
//        self.reloadView()
    }
    
    func setupTabBarItems(){
        var tabBarItems = self.tabBar.items!
        
        let dailyItem = self.tabBar.items![0] as! UITabBarItem
        let newsFeedItem = self.tabBar.items![1] as! UITabBarItem
        let postItem = self.tabBar.items![2] as! UITabBarItem
        let notifItem = self.tabBar.items![3] as! UITabBarItem
        let profileItem = self.tabBar.items![4] as! UITabBarItem
        
        dailyItem.image = UIImage(named: "tabbar_daily" )!.imageWithRenderingMode(.AlwaysOriginal)
        newsFeedItem.image = UIImage(named: "tabbar_newsfeed")!.imageWithRenderingMode(.AlwaysOriginal)
        postItem.image = UIImage(named: "tabbar_post")!.imageWithRenderingMode(.AlwaysOriginal)
        notifItem.image = UIImage(named: "tabbar_notification")!.imageWithRenderingMode(.AlwaysOriginal)
        profileItem.image = UIImage(named: "tabbar_profile")!.imageWithRenderingMode(.AlwaysOriginal)
        
        dailyItem.selectedImage = UIImage(named: "selected_tabbar_daily" )!.imageWithRenderingMode(.AlwaysOriginal)
        newsFeedItem.selectedImage = UIImage(named: "selected_tabbar_newsfeed")!.imageWithRenderingMode(.AlwaysOriginal)
        postItem.selectedImage = UIImage(named: "selected_tabbar_post")!.imageWithRenderingMode(.AlwaysOriginal)
        notifItem.selectedImage = UIImage(named: "selected_tabbar_notification")!.imageWithRenderingMode(.AlwaysOriginal)
        profileItem.selectedImage = UIImage(named: "selected_tabbar_profile")!.imageWithRenderingMode(.AlwaysOriginal)
        
        dailyItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        newsFeedItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        postItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        notifItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
        profileItem.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
    }
    
}
