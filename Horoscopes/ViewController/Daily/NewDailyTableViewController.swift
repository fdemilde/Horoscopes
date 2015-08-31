//
//  NewDailyTableViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/19/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class NewDailyTableViewController: TableViewControllerWithAds, ChooseSignViewControllerDelegate, DailyContentTableViewCellDelegate {
    
    let defaultEstimatedRowHeight: CGFloat = 96
    let spaceBetweenCell: CGFloat = 16
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
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source and delegate

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let section = isEmptyDataSource ? 0 : 4
        return section
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("DailyHoroscopesTableViewCell", forIndexPath: indexPath) as! UITableViewCell
            configureDailyHoroscopesTableViewCell(cell as! DailyHoroscopesTableViewCell)
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier("DailyButtonTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        default:
            var cell = tableView.dequeueReusableCellWithIdentifier("DailyContentTableViewCell", forIndexPath: indexPath) as! DailyContentTableViewCell
            cell.delegate = self
            cell.layer.cornerRadius = 5
            cell.clipsToBounds = true
            if indexPath.section == 1 {
                cell.setUp(DailyHoroscopeType.TodayHoroscope, selectedSign: selectedSign)
            } else {
                cell.setUp(DailyHoroscopeType.TomorrowHoroscope, selectedSign: selectedSign)
            }
            
            return cell
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return spaceBetweenCell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        return view
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
            var currentCal = NSCalendar.currentCalendar()
            let components = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
            var todayComp = currentCal.components(components, fromDate: NSDate())
            todayComp.hour = 1
            todayComp.minute = 1
            todayComp.second = 1
            todayComp.calendar = currentCal
            collectedHoroscope.mySetLastDateOpenApp(todayComp.date)
            saveCollectedHoroscopeData()
        } else {
            var settings = XAppDelegate.userSettings
            var item = CollectedItem()
            let todayTimetag = XAppDelegate.horoscopesManager.data["today"]!["time_tag"]! as! String
            item.collectedDate = NSDate(timeIntervalSince1970: (todayTimetag as NSString).doubleValue as NSTimeInterval)
            item.horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[Int(settings.horoscopeSign)]
            collectedHoroscope.collectedData.replaceObjectAtIndex(0, withObject: item)
            collectedHoroscope.saveCollectedData()
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
        let today = NSDate()
        collectedHoroscope = CollectedHoroscope()
        var today1 = NSDate()
        var currentCal = NSCalendar.currentCalendar()
        let components = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
        
        var todayComp = currentCal.components(components, fromDate: NSDate())
        todayComp.calendar = currentCal
        
        var lastOpenComp = NSCalendar.currentCalendar().components(components, fromDate: collectedHoroscope.lastDateOpenApp)
        lastOpenComp.calendar = currentCal
        
        todayComp.hour = 1
        todayComp.minute = 1
        todayComp.second = 1
        
        let newDate = lastOpenComp.date
        
        return fabs(round(todayComp.date!.timeIntervalSinceDate(lastOpenComp.date!) / (3600*24)))
    }
    
    func prepareShareVC(horoscopeDescription: String, timeTag: NSTimeInterval) -> ShareViewController{
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var shareVC = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        var sharingText = String(format: "%@", horoscopeDescription)
        var pictureURL = String(format: "http://dv7.zwigglers.com/mrest/pic/signs/%d.jpg", selectedSign + 1)
        var horoscopeSignName = Utilities.getHoroscopeNameWithIndex(selectedSign)
        shareVC.populateDailyShareData( ShareViewType.ShareViewTypeHybrid, timeTag: timeTag, horoscopeSignName: horoscopeSignName, sharingText: sharingText, pictureURL: pictureURL)
        return shareVC
    }
    
    // MARK: - Notification Handler
    
    func finishLoadingAllSigns(notification: NSNotification) {
        isEmptyDataSource = false
        updateCollectedData()
        tableView.reloadData()
    }
    
    // MARK: - Action

    @IBAction func chooseHoroscopeSign(sender: UIButton) {
        let controller = storyboard?.instantiateViewControllerWithIdentifier("ChooseSignVC") as! ChooseSignVC
        controller.delegate = self
        presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func cookieTaooed(sender: AnyObject) {
//        isCookieTapped = true
        let cookieViewController = self.storyboard!.instantiateViewControllerWithIdentifier("CookieViewController") as! CookieViewController
        cookieViewController.parentVC = self
        self.navigationController!.pushViewController(cookieViewController, animated: true)
    }
    // MARK: - Delegate
    
    func didSelectHoroscopeSign(selectedSign: Int) {
        presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        self.selectedSign = selectedSign
        updateCollectedData()
        tableView.reloadData()
    }
    
    func didShare(horoscopeDescription: String, timeTag: NSTimeInterval) {
        let controller = prepareShareVC(horoscopeDescription, timeTag: timeTag)
        var formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom
        formSheet.cornerRadius = 0.0
        formSheet.portraitTopInset = view.frame.height - SHARE_HYBRID_HEIGHT
        formSheet.presentedFormSheetSize = CGSizeMake(view.frame.width, SHARE_HYBRID_HEIGHT)
        mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
}
