//
//  CollectHoroscopesFirstCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/27/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CollectHoroscopesFirstCell : UITableViewCell {
    
    @IBOutlet weak var collectedPercentLabel: UILabel!
    var parentVC = UIViewController()
    var circularProgessBar : CircularProgressBar!
    
    @IBOutlet weak var progressBarContainer: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupComponents(){
        var collectedHoro = CollectedHoroscope()
        collectedPercentLabel.text = String(format:"%g%%",round(collectedHoro.getScore()*100))
        var centerPoint = CGPoint(x: 60, y: 60)
        circularProgessBar = CircularProgressBar(center: centerPoint, radius: 40.0 as CGFloat, strokeWidth: 10.0 as CGFloat)
        progressBarContainer.layer.addSublayer(circularProgessBar)
        circularProgessBar.animateCircleWithProgress(CGFloat(collectedHoro.getScore()), duration: 2.0)
        
        self.bringSubviewToFront(collectedPercentLabel)
    }
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.parentVC.navigationController?.popViewControllerAnimated(true)
    }
}