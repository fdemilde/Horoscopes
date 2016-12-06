//
//  CommentTVC.swift
//  Horoscopes
//
//  Created by AndAnotherOne on 12/6/16.
//  Copyright © 2016 Binh Dang. All rights reserved.
//

import UIKit

class CommentTVC: UITableViewCell {

    @IBOutlet weak var imgViewProfile: UIImageView!
    @IBOutlet weak var btnDropdown: UIButton!
    @IBOutlet weak var TvComment: UITextView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblCommentDate: UILabel!
    @IBOutlet weak var lblLike: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideOptions()
    }
    
    override func prepareForReuse() {
        hideOptions()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func hideOptions() {
        
    }
    
    func showOptions() {
        
    }

    @IBAction func btnDropdownDidTouch(_ sender: Any) {
    }
    
    @IBAction func btnLikeDidTouch(_ sender: Any) {
    }
    
}
