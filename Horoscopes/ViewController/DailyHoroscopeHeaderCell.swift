//
//  DailyHoroscopeHeaderCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/18/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class DailyHoroscopeHeaderCell: UITableViewCell {
    
    @IBOutlet weak var chooseSignButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var starImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(signIndex : Int) {
        if(signIndex != -1){ // -1 is not loaded
            var horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[signIndex] as Horoscope
            var image = UIImage(named: String(format:"%@_selected",horoscope.sign))
            chooseSignButton.setImage(image, forState: UIControlState.Normal)
            nameLabel.text = horoscope.sign
            dateLabel.text = Utilities.getSignDateString(horoscope.startDate, endDate: horoscope.endDate)
            
            if(Int32(signIndex) == XAppDelegate.userSettings.horoscopeSign){ starImage.hidden = false}
            else {starImage.hidden = true }
        }
        
    }
}