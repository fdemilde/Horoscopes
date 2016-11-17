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
    
    var todayDate = Date()
    var dateSelected : Date!
    var eventsByDate = [String]()
    var type = ArchiveViewType.calendar
    
    let CALENDAR_ICON_SPACE_HEIGHT = 50 as CGFloat
    let PROGRESS_BAR_CONTAINER_SIZE = 120 as CGFloat
    let PADDING: CGFloat = 8 as CGFloat
    let TEXTVIEW_PADDING = 10 as CGFloat // to prevent textview clipping its text
    let HEADER_HEIGHT: CGFloat = 40 as CGFloat
    let FOOTER_HEIGHT: CGFloat = 101 as CGFloat
    let CIRCULAR_PROGRESS_HOLDER_HEIGHT_WITH_PADDING: CGFloat = 160 as CGFloat
    let MIN_CALENDAR_CELL_HEIGHT: CGFloat = 250 as CGFloat
    
    let textviewForCalculating = UITextView()
    var bgImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
//        Utilities.setLocalPushForTesting()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let bgImageView = self.bgImageView{
            self.view.sendSubview(toBack: bgImageView)
        }
//        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    // MARK: UI
    
    func setupBackground(){
//        containerView.layer.cornerRadius = 4
        let screenSize = Utilities.getScreenSize()
        bgImageView = UIImageView(frame: CGRect(x: 0,y: 0,width: screenSize.width,height: screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
        self.view.sendSubview(toBack: bgImageView)
    }
    
    func getHeaderView() -> UIView {
        if let _ = tableHeaderView{
            
        } else {
            tableHeaderView = UIView()
            tableHeaderView.frame = CGRect(x: 0, y: 0, width: Utilities.getScreenSize().width, height: 150)
            tableHeaderView.backgroundColor = UIColor.clear
            var pupleView = UIView()
            pupleView.frame = CGRect(x: PADDING, y: 8, width: Utilities.getScreenSize().width - PADDING * 2, height: 142)
            pupleView.backgroundColor = UIColor(red: 133.0/255.0, green: 124.0/255.0, blue: 173.0/255.0, alpha: 1.0)
            pupleView = Utilities.makeCornerRadius(pupleView, maskFrame: self.view.bounds, roundOptions: [.topLeft, .topRight], radius: 4.0)
            pupleView.addSubview(getProgressBar())
            tableHeaderView.addSubview(pupleView)
        }
        
        return tableHeaderView
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
    
    func getProgressBar() -> UIView {
        let progressBarContainer = UIView()
        progressBarContainer.frame = CGRect(x: (tableHeaderView.frame.width - PROGRESS_BAR_CONTAINER_SIZE)/2, y: (tableHeaderView.frame.height - PROGRESS_BAR_CONTAINER_SIZE)/2, width: PROGRESS_BAR_CONTAINER_SIZE, height: PROGRESS_BAR_CONTAINER_SIZE)
        let collectedHoro = CollectedHoroscope()
        let collectedPercentLabel = UILabel()
        let percentage = round(collectedHoro.getScore() * 100)
        let label = "pc = \(percentage)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.archiveOpen, label: label)
        collectedPercentLabel.text = String(format:"%g%%", percentage)
        collectedPercentLabel.font = UIFont.boldSystemFont(ofSize: 24)
        collectedPercentLabel.textColor = UIColor.white
        collectedPercentLabel.sizeToFit()
        collectedPercentLabel.frame = CGRect(x: (progressBarContainer.frame.width - collectedPercentLabel.frame.width)/2, y: (progressBarContainer.frame.height - collectedPercentLabel.frame.height)/2, width: collectedPercentLabel.frame.width, height: collectedPercentLabel.frame.height)
        let centerPoint = CGPoint(x: 60, y: 60)
        let circularProgessBar = CircularProgressBar(center: centerPoint, radius: 40.0 as CGFloat, strokeWidth: 10.0 as CGFloat)
        progressBarContainer.layer.addSublayer(circularProgessBar)
        circularProgessBar.animateCircleWithProgress(CGFloat(collectedHoro.getScore()), duration: 2.0)
        progressBarContainer.addSubview(collectedPercentLabel)
        return progressBarContainer
    }
    
    // MARK: TableView Delegate & Datasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.tableHeaderView = getHeaderView()
        tableView.tableFooterView = getFooterView()
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let headerHeight = getTableHeaderHeight()
        let expectedHeight = Utilities.getScreenSize().height - ADMOD_HEIGHT - NAVIGATION_BAR_HEIGHT - headerHeight - PADDING - TABBAR_HEIGHT
        if(type == .calendar){
            return max(expectedHeight, MIN_CALENDAR_CELL_HEIGHT)
        }
        return max(getAboutCellHeight(), expectedHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(type == .calendar){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveCalendarCell", for: indexPath) as! ArchiveCalendarCell
            cell.setupCell(self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArchiveDetailTableCell", for: indexPath) as! ArchiveDetailTableCell
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
        let attrs = NSDictionary(object: font!, forKey: NSFontAttributeName as NSCopying)
        let string = NSMutableAttributedString(string: text, attributes: attrs as? [String : AnyObject])
        let textViewWidth = Utilities.getScreenSize().width - PADDING * 4
        var textViewHeight = self.calculateTextViewHeight(string, width: textViewWidth)
        let tableHeaderHeight = getTableHeaderHeight()
        
        let minTextViewHeight = Utilities.getScreenSize().height - ADMOD_HEIGHT - NAVIGATION_BAR_HEIGHT - PADDING * 2 - HEADER_HEIGHT - tableHeaderHeight - FOOTER_HEIGHT - TABBAR_HEIGHT
        
        textViewHeight = max(textViewHeight, minTextViewHeight)
        return textViewHeight + HEADER_HEIGHT + FOOTER_HEIGHT + TEXTVIEW_PADDING
    }
    
    func calculateTextViewHeight(_ string: NSAttributedString, width: CGFloat) ->CGFloat {
        textviewForCalculating.attributedText = string
        let size = textviewForCalculating.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        return ceil(size.height)
    }
    
    // Calendar delegate
    func didTapOnArchiveDate(_ item : CollectedItem){
        let df = DateFormatter()
        df.dateStyle = .full
        let date = df.string(from: item.collectedDate)
        let label = "date = \(date)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.archiveReading, label: label)
        collectedItem = item
        type = .horoscopeDetail
        tableView.reloadData()
    }
    
    // MARK: button Action
    
    @IBAction func backTapped(_ sender: AnyObject) {
        if type == .calendar {
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            didTapOnCalendar()
        }
    }
    
    // MARK: daily Content Cell Delegate
    
    func didShare(_ horoscopeDescription: String, timeTag: TimeInterval, shareUrl: String) {
        let controller = prepareShareVC(horoscopeDescription, timeTag: timeTag)
        let formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.slideFromBottom
        formSheet.cornerRadius = 5.0
        formSheet.presentedFormSheetSize = CGSize(width: view.frame.width - 20, height: SHARE_HYBRID_HEIGHT)
        mz_present(formSheet, animated: true, completionHandler: nil)
    }
    
    func didTapOnCalendar() {
        type = .calendar
        tableView.reloadData()
    }
    
    func prepareShareVC(_ horoscopeDescription: String, timeTag: TimeInterval) -> ShareViewController{
        var selectedSign = 0
        var shareUrl = ""
        if let item = collectedItem{
            selectedSign = XAppDelegate.horoscopesManager.getSignIndexOfSignName(item.horoscope.sign)
            if (item.horoscope.permaLinks.count != 0){
                shareUrl = item.horoscope.permaLinks[0] as! String
            }
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyBoard.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        let sharingText = String(format: "%@", horoscopeDescription)
        let pictureURL = String(format: "https://horoscopes.zwigglers.com/mrest/pic/signs/%d.jpg", selectedSign + 1)
        shareVC.populateDailyShareData( ShareViewType.shareViewTypeHybrid, timeTag: timeTag, horoscopeSign: selectedSign + 1, sharingText: sharingText, pictureURL: pictureURL, shareUrl: shareUrl)
        
        return shareVC
    }
    
    
}
