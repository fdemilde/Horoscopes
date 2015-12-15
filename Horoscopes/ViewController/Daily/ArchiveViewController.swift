//
//  ArchiveViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 9/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class ArchiveViewController : ViewControllerWithAds, JTCalendarDelegate, UITableViewDataSource, UITableViewDelegate, DailyContentTableViewCellDelegate {
    @IBOutlet weak var tableView: UITableView!
    var tableHeaderView : UIView!
    var tableFooterView : UIView!
    
    var calendarMenuView : JTCalendarMenuView!
    var calendarContentView : JTHorizontalCalendarView!
    var calendarManager : JTCalendarManager!
    var collectedHoroscopes = CollectedHoroscope()
    var collectedItem : CollectedItem!
    
    var todayDate = NSDate()
    var dateSelected : NSDate!
    var eventsByDate = [String]()
    var type = ArchiveViewType.Calendar
    
    let CALENDAR_ICON_SPACE_HEIGHT = 50 as CGFloat
    let PROGRESS_BAR_CONTAINER_SIZE = 120 as CGFloat
    let PADDING: CGFloat = 8 as CGFloat
    let TEXTVIEW_PADDING = 10 as CGFloat // to prevent textview clipping its text
    let HEADER_HEIGHT: CGFloat = 40 as CGFloat
    let FOOTER_HEIGHT: CGFloat = 101 as CGFloat
    let CIRCULAR_PROGRESS_HOLDER_HEIGHT_WITH_PADDING: CGFloat = 160 as CGFloat
    let MIN_CALENDAR_CELL_HEIGHT: CGFloat = 250 as CGFloat
    
    let textviewForCalculating = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
