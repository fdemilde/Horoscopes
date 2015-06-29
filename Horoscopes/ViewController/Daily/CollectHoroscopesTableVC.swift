//
//  CollectHoroscopesTableVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/27/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class CollectHoroscopesTableVC : UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var collectedHoroscopes = CollectedHoroscope()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "background"))
//        self.setupData()
    }
    
    // MARK: table view delegate and datasource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        println("numberOfRowsInSection == \(self.collectedHoroscopes.collectedData.count)")
        return self.collectedHoroscopes.collectedData.count + 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(indexPath.row == 0){
            var firstCell = tableView.dequeueReusableCellWithIdentifier("CollectHoroscopesFirstCell", forIndexPath: indexPath) as! CollectHoroscopesFirstCell
            firstCell.setupComponents()
            firstCell.parentVC = self
            return firstCell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("CollectHoroscopeCell", forIndexPath: indexPath) as! CollectHoroscopeCell
            cell.setupComponents(indexPath.row - 1)
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 0){
            return 300
        } else {
            return 40
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var collectedItem = self.collectedHoroscopes.collectedData[indexPath.row - 1] as! CollectedItem
        // get signIndex for tracker
        var collectSignIndex = 0
        for collectSignIndex; collectSignIndex < XAppDelegate.horoscopesManager.horoscopesSigns.count; collectSignIndex++ {
            var horoscope = self.collectedHoroscopes.collectedData[indexPath.row - 1].horoscope as Horoscope
            var favouriteHoroScope = XAppDelegate.horoscopesManager.horoscopesSigns[collectSignIndex] as Horoscope
            if(horoscope.sign == favouriteHoroScope.sign){
                break; // break loop
            }
        }
        var selectedCell = tableView.cellForRowAtIndexPath(indexPath) as! CollectHoroscopeCell
        
        var label = String(format: "sign=%d,date=%@", collectSignIndex, selectedCell.dateLabel.text!)
        XAppDelegate.sendTrackEventWithActionName(defaultViewArchive, label: label, value: XAppDelegate.mobilePlatform.tracker.appOpenCounter)
        
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var pushVC = storyBoard.instantiateViewControllerWithIdentifier("CollectHoroscopeDetailVC") as! CollectHoroscopeDetailVC
        pushVC.collectedItem = collectedItem
        self.navigationController?.pushViewController(pushVC, animated: true)
        
    }
}
