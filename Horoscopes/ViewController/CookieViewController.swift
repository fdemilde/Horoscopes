//
//  CookieViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CookieViewController : UIViewController{
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cookieButton: UIButton!
    @IBOutlet weak var dailyCookieLabel: UILabel!
    
    @IBOutlet weak var openCookieLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.view.bringSubviewToFront(backButton)
        self.view.bringSubviewToFront(cookieButton)
        self.view.bringSubviewToFront(dailyCookieLabel)
        self.view.bringSubviewToFront(openCookieLabel)
    }
    
    func setupBackground(){
        var screenSize = Utilities.getScreenSize()
        var bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cookieTapped(sender: AnyObject) {
    }
}

