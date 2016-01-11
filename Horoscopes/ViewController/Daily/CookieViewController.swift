//
//  CookieViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CookieViewController : ViewControllerWithAds, LoginViewControllerDelegate {
    
    enum CookieViewState {
        case CookieViewStateUnopened
        case CookieViewStateOpened
    }
    let FOOTER_HEIGHT = 60 as CGFloat
    let PADDING = 10 as CGFloat
    let NAVIGATION_HEIGHT = 50 as CGFloat
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    // batmanView helps prevent scrollview height to be ambiguous
    @IBOutlet weak var batmanView: UIView!
    @IBOutlet weak var myHeaderView: UIView!
    // TITLE LABEL
    @IBOutlet weak var dailyCookieLabel: UILabel!
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cookieButton: UIButton!
    
    @IBOutlet weak var openCookieLabel: UILabel!
    
    // secondView
    @IBOutlet weak var cookieOpenedImageView: UIImageView!
    @IBOutlet weak var fortuneDescriptionLabel: UILabel!
    @IBOutlet weak var yourLuckyNumberLabel: UILabel!
    @IBOutlet weak var luckyNumberLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var checkBackLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var todayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var luckyNumberLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkBackBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var containerWidthConstraint: NSLayoutConstraint!
    var state = CookieViewState.CookieViewStateUnopened
    var parentVC : DailyTableViewController?
    var shareUrl = ""
    var bgImageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.setupConstraints()
        self.setupText()
        if(isNewDay()){
            state = CookieViewState.CookieViewStateUnopened
            self.reloadState()
        } else {
            self.populateCurrentFortune()
        }
