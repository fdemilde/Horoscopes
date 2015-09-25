//
//  DailyTableViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/19/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class DailyTableViewController: TableViewControllerWithAds, ChooseSignViewControllerDelegate, DailyContentTableViewCellDelegate, DailyButtonTableViewCellDelegate {
    
    let defaultEstimatedRowHeight: CGFloat = 96
    var selectedSign = -1
    var collectedHoroscope = CollectedHoroscope()
    var shouldCollectData = false
    var shouldReloadData = true
    var isEmptyDataSource = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = defaultEstimatedRowHeight
        if let parentViewController = self.tabBarController as? CustomTabBarController{
            selectedSign = parentViewController.selectedSign
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "finishLoadingAllSigns:", name: NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
        
        refreshView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if XAppDelegate.isFirstTimeUsing() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LoginVC
            parentViewController!.presentViewController(loginVC, animated: false, completion: nil)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source and delegate

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = isEmptyDataSource ? 0 : 4
        return rows
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("DailyHoroscopesTableViewCell", forIndexPath: indexPath) 
            configureDailyHoroscopesTableViewCell(cell as! DailyHoroscopesTableViewCell)
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier("DailyButtonTableViewCell", forIndexPath: indexPath) as! DailyButtonTableViewCell
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("DailyContentTableViewCell", forIndexPath: indexPath) as! DailyContentTableViewCell
            cell.delegate = self
            
            if indexPath.row == 1 {
                cell.setUp(DailyHoroscopeType.TodayHoroscope, selectedSign: selectedSign)
            } else {
                cell.setUp(DailyHoroscopeType.TomorrowHoroscope, selectedSign: selectedSign)
            }
            
            return cell
        }

        return cell
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Data handler
    
    func refreshView() {
        if daysPassed() >= 1 || collectedHoroscope.collectedData.count == 0 {
            shouldCollectData = true
            shouldReloadData = true
        }
        if shouldReloadData {
            shouldReloadData = false
            XAppDelegate.horoscopesManager.getAllHoroscopes(false)
        }
        let label = String(format:"type=view,sign=%d", self.selectedSign)
        XAppDelegate.sendTrackEventWithActionName(defaultViewHoroscope, label: label, value: XAppDelegate.mobilePlatform.tracker.appOpenCounter)
    }
    
    func updateCollectedData() {
        if shouldCollectData {
            shouldCollectData = false
            let currentCal = NSCalendar.currentCalendar()
            let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
            let todayComp = currentCal.components(components, fromDate: NSDate())
            todayComp.hour = 1
            todayComp.minute = 1
            todayComp.second = 1
            todayComp.calendar = currentCal
            collectedHoroscope.mySetLastDateOpenApp(todayComp.date)
            saveCollectedHoroscopeData()
        } else {
            let settings = XAppDelegate.userSettings
            let item = CollectedItem()
            let todayTimetag = XAppDelegate.horoscopesManager.data["today"]!["time_tag"]! as! String
            item.collectedDate = NSDate(timeIntervalSince1970: (todayTimetag as NSString).doubleValue as NSTimeInterval)
            if(settings.horoscopeSign >= 0 && Int(settings.horoscopeSign) < XAppDelegate.horoscopesManager.horoscopesSigns.count){
                item.horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[Int(settings.horoscopeSign)]
                collectedHoroscope.collectedData.replaceObjectAtIndex(0, withObject: item)
                collectedHoroscope.saveCollectedData()
            }
            
        }
    }
    
    func saveCollectedHoroscopeData(){
        let item = CollectedItem()
        let todayTimetag = XAppDelegate.horoscopesManager.data["today"]!["time_tag"]! as! String
        item.collectedDate = NSDate(timeIntervalSince1970: (todayTimetag as NSString).doubleValue as NSTimeInterval)
        item.horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[self.selectedSign]
        collectedHoroscope.collectedData.insertObject(item, atIndex: 0)
        collectedHoroscope.saveCollectedData()
//        if let firstCell = firstCell{
//            firstCell.collectTextLabel.text = String(format:"%g",collectedHoro.getScore()*100)
//            firstCell.updateAndAnimateCollectHoroscope()
//        }
        
    }
    
    // MARK: - Helper
    
    func configureDailyHoroscopesTableViewCell(cell: DailyHoroscopesTableViewCell) {
        if selectedSign != -1 {
            let horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign] as Horoscope
            let image = UIImage(named: String(format: "%@_selected", horoscope.sign))
            cell.horoscopesSignButton.setImage(image, forState: .Normal)
            cell.horoscopesSignLabel.text = horoscope.sign
            cell.horoscopesDateLabel.text = Utilities.getSignDateString(horoscope.startDate, endDate: horoscope.endDate)
            cell.collectedPercentageLabel.text = String(format:"%g%%", round(collectedHoroscope.getScore() * 100))
        }
    }
    
    func daysPassed() -> Double {
        collectedHoroscope = CollectedHoroscope()
        let currentCal = NSCalendar.currentCalendar()
        let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        
        let todayComp = currentCal.components(components, fromDate: NSDate())
        todayComp.calendar = currentCal
        
        let lastOpenComp = NSCalendar.currentCalendar().components(components, fromDate: collectedHoroscope.lastDateOpenApp)
        lastOpenComp.calendar = currentCal
        
        todayComp.hour = 1
        todayComp.minute = 1
        todayComp.second = 1
        
        return fabs(round(todayComp.date!.timeIntervalSinceDate(lastOpenComp.date!) / (3600*24)))
    }
    
    func prepareShareVC(horoscopeDescription: String, timeTag: NSTimeInterval) -> ShareViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        let sharingText = String(format: "%@", horoscopeDescription)
        let pictureURL = String(format: "http://dv7.zwigglers.com/mrest/pic/signs/%d.jpg", selectedSign + 1)
        let horoscopeSignName = Utilities.getHoroscopeNameWithIndex(selectedSign)
        shareVC.populateDailyShareData( ShareViewType.ShareViewTypeHybrid, timeTag: timeTag, horoscopeSignName: horoscopeSignName, sharingText: sharingText, pictureURL: pictureURL)
        
        return shareVC
    }
    
    // MARK: - Notification Handler
    
    func finishLoadingAllSigns(notification: NSNotification) {
        isEmptyDataSource = false
        self.reloadData()
    }
    
    // this method is for outside class to call
    func reloadData(){
        updateCollectedData()
        tableView.reloadData()
    }
    
    // MARK: - Action

    @IBAction func chooseHoroscopeSign(sender: UIButton) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("ChooseSignVC") as! ChooseSignVC
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func cookieTapped(sender: AnyObject) {
//        isCookieTapped = true
        let cookieViewController = self.storyboard!.instantiateViewControllerWithIdentifier("CookieViewController") as! CookieViewController
        cookieViewController.parentVC = self
        self.navigationController!.pushViewController(cookieViewController, animated: true)
    }
    // MARK: - Delegate
    
    func didTapJoinHoroscopesCommunityButton() {
        tabBarController?.selectedIndex = 1
    }
    
    func didSelectHoroscopeSign(selectedSign: Int) {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.selectedSign = selectedSign
        updateCollectedData()
        tableView.reloadData()
    }
    
    func didShare(horoscopeDescription: String, timeTag: NSTimeInterval) {
        let controller = prepareShareVC(horoscopeDescription, timeTag: timeTag)
        Utilities.presentShareFormSheetController(self, shareViewController: controller)
    }
}
