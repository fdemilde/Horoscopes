//
//  MyViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import GoogleMobileAds

class MyViewController : UIViewController {
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clearColor()
        self.view.frame = CGRectMake(0, 0, Utilities.getScreenSize().width,50)
        bannerView = GADBannerView()
        
        self.bannerView?.adUnitID = ADMOD_ID
        self.bannerView?.rootViewController = self
        println("adView adView = \(bannerView)")
        var request = GADRequest()
        self.bannerView?.loadRequest(request)
    }
}