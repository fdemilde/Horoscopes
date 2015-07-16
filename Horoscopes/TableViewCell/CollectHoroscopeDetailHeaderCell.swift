//
//  CollectHoroscopeDetailHeader.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/16/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class CollectHoroscopeDetailHeaderCell : UITableViewCell {
    
    @IBOutlet weak var signButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setupCell(item : CollectedItem){
        signButton.setImage(item.horoscope.getIconSelected(), forState: UIControlState.Normal)
    }
}