//
//  DailyHoroscopesTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class DailyHoroscopesTableViewCell: UITableViewCell {

    @IBOutlet weak var horoscopesSignButton: UIButton!
    @IBOutlet weak var horoscopesSignLabel: UILabel!
    @IBOutlet weak var horoscopesDateLabel: UILabel!
    @IBOutlet weak var collectedPercentageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