//        Utilities.setLocalPushForTesting()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fortuneOpen, label: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let bgImageView = self.bgImageView{
            self.view.sendSubviewToBack(bgImageView)
        }
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLayoutSubviews()
    {
    }
    
    func setupBackground(){
        containerView.layer.cornerRadius = 4
        let screenSize = Utilities.getScreenSize()
        bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
        self.view.sendSubviewToBack(bgImageView)
    }
    
    func setupConstraints(){
        let ratio = Utilities.getRatio()
        todayTopConstraint.constant = (todayTopConstraint.constant * ratio)
        luckyNumberLabelTopConstraint.constant = (luckyNumberLabelTopConstraint.constant * ratio)
        checkBackBottomConstraint.constant = (checkBackBottomConstraint.constant * ratio)
    }
    
    func setupText(){
        if(DeviceType.IS_IPHONE_6){
            openCookieLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            fortuneDescriptionLabel.font = UIFont(name: "Book Antiqua", size: 16)
            yourLuckyNumberLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13)
            luckyNumberLabel.font = UIFont.boldSystemFontOfSize(40)
            checkBackLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        }
        
        if(DeviceType.IS_IPHONE_6P){
            openCookieLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
            fortuneDescriptionLabel.font = UIFont(name: "Book Antiqua", size: 18)
            yourLuckyNumberLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            luckyNumberLabel.font = UIFont.boldSystemFontOfSize(43)
            checkBackLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        }
    }
    
    // MARK: button Actions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cookieTapped(sender: AnyObject) {
        let isLoggedIn = XAppDelegate.socialManager.isLoggedInFacebook() ? 1 : 0
        let label = "logged_in = \(isLoggedIn)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fortuneRead, label: label)
        self.getFortune()
    }
    
    @IBAction func shareFortuneCookieTapped(sender: AnyObject) {
        let shareVC = self.prepareShareVC()
        Utilities.presentShareFormSheetController(self, shareViewController: shareVC)
    }
    // MARK: Helpers
    
    func reloadState(){
        switch (state){
        case CookieViewState.CookieViewStateUnopened:
            self.loadStateUnopened()
            break
        case CookieViewState.CookieViewStateOpened:
            self.loadStateOpened()
            break
        }
    }
    
    func prepareShareVC() -> ShareViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        shareVC.populateCookieShareData(ShareViewType.ShareViewTypeHybrid, sharingText: String(format: "%@",self.luckyNumberLabel.text!), pictureURL: String(format: "http://dv2.zwigglers.com/fortune3/pic/cookie-ff3.jpg"), shareUrl: self.shareUrl)
        
        return shareVC
    }
    
    func isNewDay() -> Bool {
        if let lastDateOpen = XAppDelegate.dataStore.lastCookieOpenDate {
            let currentCal = NSCalendar.currentCalendar()
            let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
            
            let todayComp = currentCal.components(components, fromDate: NSDate())
            todayComp.calendar = currentCal
            todayComp.hour = 0
            todayComp.minute = 0
            todayComp.second = 1
            
            let lastOpenComp = NSCalendar.currentCalendar().components(components, fromDate: lastDateOpen)
            lastOpenComp.calendar = currentCal
            lastOpenComp.hour = 0
            lastOpenComp.minute = 0
            lastOpenComp.second = 1
            if(fabs(round(todayComp.date!.timeIntervalSinceDate(lastOpenComp.date!) / (3600*24))) >= 1) {
                return true
            }
            return false
        }
        return true
    }
    
    // MARK: hide/show components
    func loadStateUnopened(){
        // show first view / hide second view
        cookieButton.hidden = false
        openCookieLabel.hidden = false
        
        cookieOpenedImageView.hidden = true
        fortuneDescriptionLabel.hidden = true
        yourLuckyNumberLabel.hidden = true
        luckyNumberLabel.hidden = true
        shareButton.hidden = true
        checkBackLabel.hidden = true
        containerWidthConstraint.constant = Utilities.getScreenSize().width - (PADDING * 2)
        containerHeightConstraint.constant = max(Utilities.getScreenSize().height - ADMOD_HEIGHT - TABBAR_HEIGHT - 50 - (PADDING * 2), 400)
    }
    
    func loadStateOpened(){
        // show first view / hide second view
        cookieButton.hidden = true
        openCookieLabel.hidden = true
        
        cookieOpenedImageView.hidden = false
        fortuneDescriptionLabel.hidden = false
        yourLuckyNumberLabel.hidden = false
        luckyNumberLabel.hidden = false
        shareButton.hidden = false
        checkBackLabel.hidden = false
        containerWidthConstraint.constant = Utilities.getScreenSize().width - (PADDING * 2)
        containerHeightConstraint.constant = max(Utilities.getScreenSize().height - ADMOD_HEIGHT - TABBAR_HEIGHT - 50 - (PADDING * 2), 400)
    }
    
    func hideAll(){
        cookieButton.hidden = true
        openCookieLabel.hidden = true
        
        cookieOpenedImageView.hidden = true
        fortuneDescriptionLabel.hidden = true
        yourLuckyNumberLabel.hidden = true
        luckyNumberLabel.hidden = true
        shareButton.hidden = true
        checkBackLabel.hidden = true
    }
    
    // MARK: Network data
    
    func checkPermissionAndGetFortune(){
        SocialManager.sharedInstance.login(self) { (error, permissionGranted) -> Void in
            Utilities.hideHUD()
            if let _ = error {
                self.showOnlyDescription("Cannot login. Please try again later.")
            } else {
                if permissionGranted {
                    self.getFortune()
                } else {
                    self.showOnlyDescription("Permission denied!")
                }
            }
        }
    }
    
    func getFortune() {
        
        if SocialManager.sharedInstance.isLoggedInFacebook() {
            
            if SocialManager.sharedInstance.isLoggedInZwigglers() {
                retrieveFortuneFromServer()
            } else {
                SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        self.retrieveFortuneFromServer()
                    }
                })
            }
        } else {
            showLoginFormSheet()
        }
        
        
        
