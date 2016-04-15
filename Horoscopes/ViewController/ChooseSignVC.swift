//
//  ChooseSignVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/25/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

protocol ChooseSignViewControllerDelegate {
    func didSelectHoroscopeSign(selectedSign: Int)
}

class ChooseSignVC : SpinWheelVC {
    
    @IBOutlet weak var chooseSignButton: UIButton!
    @IBOutlet weak var signNameLabel: UILabel!
    @IBOutlet weak var signDateLabel: UILabel!
    
    @IBOutlet weak var chooseSignButtonTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chooseSignButtonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var chooseSignButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var signNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signDateLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userSignImage: UIImageView!
    @IBOutlet weak var userSignName: UILabel!
    @IBOutlet weak var userSignDate: UILabel!
    
    @IBOutlet weak var userChangeSignButton: UIButton!
    
    
    @IBOutlet weak var signViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewOtherSignTopConstraint: NSLayoutConstraint!
    
    var currentSign = -1
    
    var delegate: ChooseSignViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userChangeSignButton.layer.cornerRadius = 4
        userChangeSignButton.clipsToBounds = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupComponents()
    }
    
    func setupComponents(){
        let ratio = Utilities.getRatioForViewWithWheel()
        chooseSignButtonTopConstraint.constant = (chooseSignButtonTopConstraint.constant * ratio)
        signNameLabelTopConstraint.constant = (signNameLabelTopConstraint.constant * ratio)
        signDateLabelTopConstraint.constant = (signDateLabelTopConstraint.constant * ratio)
        signViewTopConstraint.constant = (signViewTopConstraint.constant * ratio)
        viewOtherSignTopConstraint.constant = (viewOtherSignTopConstraint.constant * ratio)
        
        self.view .bringSubviewToFront(chooseSignButton)
        self.view .bringSubviewToFront(signNameLabel)
        self.view .bringSubviewToFront(signDateLabel)
        
        if(DeviceType.IS_IPHONE_4_OR_LESS){
//            chooseSignButton.hidden = true
            chooseSignButtonWidthConstraint.constant = 80
            chooseSignButtonHeightConstraint.constant = 80
        }
        
        currentSign = (Int)(XAppDelegate.userSettings.horoscopeSign)
        if (currentSign == -1){
            currentSign = 8
        }
        let horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[currentSign];
        wheel.autoRollToSign(horoscope.sign)
        self.userSignName.text = horoscope.sign.uppercaseString
        self.userSignDate.text = Utilities.getSignDateString(horoscope.startDate, endDate: horoscope.endDate)
        
        let image = UIImage(named: String(format:"%@_selected",horoscope.sign))
        userSignImage.image = image
        
    }
    
    // MARK: Delegata methods
    
    override func wheelDidChangeValue(newValue: Horoscope!, becauseOf autoRoll: Bool) {
        if let newValue = newValue {
            self.signNameLabel.text = newValue.sign.uppercaseString
            self.signDateLabel.text = Utilities.getSignDateString(newValue.startDate, endDate: newValue.endDate)
            let index = XAppDelegate.horoscopesManager.horoscopesSigns.indexOf(newValue)
            if(index != nil){
                self.selectedIndex = index!;
            }
            
            let horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[self.selectedIndex] as Horoscope
            
            let image = UIImage(named: String(format:"%@_selected",horoscope.sign))
            chooseSignButton.setImage(image, forState: UIControlState.Normal)
            self.signNameLabel.alpha = 0
            UILabel.beginAnimations("Fade-in", context: nil)
            UILabel.setAnimationDuration(0.6)
            self.signNameLabel.alpha = 1
            UILabel.commitAnimations()
            
        } else {
            self.signNameLabel.text = ""
            self.signDateLabel.text = ""
            return
        }
    }
    
    
    @IBAction func chooseSignTapped(sender: AnyObject) {
        self.dismissChooseSignViewController()
    }
    
    override func doneSelectedSign(){
        self.dismissChooseSignViewController()
    }
    
    func dismissChooseSignViewController(){
        delegate.didSelectHoroscopeSign(selectedIndex)
    }
    
    @IBAction func userChangeSignTapped(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
        presentViewController(loginVC, animated: true, completion: nil)
    }
    
}
