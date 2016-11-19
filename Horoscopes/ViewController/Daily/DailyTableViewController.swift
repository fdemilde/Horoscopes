//
//  DailyTableViewController.swift
//  Horoscopes
//
//  Created by Dang Doan on 8/19/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import UIKit

class DailyTableViewController: TableViewControllerWithAds, ChooseSignViewControllerDelegate, DailyContentTableViewCellDelegate, DailyButtonTableViewCellDelegate{
    
    var selectedSign = -1
    var collectedHoroscope = CollectedHoroscope()
    var shouldCollectData = false
    var shouldReloadData = true
    var isEmptyDataSource = true
    let PADDING = 8 as CGFloat
    let TEXTVIEW_PADDING = 10 as CGFloat // to prevent textview clipping its text
    let CELL_HEADER_HEIGHT = 40 as CGFloat
    let CELL_FOOTER_HEIGHT = 101 as CGFloat
    
    var textViewForCalculating = UITextView()
    var tableFooterView : UIView!
    var shouldHideNumberOfLike = false
    var shouldShowTomorrowHoroscopes = false
    
    let tapToOpenString = "Tap to open"
    var tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let parentViewController = self.tabBarController as? CustomTabBarController{
            selectedSign = parentViewController.selectedSign
        }
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(DailyTableViewController.showTomorrowHoroscope))
        NotificationCenter.default.addObserver(self, selector: #selector(DailyTableViewController.finishLoadingAllSigns(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_ALL_SIGNS_LOADED), object: nil)
        let backgroundImage = Utilities.getImageToSupportSize("background", size: view.frame.size, frame: view.bounds)
        tableView.backgroundView = UIImageView(image: backgroundImage)
        NotificationCenter.default.addObserver(self, selector: #selector(DailyTableViewController.refreshView), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        refreshView()
        // if v1 update to v2, show login VC with previous selected sign
        let didRegisterForV2 = UserDefaults.standard.bool(forKey: V2_NOTIF_CHECK)
        if !didRegisterForV2 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            parent!.present(loginVC, animated: false, completion: nil)
            
            if (Utilities.isNotificationGranted()){
                Utilities.registerForRemoteNotification()
            } else {
                UserDefaults.standard.set(true, forKey: V2_NOTIF_CHECK)
            }
            
            return
        }
        
        // this shouldn't be running at all if logic is correct, code is here just in case v2 check is wrong
        if Utilities.isFirstTimeUsing() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            parent!.present(loginVC, animated: false, completion: nil)
            return
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let label = "sign = \(selectedSign)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dailyOpen, label: label)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source and delegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 110
        case 2:
            return 160
        default:
            var description = ""
            if(selectedSign != -1 && selectedSign < XAppDelegate.horoscopesManager.horoscopesSigns.count){
                if indexPath.row == 1 {
                    if let horoscopeDescription = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[0] as? String {
                        description = horoscopeDescription
                    }
                } else {
                    if let horoscopeDescription = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[1] as? String {
                        if(shouldShowTomorrowHoroscopes){
                            description = horoscopeDescription
                        } else {
                            description = tapToOpenString
                        }
                        
                    }
                    
                }
            }
            let cellBodyHeight = self.calculateBodyHeight(nil, text: description)
            return CELL_HEADER_HEIGHT + cellBodyHeight + CELL_FOOTER_HEIGHT
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = isEmptyDataSource ? 0 : 4
        return rows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "DailyHoroscopesTableViewCell", for: indexPath)
            configureDailyHoroscopesTableViewCell(cell as! DailyHoroscopesTableViewCell)
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyButtonTableViewCell", for: indexPath) as! DailyButtonTableViewCell
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DailyContentTableViewCell", for: indexPath) as! DailyContentTableViewCell
            cell.delegate = self
            var description = ""
            var shareUrl = ""
            if indexPath.row == 1 {
                
                if(selectedSign != -1 && selectedSign < XAppDelegate.horoscopesManager.horoscopesSigns.count){
                    if let horoscopeDescription = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[0] as? String {
                        description = horoscopeDescription
                    }
                    if let permaLink = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].permaLinks[0] as? String {
                        shareUrl = permaLink
                    }
                }
                
                cell.setUp(DailyHoroscopeType.todayHoroscope, selectedSign: selectedSign, shareUrl : shareUrl, controller: self)
                
                cell.textView.text = description
                
            } else {
                
                cell.setUp(DailyHoroscopeType.tomorrowHoroscope, selectedSign: selectedSign, shareUrl: shareUrl, controller: self)
                
                if(shouldShowTomorrowHoroscopes){
                    if(selectedSign != -1 && selectedSign < XAppDelegate.horoscopesManager.horoscopesSigns.count){
                        if let horoscopeDescription = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].horoscopes[1] as? String {
                            description = horoscopeDescription
                        }
                        if let permaLink = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign].permaLinks[1] as? String {
                            shareUrl = permaLink
                        }
                    }
                    cell.textView.text = description
                    cell.actionView.isHidden = false
                    cell.removeGestureRecognizer(tapGesture)
                } else {
                    cell.configureNumberOfLike(shouldHideNumberOfLike)
                    cell.addGestureRecognizer(tapGesture)
                    cell.textView.text = tapToOpenString
                    cell.actionView.isHidden = true
                    
                }
            }
            
            return cell
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        tableView.tableFooterView = getFooterView()
        return 1
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
            self.shouldHideNumberOfLike = true
            shouldReloadData = false
            XAppDelegate.horoscopesManager.getAllHoroscopes(false)
        }
    }
    
    func updateCollectedData() {
        if(XAppDelegate.horoscopesManager.data.count == 0 || XAppDelegate.horoscopesManager.hasNoData == true){ // has no data == true mean we are using hardcoded data to show error
            return
        }
        if shouldCollectData {
            shouldCollectData = false
            
            let components: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second]
            var todayComp = (defaultCalendar as NSCalendar).components(components, from: Date())
            (todayComp as NSDateComponents).calendar = defaultCalendar as Calendar
            todayComp.hour = 1
            todayComp.minute = 1
            todayComp.second = 1
            collectedHoroscope.mySetLastDateOpenApp((todayComp as NSDateComponents).date)
            saveCollectedHoroscopeData()
        } else {
            let settings = XAppDelegate.userSettings
            let item = CollectedItem()
            item.collectedDate = Date()
            if(settings.horoscopeSign >= 0 && Int(settings.horoscopeSign) < XAppDelegate.horoscopesManager.horoscopesSigns.count){
                item.horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[Int(settings.horoscopeSign)]
                collectedHoroscope.collectedData.replaceObject(at: 0, with: item)
                collectedHoroscope.saveCollectedData()
            }
            
        }
    }
    
    func saveCollectedHoroscopeData(){
        let item = CollectedItem()
        item.collectedDate = Date()
        item.horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[self.selectedSign]
        collectedHoroscope.collectedData.insert(item, at: 0)
        collectedHoroscope.saveCollectedData()
        
    }
    
    // MARK: - Helper
    
    func configureDailyHoroscopesTableViewCell(_ cell: DailyHoroscopesTableViewCell) {
        if selectedSign != -1 {
            let horoscope = XAppDelegate.horoscopesManager.horoscopesSigns[selectedSign] as Horoscope
            let image = UIImage(named: String(format: "%@_selected", horoscope.sign))
            cell.horoscopesSignButton.setImage(image, for: UIControlState())
            cell.horoscopesSignLabel.text = horoscope.sign
            cell.horoscopesDateLabel.text = Utilities.getSignDateString(horoscope.startDate, endDate: horoscope.endDate)
            cell.collectedPercentageLabel.text = String(format:"%g%%", round(collectedHoroscope.getScore() * 100))
        }
    }
    
    func daysPassed() -> Double {
        collectedHoroscope = CollectedHoroscope()
        
        var todayComp = defaultCalendar.dateComponents([.day, .month, .year, .hour], from: Date())
        todayComp.calendar = defaultCalendar
        todayComp.hour = 1
        todayComp.minute = 1
        todayComp.second = 1
        
        var lastOpenComp = defaultCalendar.dateComponents([.day, .month, .year, .hour], from: collectedHoroscope.lastDateOpenApp)
        lastOpenComp.calendar = defaultCalendar
        lastOpenComp.hour = 1
        lastOpenComp.minute = 1
        lastOpenComp.second = 1
        
        return fabs(round(todayComp.date!.timeIntervalSince(lastOpenComp.date!) / (3600*24)))
    }
    
    func prepareShareVC(_ horoscopeDescription: String, timeTag: TimeInterval, shareUrl : String) -> ShareViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyBoard.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        let sharingText = String(format: "%@", horoscopeDescription)
        let pictureURL = String(format: "http://horoscopes.zwigglers.com/mrest/pic/signs/%d.jpg", selectedSign + 1)
        shareVC.populateDailyShareData( ShareViewType.shareViewTypeHybrid, timeTag: timeTag, horoscopeSign: selectedSign + 1, sharingText: sharingText, pictureURL: pictureURL, shareUrl: shareUrl)
        
        return shareVC
    }
    
    
    
    func calculateBodyHeight(_ cell : DailyContentTableViewCell? ,text : String) -> CGFloat{
        
        let font = UIFont(name: "Book Antiqua", size: 15)
        let attrs = NSDictionary(object: font!, forKey: NSFontAttributeName as NSCopying)
        let string = NSMutableAttributedString(string: text, attributes: attrs as? [String : AnyObject])
        let textViewWidth = self.view.frame.width - PADDING * 4
        let textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        return TEXTVIEW_PADDING + textViewHeight
    }
    
    func calculateTextViewHeight(_ string: NSAttributedString, width: CGFloat) ->CGFloat {
        textViewForCalculating.attributedText = string
        let size = textViewForCalculating.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        let height = ceil(size.height)
        return height
    }
    
    func getFooterView() -> UIView {
        if let _ = tableFooterView{
            
        } else {
            tableFooterView = UIView()
            tableFooterView.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 8)
            tableFooterView.backgroundColor = UIColor.clear
        }
        return tableFooterView
    }
    
    // MARK: - Notification Handler
    
    func finishLoadingAllSigns(_ notification: Notification) {
        isEmptyDataSource = false
        self.reloadData()
    }
    
    // this method is for outside class to call
    func reloadData(){
        updateCollectedData()
        tableView.reloadData()
    }
    
    // MARK: - Action
    
    @IBAction func handleRefresh(_ sender: UIRefreshControl) {
        XAppDelegate.horoscopesManager.getAllHoroscopes(true)
        self.shouldHideNumberOfLike = true
        shouldShowTomorrowHoroscopes = false
        tableView.reloadData()
        sender.endRefreshing()
    }
    
    @IBAction func chooseHoroscopeSign(_ sender: UIButton) {
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dailyChooser, label: nil)
        self.shouldHideNumberOfLike = true
        shouldShowTomorrowHoroscopes = false
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChooseSignVC") as! ChooseSignVC
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func cookieTapped() {
        //        isCookieTapped = true
        DispatchQueue.main.async(execute: {
            let cookieViewController = self.storyboard!.instantiateViewController(withIdentifier: "CookieViewController") as! CookieViewController
            cookieViewController.parentVC = self
            self.navigationController!.pushViewController(cookieViewController, animated: true)
        })
    }
    
    func showTomorrowHoroscope(){
        shouldShowTomorrowHoroscopes = true
        tableView.reloadData()
    }
    // MARK: - Delegate
    
    func didTapJoinHoroscopesCommunityButton() {
        
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dailyCommunity, label: nil)
        tabBarController?.selectedIndex = 1
    }
    
    func didTapViewOtherSignButton() {
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dailyChooser, label: nil)
        shouldHideNumberOfLike = true
        let controller = storyboard?.instantiateViewController(withIdentifier: "ChooseSignVC") as! ChooseSignVC
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    
    func didSelectHoroscopeSign(_ selectedSign: Int) {
        presentedViewController?.dismiss(animated: true, completion: nil)
        self.selectedSign = selectedSign
        updateCollectedData()
        tableView.reloadData()
    }
    
    func didShare(_ horoscopeDescription: String, timeTag: TimeInterval, shareUrl : String) {
        let controller = prepareShareVC(horoscopeDescription, timeTag: timeTag, shareUrl : shareUrl)
        Utilities.presentShareFormSheetController(self, shareViewController: controller)
    }
}
