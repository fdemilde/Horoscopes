//
//  MyTableViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import GoogleMobileAds
class MyTableViewController : UITableViewController {
    
    @IBOutlet weak var tableHeaderView: UIView!
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableHeaderView.backgroundColor = UIColor.clearColor()
        self.tableHeaderView.frame = CGRectMake(0, 0, Utilities.getScreenSize().width,50)
        
        bannerView = GADBannerView()
        self.bannerView?.frame = CGRectMake(0,0,Utilities.getScreenSize().width,50)
        self.bannerView?.adUnitID = ADMOD_ID
        self.bannerView?.rootViewController = self
        var request = GADRequest()
        self.bannerView?.loadRequest(request)
//        self.navigationController?.view.addSubview(self.bannerView)
    }
}