//        Utilities.setLocalPushForTesting()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: UI
    
    func setupBackground(){
//        containerView.layer.cornerRadius = 4
        let screenSize = Utilities.getScreenSize()
        let bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
    }
    
    func getHeaderView() -> UIView {
        if let _ = tableHeaderView{
            
        } else {
            tableHeaderView = UIView()
            tableHeaderView.frame = CGRectMake(0, 0, Utilities.getScreenSize().width, 150)
            tableHeaderView.backgroundColor = UIColor.clearColor()
            var pupleView = UIView()
            pupleView.frame = CGRectMake(PADDING, 8, Utilities.getScreenSize().width - PADDING * 2, 142)
            pupleView.backgroundColor = UIColor(red: 133.0/255.0, green: 124.0/255.0, blue: 173.0/255.0, alpha: 1.0)
            pupleView = Utilities.makeCornerRadius(pupleView, maskFrame: self.view.bounds, roundOptions: [.TopLeft, .TopRight], radius: 4.0)
            pupleView.addSubview(getProgressBar())
            tableHeaderView.addSubview(pupleView)
        }
        
        return tableHeaderView
    }
    
    func getFooterView() -> UIView {
        if let _ = tableFooterView{
            
        } else {
            tableFooterView = UIView()
            tableFooterView.frame = CGRectMake(0, 0, tableView.frame.width, 8)
            tableFooterView.backgroundColor = UIColor.clearColor()
        }
        return tableFooterView
    }
    
    func getProgressBar() -> UIView {
        let progressBarContainer = UIView()
        progressBarContainer.frame = CGRectMake((tableHeaderView.frame.width - PROGRESS_BAR_CONTAINER_SIZE)/2, (tableHeaderView.frame.height - PROGRESS_BAR_CONTAINER_SIZE)/2, PROGRESS_BAR_CONTAINER_SIZE, PROGRESS_BAR_CONTAINER_SIZE)
        let collectedHoro = CollectedHoroscope()
        let collectedPercentLabel = UILabel()
        collectedPercentLabel.text = String(format:"%g%%",round(collectedHoro.getScore()*100))
        collectedPercentLabel.font = UIFont.boldSystemFontOfSize(24)
        collectedPercentLabel.textColor = UIColor.whiteColor()
        collectedPercentLabel.sizeToFit()
        collectedPercentLabel.frame = CGRectMake((progressBarContainer.frame.width - collectedPercentLabel.frame.width)/2, (progressBarContainer.frame.height - collectedPercentLabel.frame.height)/2, collectedPercentLabel.frame.width, collectedPercentLabel.frame.height)
        let centerPoint = CGPoint(x: 60, y: 60)
        let circularProgessBar = CircularProgressBar(center: centerPoint, radius: 40.0 as CGFloat, strokeWidth: 10.0 as CGFloat)
        progressBarContainer.layer.addSublayer(circularProgessBar)
        circularProgessBar.animateCircleWithProgress(CGFloat(collectedHoro.getScore()), duration: 2.0)
        progressBarContainer.addSubview(collectedPercentLabel)
        return progressBarContainer
    }
    
    // MARK: Buttons action
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: TableView Delegate & Datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        tableView.tableHeaderView = getHeaderView()
        tableView.tableFooterView = getFooterView()
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let headerHeight = getTableHeaderHeight()
        let expectedHeight = Utilities.getScreenSize().height - ADMOD_HEIGHT - NAVIGATION_BAR_HEIGHT - headerHeight - PADDING - TABBAR_HEIGHT
        if(type == .Calendar){
            return max(expectedHeight, MIN_CALENDAR_CELL_HEIGHT)
        }
        return max(getAboutCellHeight(), expectedHeight)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(type == .Calendar){
            let cell = tableView.dequeueReusableCellWithIdentifier("ArchiveCalendarCell", forIndexPath: indexPath) as! ArchiveCalendarCell
            cell.setupCell(self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ArchiveDetailTableCell", forIndexPath: indexPath) as! ArchiveDetailTableCell
            if let _ = collectedItem{
                cell.setUp(collectedItem)
                    cell.delegate = self
            }
            return cell
        }
    }
    
    func getTableHeaderHeight() -> CGFloat{
        var headerHeight = CIRCULAR_PROGRESS_HOLDER_HEIGHT_WITH_PADDING
        if let tableHeaderView = tableView.tableHeaderView {
            headerHeight = tableHeaderView.frame.height
        }
        
        return headerHeight
    }
    
    // MARK: Helpers
    
    func getAboutCellHeight() -> CGFloat {
        var text = ""
        if let item = collectedItem{
            text = item.horoscope.horoscopes[0] as! String
        }
        
        let font = UIFont(name: "Book Antiqua", size: 15)
        let attrs = NSDictionary(object: font!, forKey: NSFontAttributeName)
        let string = NSMutableAttributedString(string: text, attributes: attrs as? [String : AnyObject])
        let textViewWidth = Utilities.getScreenSize().width - PADDING * 4
        var textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        let tableHeaderHeight = getTableHeaderHeight()
        
        let minTextViewHeight = Utilities.getScreenSize().height - ADMOD_HEIGHT - NAVIGATION_BAR_HEIGHT - PADDING * 2 - HEADER_HEIGHT - tableHeaderHeight - FOOTER_HEIGHT - TABBAR_HEIGHT
        
        textViewHeight = max(textViewHeight, minTextViewHeight)
        return textViewHeight + HEADER_HEIGHT + FOOTER_HEIGHT + TEXTVIEW_PADDING
    }
    
    func calculateTextViewHeight(string: NSAttributedString, width: CGFloat) ->CGFloat {
        textviewForCalculating.attributedText = string
        let size = textviewForCalculating.sizeThatFits(CGSizeMake(width, CGFloat.max))
        return ceil(size.height)
    }
    
    // Calendar delegate
    func didTapOnArchiveDate(item : CollectedItem){
        collectedItem = item
        type = .HoroscopeDetail
        tableView.reloadData()
    }
    
    // MARK: button Action
    
    @IBAction func backTapped(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: daily Content Cell Delegate
    
    func didShare(horoscopeDescription: String, timeTag: NSTimeInterval, shareUrl: String) {
        let controller = prepareShareVC(horoscopeDescription, timeTag: timeTag)
        let formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom
        formSheet.cornerRadius = 5.0
        formSheet.presentedFormSheetSize = CGSizeMake(view.frame.width - 20, SHARE_HYBRID_HEIGHT)
        mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    func didTapOnCalendar() {
        type = .Calendar
        tableView.reloadData()
    }
    
    func prepareShareVC(horoscopeDescription: String, timeTag: NSTimeInterval) -> ShareViewController{
        var selectedSign = 0
        var shareUrl = ""
        if let item = collectedItem{
            selectedSign = XAppDelegate.horoscopesManager.getSignIndexOfSignName(item.horoscope.sign)
            if (item.horoscope.permaLinks.count != 0){
                shareUrl = item.horoscope.permaLinks[0] as! String
            }
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        let sharingText = String(format: "%@", horoscopeDescription)
        let pictureURL = String(format: "http://dv7.zwigglers.com/mrest/pic/signs/%d.jpg", selectedSign + 1)
        shareVC.populateDailyShareData( ShareViewType.ShareViewTypeHybrid, timeTag: timeTag, horoscopeSign: selectedSign + 1, sharingText: sharingText, pictureURL: pictureURL, shareUrl: shareUrl)
        
        return shareVC
    }
    
    
}