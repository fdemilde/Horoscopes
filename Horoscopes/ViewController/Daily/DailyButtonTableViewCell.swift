//
//  DailyButtonTableViewCell.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/20/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

protocol DailyButtonTableViewCellDelegate {
    func didTapJoinHoroscopesCommunityButton()
    func didTapViewOtherSignButton()
}

class DailyButtonTableViewCell: UITableViewCell {
    
    let inset: CGFloat = 8
    @IBOutlet weak var discoverFortuneCookieButton: UIButton!
    @IBOutlet weak var joinHoroscopesCommunityButton: UIButton!
    @IBOutlet weak var viewOtherSignButton: UIButton!
    var delegate: DailyButtonTableViewCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        makeCorneredButton(discoverFortuneCookieButton)
        makeCorneredButton(joinHoroscopesCommunityButton)
        makeCorneredButton(viewOtherSignButton)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var frame = newValue
            frame.origin.x = inset
            frame.size.width = UIScreen.mainScreen().bounds.width - 2*inset
            super.frame = frame
        }
    }
    
    func makeCorneredButton(button: UIButton) {
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
    }
    
    @IBAction func tapJoinHoroscopesCommunityButton(sender: UIButton) {
        delegate.didTapJoinHoroscopesCommunityButton()
    }
    
    @IBAction func viewOtherSignTapped(sender: AnyObject) {
        delegate.didTapViewOtherSignButton()
    }

}
