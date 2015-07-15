//
//  SpinWheelVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class SpinWheelVC : UIViewController, SMRotaryProtocol{
    var wheel = RotateControl()
    var selectedIndex = -1
    var signDescription = ""
    var signDate = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.setupNotification()
        self.setupWheel()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        wheel.removeFromSuperview()
    }
    
    func setupNotification(){
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "allSignLoaded:", name: NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
    }
    
    func setupBackground(){
        var screenSize = Utilities.getScreenSize()
        var bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "choose_sign_bg")
        self.view.addSubview(bgImageView)
    }
    
    func setupWheel(){
        var horoscopesSigns = XAppDelegate.horoscopesManager.getHoroscopesSigns()
        var setting = XAppDelegate.userSettings
        if (setting.horoscopeSign != -1){ // not load first time
            var index = setting.horoscopeSign
            if(index < 8){
                for var i = 0; i < 8 - index; ++i {
                    horoscopesSigns.insert(horoscopesSigns.last!, atIndex: 0)
                    horoscopesSigns.removeLast()
                }
            } else {
                for var i = 0; i < index - 8; ++i {
                    horoscopesSigns.append(horoscopesSigns[0] as Horoscope)
                    horoscopesSigns.removeAtIndex(0)
                }
            }
        } else {
            setting.horoscopeSign = 8
        }
        
        var allSignsArray = Utilities.parseArrayToNSArray(horoscopesSigns).mutableCopy() as! NSMutableArray
        
        var frame = getProperRotateFrame()
        wheel = RotateControl(frame: frame , andDelegate: self, withSections: Int32(allSignsArray.count), andArray: allSignsArray)
        self.wheel.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height + 15);
        self.view.addSubview(self.wheel);
    }
    
    func wheelDidChangeValue(newValue : Horoscope?){
    }
    
    func doneSelectedSign(){
        
    }
    
    func getProperRotateFrame() -> CGRect{
        // calculate rotate frame width base on screen size width
        // for 320px screen -> rotate width will be 450
        var screenWidth = self.view.bounds.size.width
        var result = 450 * screenWidth / 320
        return CGRectMake(0, 0, result, result)
    }
    
}
