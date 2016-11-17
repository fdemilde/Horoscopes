//
//  ViewControllerWithAds.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class ViewControllerWithAds : UIViewController {
    
    var bannerView: GADBannerView!
    @IBOutlet weak var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async(execute: {
            self.headerView.frame = CGRect(x: 0, y: 0, width: Utilities.getScreenSize().width,height: 50)
            self.headerView.backgroundColor = UIColor.clear
            self.bannerView = GADBannerView()
            self.bannerView?.frame = CGRect(x: 0,y: 0,width: Utilities.getScreenSize().width,height: 50)
            self.bannerView?.adUnitID = ADMOD_ID
            self.bannerView?.rootViewController = XAppDelegate.window?.rootViewController
            let request = GADRequest()
            self.bannerView?.load(request)
            if let navigationController = self.navigationController {
                navigationController.view.addSubview(self.bannerView)
            } else {
                self.view.addSubview(self.bannerView)
            }
        })
    }
    
}
