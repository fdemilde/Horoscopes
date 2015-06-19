//
//  DailyTableViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/17/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class DailyTableViewController : UITableViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var selectedSign = -1
    var timeTags = [AnyObject]()
    var cellArray = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
//        self.tableView.backgroundColor = UIColor.blueColor()
        self.tableView.estimatedRowHeight = 130
        tableView.rowHeight = UITableViewAutomaticDimension
        
        if let parentVC = self.tabBarController as? CustomTabBarController{
            self.selectedSign = parentVC.selectedSign
        }
        self.setupData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupNotification()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
//        var newFrame = self.tableView.frame
//        println("table frame = \(newFrame)")
//        newFrame.size.height = self.tableView.frame.height - 200
//        self.tableView.frame = newFrame
//        println("after !!! table frame = \(self.tableView.frame)")
    }
    
    func setupNotification(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "allSignLoaded:", name: NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
    }
    
    func setupData(){
        if(selectedSign != -1){
            var todayDesc = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[0] as! String
            var tomorrowDesc = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[1] as! String
            cellArray.append("")
            cellArray.append(todayDesc)
            cellArray.append(tomorrowDesc)
            if let todayDict = XAppDelegate.horoscopesManager.data["today"] as? Dictionary <String, AnyObject>{
                if let todayTimeTag = todayDict["time_tag"] as? String{
                    self.timeTags.append(todayTimeTag)
                }
            }
            
            if let tomorrowDict = XAppDelegate.horoscopesManager.data["tomorrow"] as? Dictionary <String, AnyObject>{
                if let tomorrowTimeTag = tomorrowDict["time_tag"] as? String{
                    self.timeTags.append(tomorrowTimeTag)
                }
            }
        }
        
    }
    
    // MARK: table view delegate & datasource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return cellArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            var cell = DailyHoroscopeHeaderCell()
            cell = tableView.dequeueReusableCellWithIdentifier("DailyHoroscopeHeaderCell", forIndexPath: indexPath) as! DailyHoroscopeHeaderCell
            cell.setupCell(self.selectedSign)
            return cell
        } else {
            var cell = DailyHoroscopeCell()
            cell = tableView.dequeueReusableCellWithIdentifier("DailyHoroscopeCell", forIndexPath: indexPath) as! DailyHoroscopeCell
            if(indexPath.row == 1){
                var resultDesc = self.getTodayDesc()
                var resultTs = 0.0
                if (self.timeTags.count > 0) {
                    var timeString = self.timeTags[0] as! NSString
                    resultTs = NSTimeInterval(timeString.doubleValue)
                }
//
                cell.setupCell(resultDesc, time: resultTs, type: DailyHoroscopeType.TodayHoroscope)
                
            } else {
                var resultDesc = self.getTomorrowDesc()
                var resultTs = 0.0
                
                if (self.timeTags.count > 1) {
                    var timeString = self.timeTags[1] as! NSString
                    resultTs = NSTimeInterval(timeString.doubleValue)
                }
                cell.setupCell(resultDesc, time: resultTs, type: DailyHoroscopeType.TomorrowHoroscope)
            }
            
            return cell
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 160
        } else if (indexPath.row == 1){
            var descString = self.getTodayDesc()
            return getAboutCellHeight(descString)
        }  else {
            var descString = self.getTomorrowDesc()
            return getAboutCellHeight(descString)
        }
    }
    
    // MARK: notifications handlers
    
    @objc func allSignLoaded(notif: NSNotification) {
        println("MyNotification was handled")
        self.saveData()
        self.tableView.reloadData()
    }
    
    //MARK: Helpers
    
    func saveData(){
        var todayTimetag = XAppDelegate.horoscopesManager.data["today"]!["time_tag"]! as! String
        var tomorrowTimetag = XAppDelegate.horoscopesManager.data["tomorrow"]!["time_tag"]! as! String
        self.timeTags.append(todayTimetag)
        self.timeTags.append(tomorrowTimetag)
        
        var todayDesc = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[0] as! String
        var tomorrowDesc = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[1] as! String
        self.cellArray.removeAll(keepCapacity: false)
        self.cellArray.append("")
        self.cellArray.append(todayDesc)
        self.cellArray.append(tomorrowDesc)
    }
    
    func getAboutCellHeight(desc: String) -> CGFloat {
        var font = UIFont(name: "HelveticaNeue", size: 16)
        var attrs = NSDictionary(object: font!, forKey: NSFontAttributeName)
        var string = NSMutableAttributedString(string: desc, attributes: attrs as [NSObject : AnyObject])
        var textViewWidth = Utilities.getScreenSize().width - 17*2
        let textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        var topSpace = 95 as CGFloat
        var bottomSpace = 115 as CGFloat
        return textViewHeight + topSpace + bottomSpace
    }
    
    func calculateTextViewHeight(string: NSAttributedString, width: CGFloat) ->CGFloat {
        var textView = UITextView()
        textView.attributedText = string
        
        let size = textView.sizeThatFits(CGSizeMake(width, CGFloat.max))
        var height = ceil(size.height)
        return height
    }
    
    func getTodayDesc() -> String {
        var resultDesc = ""
        if let desc = self.cellArray[1] as? String {
            resultDesc = desc
        }
        return resultDesc
    }
    
    func getTomorrowDesc() -> String {
        var resultDesc = ""
        if let desc = self.cellArray[2] as? String {
            resultDesc = desc
        }
        return resultDesc
    }
    
}