//            if((FBSDKAccessToken .currentAccessToken()) != nil){
//                FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
//                    if(error == nil){
//                        // println("User information = \(result)")
//                        let userFBID = result["id"] as! String
//                        let postData = NSMutableDictionary()
//                        postData.setObject(userFBID, forKey: "fb_uid")
//                        let expiredTime = NSDate().timeIntervalSince1970 + 600
//                        CacheManager.cacheGet(GET_FORTUNE_METHOD, postData: postData, loginRequired: OPTIONAL, expiredTime: expiredTime, forceExpiredKey: nil, completionHandler: { (response, error) -> Void in
//                            if(error != nil){
//                                Utilities.hideHUD()
//                                self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
//                            } else {
//                                let result = Utilities.parseNSDictionaryToDictionary(response!)
//                                // println("fortune result = \(result)")
//                                self.reloadFortuneData(result)
//                            }
//                        })
//                    } else {
//                        Utilities.hideHUD()
//                        print("fetch Info Error = \(error)")
//                        self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
//                    }
//                })
//            } else {
//                self.checkPermissionAndGetFortune()
//            }
    }
    
    func retrieveFortuneFromServer() {
        Utilities.showHUD()
        let accessToken = FBSDKAccessToken.currentAccessToken()
        let userFBID = accessToken.userID as String
        let postData = NSMutableDictionary()
        postData.setObject(userFBID, forKey: "fb_uid")
        let expiredTime = NSDate().timeIntervalSince1970 + 600
        CacheManager.cacheGet(GET_FORTUNE_METHOD, postData: postData, loginRequired: OPTIONAL, expiredTime: expiredTime, forceExpiredKey: nil, completionHandler: { (response, error) -> Void in
            if(error != nil){
                Utilities.hideHUD()
                self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(response!)
                // println("fortune result = \(result)")
                self.reloadFortuneData(result)
            }
        })
    }
    
    func populateCurrentFortune(){
        self.fortuneDescriptionLabel.text = XAppDelegate.dataStore.currentFortuneDescription
        self.luckyNumberLabel.text = XAppDelegate.dataStore.currentLuckyNumber
        self.state = CookieViewState.CookieViewStateOpened
        self.reloadState()
    }
    
    func reloadFortuneData(data : Dictionary<String, AnyObject>){
        
        dispatch_async(dispatch_get_main_queue(),{
            let error = data["error"] as! Int
            if(error != 0){
                self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
                Utilities.hideHUD()
            }
            //set data
            var fortuneData = data["fortune"] as! Dictionary<String,AnyObject>
            let fortuneDescription = fortuneData["fortune"] as? String
            let fortunePermaLink = fortuneData["permalink"] as? String
            if let fortuneDescription = fortuneDescription {
                XAppDelegate.dataStore.currentFortuneDescription = "\"\(fortuneDescription)\""
                self.fortuneDescriptionLabel.text = "\"\(fortuneDescription)\""
            } else {
                self.fortuneDescriptionLabel.text = ""
            }
            if let fortunePermaLink = fortunePermaLink {
                self.shareUrl = fortunePermaLink
            }
            
            self.luckyNumberLabel.text = ""
            let luckyNumbers = fortuneData["lucky_numbers"] as? [AnyObject]
            if let luckyNumbers = luckyNumbers {
                for number in luckyNumbers {
                    if(self.luckyNumberLabel.text != ""){
                        self.luckyNumberLabel.text = self.luckyNumberLabel.text?.stringByAppendingString(" ")
                    }
                    self.luckyNumberLabel.text = self.luckyNumberLabel.text?.stringByAppendingString(String(format:"%d", number as! Int))
                }
                XAppDelegate.dataStore.currentLuckyNumber = self.luckyNumberLabel.text!
            }
            XAppDelegate.dataStore.lastCookieOpenDate = NSDate()
            self.state = CookieViewState.CookieViewStateOpened
            self.reloadState()
            
            Utilities.hideHUD()
        })
        
        
    }
    
    func showOnlyDescription(string: String){
        dispatch_async(dispatch_get_main_queue(),{
            self.fortuneDescriptionLabel.text = string
            self.fortuneDescriptionLabel.sizeToFit();
            self.hideAll() // only show description label to show error
            self.fortuneDescriptionLabel.hidden = false
        })
    }
    
    func showLoginFormSheet() {
        self.view.endEditing(true)
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("PostLoginViewController") as! PostLoginViewController
        controller.delegate = self
        let formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.cornerRadius = 5
        formSheet.shouldCenterVertically = true
        formSheet.presentedFormSheetSize = CGSize(width: formSheet.view.frame.width, height: 150)
        self.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    // MARK: FBLogin delegate
    func didLoginSuccessfully() {
        retrieveFortuneFromServer()
    }
}

