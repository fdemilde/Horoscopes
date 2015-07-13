//
//  CollectHoroscopeDetailVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CollectHoroscopeDetailVC : MyViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var signNameLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dateOfHoroscope: UILabel!
    
    var collectedItem = CollectedItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var screenSize = Utilities.getScreenSize()
        var bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
        self.view.bringSubviewToFront(segment)
        self.view.bringSubviewToFront(descriptionTextView)
        self.view.bringSubviewToFront(signNameLabel)
        self.view.bringSubviewToFront(backButton)
        self.view.bringSubviewToFront(dateOfHoroscope)
        setupData()
    }
    
    func setupData(){
        var formater = NSDateFormatter()
        formater.dateFormat = "dd MMM yyyy";
        self.dateOfHoroscope.text = formater.stringFromDate(self.collectedItem.collectedDate)
        self.descriptionTextView.text = self.collectedItem.horoscope.horoscopes[0] as! String
        self.signNameLabel.text = self.collectedItem.horoscope.sign
    }
    
    // MARK: Button Action
    
    @IBAction func changeDaySegmentTapped(sender: AnyObject) {
        self.descriptionTextView.alpha = 0;
        self.descriptionTextView.text = self.collectedItem.horoscope.horoscopes[sender.selectedSegmentIndex] as! String
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.descriptionTextView.alpha = 1;
        })
    }
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}