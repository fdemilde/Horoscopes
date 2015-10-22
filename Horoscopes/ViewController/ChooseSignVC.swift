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
    @IBOutlet weak var starImage: UIImageView!
    
    @IBOutlet weak var chooseSignButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signDateLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var starIconTopConstraint: NSLayoutConstraint!
    var delegate: ChooseSignViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupComponents()
        
    }
    
    func setupComponents(){
        let ratio = Utilities.getRatioForViewWithWheel()
        chooseSignButtonTopConstraint.constant = (chooseSignButtonTopConstraint.constant * ratio)
        signNameLabelTopConstraint.constant = (signNameLabelTopConstraint.constant * ratio)
        signDateLabelTopConstraint.constant = (signDateLabelTopConstraint.constant * ratio)
        starIconTopConstraint.constant = (starIconTopConstraint.constant * ratio)
        
        self.view .bringSubviewToFront(chooseSignButton)
        self.view .bringSubviewToFront(signNameLabel)
        self.view .bringSubviewToFront(signDateLabel)
        self.view .bringSubviewToFront(starImage)
    }
    
    // MARK: Delegata methods
    
    override func wheelDidChangeValue(newValue : Horoscope?){
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
            
            self.starImage.hidden = (XAppDelegate.userSettings.horoscopeSign != Int32(self.selectedIndex))
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
        let label = String(format:"type=view,sign=%d", self.selectedIndex)
        
        XAppDelegate.sendTrackEventWithActionName(defaultHoroscopeChooser, label: label, value: XAppDelegate.mobilePlatform.tracker.appOpenCounter)
        delegate.didSelectHoroscopeSign(selectedIndex)
    }
}
