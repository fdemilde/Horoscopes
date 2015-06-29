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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupComponents(){
        var collectedHoro = CollectedHoroscope()
        collectedPercentLabel.text = String(format:"%g%",round(collectedHoro.getScore()*100))
    }
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.parentVC.navigationController?.popViewControllerAnimated(true)
    }
}