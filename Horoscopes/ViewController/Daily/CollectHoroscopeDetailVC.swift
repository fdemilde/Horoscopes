//
//  CollectHoroscopeDetailVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CollectHoroscopeDetailVC : MyViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var dateOfHoroscope: UILabel!
    let textviewForCalculating = UITextView()
    var topSpace = 43 as CGFloat
    var bottomSpace = 75 as CGFloat
    var separatorSpace = 35 as CGFloat
    
    var collectedItem = CollectedItem()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var screenSize = Utilities.getScreenSize()
        var bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
        self.view.bringSubviewToFront(tableView)
        self.view.bringSubviewToFront(backButton)
        self.view.bringSubviewToFront(dateOfHoroscope)
        setupData()
    }
    
    func setupData(){
        var formater = NSDateFormatter()
        formater.dateFormat = "dd MMM yyyy";
        self.dateOfHoroscope.text = formater.stringFromDate(self.collectedItem.collectedDate)
    }
    
    // MARK: Button Action
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: table view delegate & datasource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //TODO: need update
        
//        var cell : CollectHoroscopeDetailCell!
        if(indexPath.row == 0){
            var cell : CollectHoroscopeDetailHeaderCell!
            cell = tableView.dequeueReusableCellWithIdentifier("CollectHoroscopeDetailHeaderCell", forIndexPath: indexPath) as! CollectHoroscopeDetailHeaderCell
            cell.setupCell(self.collectedItem)
            return cell
        } else {
            var cell : CollectHoroscopeDetailCell!
            cell = tableView.dequeueReusableCellWithIdentifier("CollectHoroscopeDetailCell", forIndexPath: indexPath) as! CollectHoroscopeDetailCell
            if(indexPath.row == 1){
                cell.setupCell(self.collectedItem, type: DailyHoroscopeType.TodayHoroscope)
            } else {
                cell.setupCell(self.collectedItem, type: DailyHoroscopeType.TomorrowHoroscope)
            }
            
            return cell
        }
//        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 110
        } else if (indexPath.row == 1){
            var descString = self.getTodayDesc()
            return getAboutCellHeight(descString)
        } else {
            var descString = self.getTomorrowDesc()
            return getAboutCellHeight(descString) - separatorSpace // last cell doesn't need separator
        }
    }
        
    // MARK: Helpers
    
    func getAboutCellHeight(desc: String) -> CGFloat {
        var font = UIFont(name: "HelveticaNeue", size: 16)
        var attrs = NSDictionary(object: font!, forKey: NSFontAttributeName)
        var string = NSMutableAttributedString(string: desc, attributes: attrs as [NSObject : AnyObject])
        var textViewWidth = Utilities.getScreenSize().width - 17*2
        let textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        return textViewHeight + topSpace + bottomSpace
    }
    
    func calculateTextViewHeight(string: NSAttributedString, width: CGFloat) ->CGFloat {
        textviewForCalculating.attributedText = string
        let size = textviewForCalculating.sizeThatFits(CGSizeMake(width, CGFloat.max))
        var height = ceil(size.height)
        return height
    }
    
    func getTodayDesc() -> String {
        var resultDesc = ""
        if let desc = self.collectedItem.horoscope.horoscopes[0] as? String {
            resultDesc = desc
        }
        return resultDesc
    }
    
    func getTomorrowDesc() -> String {
        var resultDesc = ""
        if let desc = self.collectedItem.horoscope.horoscopes[1] as? String {
            resultDesc = desc
        }
        return resultDesc
    }
}