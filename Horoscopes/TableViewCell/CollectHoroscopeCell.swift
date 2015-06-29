//
//  CollectHoroscopeCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/27/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CollectHoroscopeCell : UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupComponents(index : Int){
        var collectHoro = CollectedHoroscope()
        var item = collectHoro.collectedData[index] as! CollectedItem
        var dateformatter = NSDateFormatter()
        dateformatter.dateFormat = "MMM dd, yyyy"
        self.dateLabel.text = dateformatter.stringFromDate(item.collectedDate)
    }
    
}