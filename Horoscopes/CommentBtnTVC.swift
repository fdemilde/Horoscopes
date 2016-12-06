//
//  CommentBtnTVC.swift
//  Horoscopes
//
//  Created by AndAnotherOne on 12/6/16.
//  Copyright © 2016 Binh Dang. All rights reserved.
//

import UIKit

class CommentBtnTVC: UITableViewCell {

    @IBOutlet weak var btnAddAComment: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnAddAComment.layer.cornerRadius = 4
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnAddACommentDidTouch(_ sender: Any) {
    }
    

}
