//
//  CookieViewController.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/26/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import UIKit

class CookieViewController : UIViewController{
    
    enum CookieViewState {
        case CookieViewStateUnopened
        case CookieViewStateOpened
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // firstView
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cookieButton: UIButton!
    @IBOutlet weak var dailyCookieLabel: UILabel!
    @IBOutlet weak var openCookieLabel: UILabel!
    
    // secondView
    @IBOutlet weak var cookieOpenedImageView: UIImageView!
    @IBOutlet weak var fortuneDescriptionLabel: UILabel!
    @IBOutlet weak var yourLuckyNumberLabel: UILabel!
    @IBOutlet weak var luckyNumberLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var checkBackLabel: UILabel!
    
    @IBOutlet weak var cookieOpenedTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var todayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var yourLuckyLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var luckyNumberLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkBackTopConstraint: NSLayoutConstraint!
    
    var state = CookieViewState.CookieViewStateUnopened
    var parentVC : NewDailyTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.bringFirstViewComponentsToFront()
        self.bringSecondViewComponentsToFront()
        self.setupConstraints()
        state = CookieViewState.CookieViewStateUnopened
        self.reloadState()
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    func setupBackground(){
        var screenSize = Utilities.getScreenSize()
        var bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
    }
    
    func bringFirstViewComponentsToFront(){
        self.view.bringSubviewToFront(scrollView)
        
        scrollView.bringSubviewToFront(backButton)
        scrollView.bringSubviewToFront(cookieButton)
        scrollView.bringSubviewToFront(dailyCookieLabel)
        scrollView.bringSubviewToFront(openCookieLabel)
    }
    
    func bringSecondViewComponentsToFront(){
        scrollView.bringSubviewToFront(cookieOpenedImageView)
        scrollView.bringSubviewToFront(fortuneDescriptionLabel)
        scrollView.bringSubviewToFront(yourLuckyNumberLabel)
        scrollView.bringSubviewToFront(luckyNumberLabel)
        scrollView.bringSubviewToFront(shareButton)
        scrollView.bringSubviewToFront(checkBackLabel)
    }
    
    func setupConstraints(){
        var ratio = Utilities.getRatio()
        cookieOpenedTopConstraint.constant = (cookieOpenedTopConstraint.constant * ratio)
        todayTopConstraint.constant = (todayTopConstraint.constant * ratio)
        yourLuckyLabelTopConstraint.constant = (yourLuckyLabelTopConstraint.constant * ratio)
        luckyNumberLabelTopConstraint.constant = (luckyNumberLabelTopConstraint.constant * ratio)
        shareButtonTopConstraint.constant = (shareButtonTopConstraint.constant * ratio)
        checkBackTopConstraint.constant = (checkBackTopConstraint.constant * ratio)

    }
    
    // MARK: button Actions
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cookieTapped(sender: AnyObject) {
        Utilities.showHUD()
        self.getFortune()
        
        
    }
    
    @IBAction func shareFortuneCookieTapped(sender: AnyObject) {
        var shareVC = self.prepareShareVC()
        var formSheet = MZFormSheetController(viewController: shareVC)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom
        formSheet.cornerRadius = 0.0
        formSheet.portraitTopInset = self.view.frame.height - SHARE_HYBRID_HEIGHT;
        formSheet.presentedFormSheetSize = CGSizeMake(self.view.frame.width, SHARE_HYBRID_HEIGHT);
        self.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
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
        var storyBoard = UIStoryboard(name: "Main", bundle: nil)
        var shareVC = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        shareVC.populateCookieShareData(ShareViewType.ShareViewTypeHybrid, sharingText: String(format: "%@",self.luckyNumberLabel.text!), pictureURL: String(format: "http://dv2.zwigglers.com/fortune3/pic/cookie-ff3.jpg"))
        
        return shareVC
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
        
        scrollView.contentSize = CGSizeMake(Utilities.getScreenSize().width, Utilities.getScreenSize().height - ADMOD_HEIGHT - TABBAR_HEIGHT)
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
        
        scrollView.contentSize = CGSizeMake(Utilities.getScreenSize().width, 460)
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
        var loginManager = FBSDKLoginManager()
        var permissions = ["public_profile", "email", "user_birthday"]
        loginManager.logInWithReadPermissions(permissions, handler: { (result, error) -> Void in
            if((error) != nil){
                self.showOnlyDescription("Error when login Facebook!")
                Utilities.hideHUD()
            } else if (result.isCancelled) {
                self.showOnlyDescription("Permission denied!")
                // Handle cancellations
                Utilities.hideHUD()
            } else {
                if (result.grantedPermissions.contains("public_profile")) {
                    // Do work
                    self.getFortune()
                } else {
                    // Permission denied
                    self.showOnlyDescription("Permission denied!")
                    Utilities.hideHUD()
                }
            }
        })
    }
    
    func getFortune() {
        if((FBSDKAccessToken .currentAccessToken()) != nil){
            var params = Dictionary<String,String>()
            FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
                if(error == nil){
                    // println("User information = \(result)")
                    var userFBID = result["id"] as! String
                    var postData = NSMutableDictionary()
                    postData.setObject(userFBID, forKey: "fb_uid")
                    
                    XAppDelegate.mobilePlatform.sc.sendRequest(GET_FORTUNE_METHOD, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
                        var result = Utilities.parseNSDictionaryToDictionary(response)
                        // println("fortune result = \(result)")
                        self.reloadFortuneData(result)
                    })
                } else {
                    Utilities.hideHUD()
                    println("fetch Info Error = \(error)")
                }
            })
        } else {
            self.checkPermissionAndGetFortune()
        }
    }
    
    func reloadFortuneData(data : Dictionary<String, AnyObject>){
        
        dispatch_async(dispatch_get_main_queue(),{
            var error = data["error"] as! Int
            if(error != 0){
                self.showOnlyDescription("There was an error that occurred during fetching the data. Please try again later!")
                Utilities.hideHUD()
            }
            //set data
            var fortuneData = data["fortune"] as! Dictionary<String,AnyObject>
            self.fortuneDescriptionLabel.text = fortuneData["fortune"] as? String
            self.luckyNumberLabel.text = "";
            var luckyNumbers = fortuneData["lucky_numbers"] as! [AnyObject]
            
            for number in luckyNumbers {
                if(self.luckyNumberLabel.text != ""){
                    self.luckyNumberLabel.text = self.luckyNumberLabel.text?.stringByAppendingString(" ")
                }
                self.luckyNumberLabel.text = self.luckyNumberLabel.text?.stringByAppendingString(String(format:"%d", number as! Int))
            }
            
            self.state = CookieViewState.CookieViewStateOpened
            self.reloadState()
            
            Utilities.hideHUD()
        })
        
        
    }
    
    func showOnlyDescription(string: String){
        self.fortuneDescriptionLabel.text = string
        self.fortuneDescriptionLabel.sizeToFit();
        self.hideAll() // only show description label to show error
        self.fortuneDescriptionLabel.hidden = false
    }
    
    
}

