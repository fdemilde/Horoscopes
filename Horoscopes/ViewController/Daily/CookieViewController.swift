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
        case cookieViewStateUnopened
        case cookieViewStateOpened
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
    var state = CookieViewState.cookieViewStateUnopened
    var parentVC : DailyTableViewController?
    var shareUrl = ""
    var bgImageView : UIImageView!
    var fortuneId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.setupConstraints()
        self.setupText()
        if(isNewDay()){
            state = CookieViewState.cookieViewStateUnopened
            self.reloadState()
        } else {
            self.populateCurrentFortune()
        }
//        Utilities.setLocalPushForTesting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fortuneOpen, label: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let bgImageView = self.bgImageView{
            self.view.sendSubview(toBack: bgImageView)
        }
//        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLayoutSubviews()
    {
    }
    
    func setupBackground(){
        containerView.layer.cornerRadius = 4
        let screenSize = Utilities.getScreenSize()
        bgImageView = UIImageView(frame: CGRect(x: 0,y: 0,width: screenSize.width,height: screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
        self.view.sendSubview(toBack: bgImageView)
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
            luckyNumberLabel.font = UIFont.boldSystemFont(ofSize: 40)
            checkBackLabel.font = UIFont(name: "HelveticaNeue-Light", size: 13)
        }
        
        if(DeviceType.IS_IPHONE_6P){
            openCookieLabel.font = UIFont(name: "HelveticaNeue-Light", size: 18)
            fortuneDescriptionLabel.font = UIFont(name: "Book Antiqua", size: 18)
            yourLuckyNumberLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            luckyNumberLabel.font = UIFont.boldSystemFont(ofSize: 43)
            checkBackLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        }
    }
    
    // MARK: button Actions
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func cookieTapped(_ sender: AnyObject) {
        let isLoggedIn = XAppDelegate.socialManager.isLoggedInFacebook() ? 1 : 0
        let label = "logged_in = \(isLoggedIn)"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fortuneRead, label: label)
        self.getFortune()
    }
    
    @IBAction func shareFortuneCookieTapped(_ sender: AnyObject) {
        let shareVC = self.prepareShareVC()
        Utilities.presentShareFormSheetController(self, shareViewController: shareVC)
    }
    // MARK: Helpers
    
    func reloadState(){
        switch (state){
        case CookieViewState.cookieViewStateUnopened:
            self.loadStateUnopened()
            break
        case CookieViewState.cookieViewStateOpened:
            self.loadStateOpened()
            break
        }
    }
    
    func prepareShareVC() -> ShareViewController{
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareVC = storyBoard.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        shareVC.populateCookieShareData(ShareViewType.shareViewTypeHybrid, sharingText: String(format: "%@",self.luckyNumberLabel.text!), pictureURL: String(format: "http://dv2.zwigglers.com/fortune3/pic/cookie-ff3.jpg"), shareUrl: self.shareUrl, fortuneId: fortuneId)
        
        return shareVC
    }
    
    func isNewDay() -> Bool {
        if let lastDateOpen = XAppDelegate.dataStore.lastCookieOpenDate {
            let components: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second]
            
            var todayComp = (defaultCalendar as NSCalendar).components(components, from: Date())
            (todayComp as NSDateComponents).calendar = defaultCalendar as Calendar
            todayComp.hour = 0
            todayComp.minute = 0
            todayComp.second = 1
            
            var lastOpenComp = (defaultCalendar as NSCalendar).components(components, from: lastDateOpen)
            (lastOpenComp as NSDateComponents).calendar = defaultCalendar
            lastOpenComp.hour = 0
            lastOpenComp.minute = 0
            lastOpenComp.second = 1
            
            if(fabs(round((todayComp as NSDateComponents).date!.timeIntervalSince((lastOpenComp as NSDateComponents).date!) / (3600*24))) >= 1) {
                return true
            }
            return false
        }
        return true
    }
    
    // MARK: hide/show components
    func loadStateUnopened(){
        // show first view / hide second view
        cookieButton.isHidden = false
        openCookieLabel.isHidden = false
        
        cookieOpenedImageView.isHidden = true
        fortuneDescriptionLabel.isHidden = true
        yourLuckyNumberLabel.isHidden = true
        luckyNumberLabel.isHidden = true
        shareButton.isHidden = true
        checkBackLabel.isHidden = true
        containerWidthConstraint.constant = Utilities.getScreenSize().width - (PADDING * 2)
        containerHeightConstraint.constant = max(Utilities.getScreenSize().height - ADMOD_HEIGHT - TABBAR_HEIGHT - 50 - (PADDING * 2), 400)
    }
    
    func loadStateOpened(){
        // show first view / hide second view
        cookieButton.isHidden = true
        openCookieLabel.isHidden = true
        
        cookieOpenedImageView.isHidden = false
        fortuneDescriptionLabel.isHidden = false
        yourLuckyNumberLabel.isHidden = false
        luckyNumberLabel.isHidden = false
        shareButton.isHidden = false
        checkBackLabel.isHidden = false
        containerWidthConstraint.constant = Utilities.getScreenSize().width - (PADDING * 2)
        containerHeightConstraint.constant = max(Utilities.getScreenSize().height - ADMOD_HEIGHT - TABBAR_HEIGHT - 50 - (PADDING * 2), 400)
    }
    
    func hideAll(){
        cookieButton.isHidden = true
        openCookieLabel.isHidden = true
        
        cookieOpenedImageView.isHidden = true
        fortuneDescriptionLabel.isHidden = true
        yourLuckyNumberLabel.isHidden = true
        luckyNumberLabel.isHidden = true
        shareButton.isHidden = true
        checkBackLabel.isHidden = true
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
                SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.current().tokenString, completionHandler: { (responseDict, error) -> Void in
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
    }
    
    func retrieveFortuneFromServer() {
        Utilities.showHUD()
        if let accessToken = FBSDKAccessToken.current() {
            let postData = NSMutableDictionary()
            if(!XAppDelegate.socialManager.isLoggedInZwigglers()){ // if user doesn't have zwiggler token, use facebook id
                if let userFBID = accessToken.userID {
                    postData.setObject(userFBID, forKey: "fb_uid" as NSCopying)
                }
            }
            
            let expiredTime = Date().timeIntervalSince1970 + 600
            CacheManager.cacheGet(GET_FORTUNE_METHOD, postData: postData, loginRequired: OPTIONAL, expiredTime: expiredTime, forceExpiredKey: nil, completionHandler: { (response, error) -> Void in
                if(error != nil){
                    Utilities.hideHUD()
                    self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
                } else {
                    if let response = response {
                        
                        let result = Utilities.parseNSDictionaryToDictionary(response)
                        self.reloadFortuneData(result)
                    } else {
                        Utilities.hideHUD()
                        self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
                    }
                }
            })
        } else {
            Utilities.hideHUD()
            showLoginFormSheet()
        }
        
    }
    
    func populateCurrentFortune(){
        self.fortuneDescriptionLabel.text = XAppDelegate.dataStore.currentFortuneDescription
        self.luckyNumberLabel.text = XAppDelegate.dataStore.currentLuckyNumber
        self.state = CookieViewState.cookieViewStateOpened
        self.shareUrl = XAppDelegate.dataStore.currentCookieShareLink
        self.reloadState()
    }
    
    func reloadFortuneData(_ data : Dictionary<String, AnyObject>){
        
        DispatchQueue.main.async(execute: {
            let error = data["error"] as! Int
            if(error != 0){
                self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
                Utilities.hideHUD()
                return
            }
            //set data
            let fortuneData = data["fortune"] as? Dictionary<String,AnyObject>
            
            if let fortuneData = fortuneData {
                let fortuneDescription = fortuneData["fortune"] as? String
                let fortunePermaLink = fortuneData["permalink"] as? String
                let fortuneIdInt = fortuneData["fortune_id"] as? Int
                if let fortuneDescription = fortuneDescription {
                    XAppDelegate.dataStore.currentFortuneDescription = "\"\(fortuneDescription)\""
                    self.fortuneDescriptionLabel.text = "\"\(fortuneDescription)\""
                } else {
                    self.fortuneDescriptionLabel.text = ""
                }
                if let fortunePermaLink = fortunePermaLink {
                    self.shareUrl = fortunePermaLink
                    XAppDelegate.dataStore.currentCookieShareLink = fortunePermaLink
                }
                
                if let fortuneId = fortuneIdInt {
                    self.fortuneId = fortuneId
                }
                
                self.luckyNumberLabel.text = ""
                let luckyNumbers = fortuneData["lucky_numbers"] as? [AnyObject]
                if let luckyNumbers = luckyNumbers {
                    for number in luckyNumbers {
                        if(self.luckyNumberLabel.text != ""){
                            self.luckyNumberLabel.text = (self.luckyNumberLabel.text)! + " "
                        }
                        self.luckyNumberLabel.text = (self.luckyNumberLabel.text)! + String(format:"%d", number as! Int)
                    }
                    XAppDelegate.dataStore.currentLuckyNumber = self.luckyNumberLabel.text!
                }
                XAppDelegate.dataStore.lastCookieOpenDate = Date()
                self.state = CookieViewState.cookieViewStateOpened
                self.reloadState()
            } else {
                self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
            }
            
            Utilities.hideHUD()
        })
        
        
    }
    
    func showOnlyDescription(_ string: String){
        DispatchQueue.main.async(execute: {
            self.fortuneDescriptionLabel.text = string
            self.fortuneDescriptionLabel.sizeToFit();
            self.hideAll() // only show description label to show error
            self.fortuneDescriptionLabel.isHidden = false
        })
    }
    
    func showLoginFormSheet() {
        self.view.endEditing(true)
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "PostLoginViewController") as! PostLoginViewController
        controller.delegate = self
        let formSheet = MZFormSheetController(viewController: controller)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.cornerRadius = 5
        formSheet.shouldCenterVertically = true
        formSheet.presentedFormSheetSize = CGSize(width: formSheet.view.frame.width, height: 150)
        self.mz_present(formSheet, animated: true, completionHandler: nil)
    }
    
    // MARK: FBLogin delegate
    func didLoginSuccessfully() {
        retrieveFortuneFromServer()
    }
}

