//
//  DailyViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/15/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class DailyViewController : UIViewController {
    
    @IBOutlet weak var chooseSignButton: UIButton!
    @IBOutlet weak var signNameLabel
    : UILabel!
    @IBOutlet weak var signDateLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    var selectedSign = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        if let parentVC = self.tabBarController as? CustomTabBarController{
            self.selectedSign = parentVC.selectedSign
        }
        self.setupComponents()
        self.reloadView()
    }
    
    
    func setupComponents(){
        self.view.bringSubviewToFront(chooseSignButton)
        self.view.bringSubviewToFront(signNameLabel)
        self.view.bringSubviewToFront(signDateLabel)
        self.view.bringSubviewToFront(starImage)
    }
    
    func reloadView(){
        self.reloadViewWithSign(self.selectedSign)
    }
    
    func reloadViewWithSign(selectedSign:Int){
        var sign = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign] as Horoscope
        var image = UIImage(named: String(format:"%@_selected",sign.sign))
        chooseSignButton.setImage(image, forState: UIControlState.Normal)
        signNameLabel.text = sign.sign
        signDateLabel.text = Utilities.getSignDateString(sign.startDate, endDate: sign.endDate)
        if(Int32(selectedSign) == XAppDelegate.userSettings.horoscopeSign){ starImage.hidden = false}
        else {starImage.hidden = true }
    }
}
