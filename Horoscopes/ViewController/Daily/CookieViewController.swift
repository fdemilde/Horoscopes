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
    let NAVIGATION_BAR_HEIGHT = 50 as CGFloat
    let FOOTER_HEIGHT = 60 as CGFloat
    let PADDING = 10 as CGFloat
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    // batmanView helps prevent scrollview height to be ambiguous
    @IBOutlet weak var batmanView: UIView!
    @IBOutlet weak var headerView: UIView!
    // TITLE LABEL
    @IBOutlet weak var dailyCookieLabel: UILabel!
    
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
    
//    @IBOutlet weak var cookieOpenedTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var tapToOpenLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var todayTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var yourLuckyLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var luckyNumberLabelTopConstraint: NSLayoutConstraint!
//    @IBOutlet weak var shareButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkBackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorTopConstraint: NSLayoutConstraint!
    
    var state = CookieViewState.CookieViewStateUnopened
    var parentVC : NewDailyTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBackground()
        self.setupConstraints()
        state = CookieViewState.CookieViewStateUnopened
        self.reloadState()
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    func setupBackground(){
        containerView.layer.cornerRadius = 4
        var screenSize = Utilities.getScreenSize()
        var bgImageView = UIImageView(frame: CGRectMake(0,0,screenSize.width,screenSize.height))
        bgImageView.image = UIImage(named: "background")
        self.view.addSubview(bgImageView)
    }
    
    func setupConstraints(){
        var ratio = Utilities.getRatio()
        tapToOpenLabelTopConstraint.constant = (tapToOpenLabelTopConstraint.constant * ratio)
        todayTopConstraint.constant = (todayTopConstraint.constant * ratio)
        yourLuckyLabelTopConstraint.constant = (yourLuckyLabelTopConstraint.constant * ratio)
        luckyNumberLabelTopConstraint.constant = (luckyNumberLabelTopConstraint.constant * ratio)
        checkBackTopConstraint.constant = (checkBackTopConstraint.constant * ratio)
        separatorTopConstraint.constant = (separatorTopConstraint.constant * ratio)
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
        formSheet.cornerRadius = 5.0
        formSheet.presentedFormSheetSize = CGSizeMake(view.frame.width - 20, SHARE_HYBRID_HEIGHT)
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
        println("loadStateUnopened loadStateUnopened")
        // show first view / hide second view
        cookieButton.hidden = false
        openCookieLabel.hidden = false
        
        cookieOpenedImageView.hidden = true
        fortuneDescriptionLabel.hidden = true
        yourLuckyNumberLabel.hidden = true
        luckyNumberLabel.hidden = true
        shareButton.hidden = true
        checkBackLabel.hidden = true
        separatorView.hidden = true
        footerView.hidden = true
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
        separatorView.hidden = false
        footerView.hidden = false
        
        containerView.frame = CGRectMake(containerView.frame.origin.x, containerView.frame.origin.y,containerView.frame.size.width, headerView.frame.height + todayTopConstraint.constant + fortuneDescriptionLabel.frame.height + yourLuckyLabelTopConstraint.constant + yourLuckyNumberLabel.frame.height + luckyNumberLabelTopConstraint.constant + luckyNumberLabel.frame.height + checkBackTopConstraint.constant + checkBackLabel.frame.height + separatorTopConstraint.constant + 1 + FOOTER_HEIGHT)
        scrollView.contentSize = CGSize(width: containerView.frame.width, height: containerView.frame.height + PADDING * 2)
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

