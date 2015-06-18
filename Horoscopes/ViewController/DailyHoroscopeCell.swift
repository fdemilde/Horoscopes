//
//  HoroscopeDescCell.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/18/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class DailyHoroscopeCell : UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var horoscopeDesc: UITextView!
    @IBOutlet weak var todayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        horoscopeDesc.delegate = self
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCell(desc : String, time : NSTimeInterval, type : DailyHoroscopeType) {
        
        var dateString = Utilities.getDateStringFromTimestamp(time,dateFormat: "MMM, dd YYYY")
        self.dateLabel.text = dateString
        switch type{
            case DailyHoroscopeType.TodayHoroscope:
                todayLabel.text = "Today"
            
            case DailyHoroscopeType.TomorrowHoroscope:
                todayLabel.text = "Tomorrow"
            default:
                println("")
        }
        self.horoscopeDesc.text = desc
    }
    
    // MARK: textview delegate
    
    func textViewDidChange(textView: UITextView) {
        println("textViewDidChange textViewDidChange")
//        let size = textView.bounds.size
//        let newSize = textView.sizeThatFits(CGSize(width: size.width, height: CGFloat.max))
//        
//        // Resize the cell only when cell's size is changed
//        if size.height != newSize.height {
//            UIView.setAnimationsEnabled(false)
//            tableView?.beginUpdates()
//            tableView?.endUpdates()
//            UIView.setAnimationsEnabled(true)
//            
//            if let thisIndexPath = tableView?.indexPathForCell(self) {
//                tableView?.scrollToRowAtIndexPath(thisIndexPath, atScrollPosition: .Bottom, animated: false)
//            }
//        }
    }
}

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
}
