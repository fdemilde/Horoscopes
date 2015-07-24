//
//  ProfileFirstSectionHeaderView.swift
//  Horoscopes
//
//  Created by Dang Doan on 7/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class ProfileFirstSectionHeaderView: UIView {
    
    var addButton: UIButton!
    var settingsButton: UIButton!
    let margin: CGFloat = 10
    let buttonHeight: CGFloat = 44
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addButton = UIButton()
        addButton.setImage(UIImage(named: "add_btn"), forState: UIControlState.Normal)
        addButton.sizeToFit()
        addButton.frame = CGRectMake(margin, margin, addButton.bounds.size.width, buttonHeight)
        addSubview(addButton)
        
        settingsButton = UIButton()
        settingsButton.setImage(UIImage(named: "settings_btn"), forState: UIControlState.Normal)
        settingsButton.sizeToFit()
        settingsButton.frame = CGRectMake(bounds.size.width - settingsButton.bounds.size.width - margin, margin, settingsButton.bounds.size.width, buttonHeight)
        addSubview(settingsButton)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Helpers
    func show() {
        self.addButton.alpha = 1
        self.settingsButton.alpha = 1
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
