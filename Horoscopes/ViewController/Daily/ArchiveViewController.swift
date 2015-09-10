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
    let HEADER_HEIGHT: CGFloat = 37 as CGFloat
    let FOOTER_HEIGHT: CGFloat = 50 as CGFloat
    
    let textviewForCalculating = UITextView()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: UI
    
    func setupBackground(){
//        containerView.layer.cornerRadius = 4
        var screenSize = Utilities.getScreenSize()
        var bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
    }
    
    func getHeaderView() -> UIView {
        if let tableHeaderView = tableHeaderView{
            
        } else {
            tableHeaderView = UIView()
            tableHeaderView.frame = CGRectMake(0, 0, Utilities.getScreenSize().width, 150)
            tableHeaderView.backgroundColor = UIColor.clearColor()
            var pupleView = UIView()
            pupleView.frame = CGRectMake(PADDING, 10, Utilities.getScreenSize().width - PADDING * 2, 140)
            pupleView.backgroundColor = UIColor(red: 133.0/255.0, green: 124.0/255.0, blue: 173.0/255.0, alpha: 1.0)
            pupleView = Utilities.makeCornerRadius(pupleView, maskFrame: self.view.bounds, roundOptions: (UIRectCorner.TopLeft | UIRectCorner.TopRight), radius: 4.0)
            
            pupleView.addSubview(getProgressBar())
            tableHeaderView.addSubview(pupleView)
        }
        
        return tableHeaderView
    }
    
    func getFooterView() -> UIView {
        if let tableHeaderView = tableFooterView{
            
        } else {
            tableFooterView = UIView()
            tableFooterView.frame = CGRectMake(0, 0, tableView.frame.width, 8)
            tableFooterView.backgroundColor = UIColor.clearColor()
        }
        return tableFooterView
    }
    
    func getProgressBar() -> UIView {
        var progressBarContainer = UIView()
        progressBarContainer.frame = CGRectMake((tableHeaderView.frame.width - PROGRESS_BAR_CONTAINER_SIZE)/2, (tableHeaderView.frame.height - PROGRESS_BAR_CONTAINER_SIZE)/2, PROGRESS_BAR_CONTAINER_SIZE, PROGRESS_BAR_CONTAINER_SIZE)
        var collectedHoro = CollectedHoroscope()
        var collectedPercentLabel = UILabel()
        collectedPercentLabel.text = String(format:"%g%%",round(collectedHoro.getScore()*100))
        collectedPercentLabel.font = UIFont.boldSystemFontOfSize(24)
        collectedPercentLabel.textColor = UIColor.whiteColor()
        collectedPercentLabel.sizeToFit()
        collectedPercentLabel.frame = CGRectMake((progressBarContainer.frame.width - collectedPercentLabel.frame.width)/2, (progressBarContainer.frame.height - collectedPercentLabel.frame.height)/2, collectedPercentLabel.frame.width, collectedPercentLabel.frame.height)
        var centerPoint = CGPoint(x: 60, y: 60)
        var circularProgessBar = CircularProgressBar(center: centerPoint, radius: 40.0 as CGFloat, strokeWidth: 10.0 as CGFloat)
        progressBarContainer.layer.addSublayer(circularProgessBar)
        circularProgessBar.animateCircleWithProgress(CGFloat(collectedHoro.getScore()), duration: 2.0)
        progressBarContainer.addSubview(collectedPercentLabel)
        return progressBarContainer
    }
    
    // MARK: Buttons action
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
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
        if(type == .Calendar){
            return 240
        }
         return getAboutCellHeight()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(type == .Calendar){
            var cell = tableView.dequeueReusableCellWithIdentifier("ArchiveCalendarCell") as! ArchiveCalendarCell
            cell.setupCell(self)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("ArchiveHoroscopeDetailCell") as! DailyContentTableViewCell
            if let item = collectedItem{
                cell.setUpArchive(collectedItem)
                    cell.delegate = self
            }
            return cell
        }
    }
    
    // MARK: Helpers
    
    func getAboutCellHeight() -> CGFloat {
        var text = ""
        if let item = collectedItem{
            text = item.horoscope.horoscopes[0] as! String
        }
        
        var font = UIFont(name: "HelveticaNeue", size: 16)
        var attrs = NSDictionary(object: font!, forKey: NSFontAttributeName)
        var string = NSMutableAttributedString(string: text, attributes: attrs as [NSObject : AnyObject])
        var textViewWidth = Utilities.getScreenSize().width - PADDING * 2
        let textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        return textViewHeight + HEADER_HEIGHT + FOOTER_HEIGHT + PADDING + 20
    }
    
    func calculateTextViewHeight(string: NSAttributedString, width: CGFloat) ->CGFloat {
        textviewForCalculating.attributedText = string
        let size = textviewForCalculating.sizeThatFits(CGSizeMake(width, CGFloat.max))
        var height = ceil(size.height)
        return height
    }
    
    // Calendar delegate
    func didTapOnArchiveDate(item : CollectedItem){
        collectedItem = item
        type = .HoroscopeDetail
        tableView.reloadData()
    }
    
    // MARK: button Action
    
    @IBAction func backTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: daily Content Cell Delegate
    
    func didShare(horoscopeDescription: String, timeTag: NSTimeInterval) {
        let controller = prepareShareVC(horoscopeDescription, timeTag: timeTag)
        var formSheet = MZFormSheetController(viewController: controller)
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
        if let item = collectedItem{
            selectedSign = XAppDelegate.horoscopesManager.getSignIndexOfSignName(item.horoscope.sign)
        }
        
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var shareVC = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        var sharingText = String(format: "%@", horoscopeDescription)
        var pictureURL = String(format: "http://dv7.zwigglers.com/mrest/pic/signs/%d.jpg", selectedSign + 1)
        var horoscopeSignName = Utilities.getHoroscopeNameWithIndex(selectedSign)
        shareVC.populateDailyShareData( ShareViewType.ShareViewTypeHybrid, timeTag: timeTag, horoscopeSignName: horoscopeSignName, sharingText: sharingText, pictureURL: pictureURL)
        
        return shareVC
    }
    
    
}