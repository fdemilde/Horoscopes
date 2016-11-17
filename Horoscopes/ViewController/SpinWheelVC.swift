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
    var bgImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.setupNotification()
        self.setupWheel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let bgImageView = self.bgImageView{
            self.view.sendSubview(toBack: bgImageView)
        }
        view.addSubview(wheel)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wheel.removeFromSuperview()
    }
    
    func setupNotification(){
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "allSignLoaded:", name: NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
    }
    
    func setupBackground(){
        let screenSize = Utilities.getScreenSize()
        let rect = CGRect(x: 0,y: 0,width: screenSize.width,height: screenSize.height)
        bgImageView = UIImageView(frame: rect)
        if(DeviceType.IS_IPHONE_6){ // iP6
            bgImageView.image = UIImage(named: "bg-ip6@2x.png")
        } else {
            bgImageView.image = UIImage(named: "choose_sign_bg")
        }
        
        self.view.addSubview(bgImageView)
//        self.view.backgroundColor = UIColor(patternImage: image)
    }
    
    func setupWheel(){
        var horoscopesSigns = XAppDelegate.horoscopesManager.getHoroscopesSigns()
        var currentSign = "";
        let setting = XAppDelegate.userSettings
        if (setting.horoscopeSign != -1){ // not load first time
            currentSign = horoscopesSigns[Int(setting.horoscopeSign)].sign;
            let index = setting.horoscopeSign
            if(index < 8){
                for var i = 0; i < 8 - index; i += 1 {
                    horoscopesSigns.insert(horoscopesSigns.last!, at: 0)
                    horoscopesSigns.removeLast()
                }
            } else {
                for var i = 0; i < index - 8; i += 1 {
                    horoscopesSigns.append(horoscopesSigns[0] as Horoscope)
                    horoscopesSigns.remove(at: 0)
                }
            }
        } else {
//            setting.horoscopeSign = 8
//            currentSign = horoscopesSigns[Int(setting.horoscopeSign)].sign;
            currentSign = horoscopesSigns[8].sign;
        }
        //      Binh Modified
        
        let allSignsArray = Utilities.parseArrayToNSArray(horoscopesSigns).mutableCopy() as! NSMutableArray
        
        let frame = getProperRotateFrame()
        wheel = RotateControl(frame: frame, andDelegate: self, withSections: Int32(allSignsArray.count), andArray: allSignsArray, andCurrentSign: currentSign)
        
        self.wheel.center = CGPoint(x: self.view.bounds.size.width/2, y: self.view.bounds.size.height + 15);
    }
    
    func wheelDidChangeValue(_ newValue: Horoscope!, becauseOf autoRoll: Bool) {
        
    }
    
    func doneSelectedSign(){
        
    }
    
    func getProperRotateFrame() -> CGRect{
        // calculate rotate frame width base on screen size width
        // for 320px screen -> rotate width will be 450
        let screenWidth = self.view.bounds.size.width
        let result = 450 * screenWidth / 320
        return CGRect(x: 0, y: 0, width: result, height: result)
    }
    
}
