//
//  LoginVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class LoginVC : SpinWheelVC, SocialManagerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var separator: UIImageView!
    
    @IBOutlet weak var birthdaySelectButton: UIButton!
    @IBOutlet weak var signNameLabel: UILabel!
    @IBOutlet weak var signDateLabel: UILabel!
    @IBOutlet weak var DOBLabel: UILabel!
    
    @IBOutlet weak var starIcon: UIImageView!
    
    @IBOutlet weak var fbLoginButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbLoginLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var DOBLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var birthdayBgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signDateLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var starIconTopConstraint: NSLayoutConstraint!
    var startButton : UIButton!
    
    
    var userFBID = ""
    var userFBName = ""
    var userFBImageURL = ""
    var userFBBirthdayString = ""
    var birthday : NSDate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginBtn.imageView!.layer.cornerRadius = 0.5 * fbLoginBtn.bounds.size.width
        fbLoginBtn.backgroundColor = UIColor.clearColor()
        fbLoginBtn.imageView!.clipsToBounds = true
        XAppDelegate.socialManager.delegate = self
        self.setupComponents()
    }
    
    func setupComponents(){
        var ratio = Utilities.getRatio()
        fbLoginButtonTopConstraint.constant = (fbLoginButtonTopConstraint.constant * ratio)
        fbLoginLabelTopConstraint.constant = (fbLoginLabelTopConstraint.constant * ratio)
        separatorTopConstraint.constant = (separatorTopConstraint.constant * ratio)
        DOBLabelTopConstraint.constant = (DOBLabelTopConstraint.constant * ratio)
        
        birthdayBgTopConstraint.constant = (birthdayBgTopConstraint.constant * ratio)
        signNameLabelTopConstraint.constant = (signNameLabelTopConstraint.constant * ratio)
        signDateLabelTopConstraint.constant = (signDateLabelTopConstraint.constant * ratio)
        starIconTopConstraint.constant = (starIconTopConstraint.constant * ratio)
        
        var startButtonImage = UIImage(named: "start_button")
        var startButtonFrame = CGRectMake((Utilities.getScreenSize().width - startButtonImage!.size.width)/2, Utilities.getScreenSize().height - startButtonImage!.size.height, startButtonImage!.size.width, startButtonImage!.size.height)
        startButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        startButton.frame = startButtonFrame
        startButton.setImage(startButtonImage, forState: UIControlState.Normal)
        startButton.setTitle("", forState: UIControlState.Normal)
//        startButton.backgroundColor = UIColor.blueColor()
        self.view .addSubview(startButton)
        
        startButton.addTarget(self, action: "startButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view .bringSubviewToFront(fbLoginBtn)
        self.view .bringSubviewToFront(loginLabel)
        self.view .bringSubviewToFront(separator)
        self.view .bringSubviewToFront(birthdaySelectButton)
        self.view .bringSubviewToFront(signNameLabel)
        self.view .bringSubviewToFront(signDateLabel)
        self.view .bringSubviewToFront(DOBLabel)
        self.view .bringSubviewToFront(starIcon)
        self.view .bringSubviewToFront(startButton)
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        Utilities.showHUD(viewToShow: self.view)
        if(XAppDelegate.socialManager.isLoggedInFacebook()){
            self.fetchUserInfo()
        } else {
            XAppDelegate.socialManager.loginFacebook { (result, error) -> () in
                if(error == nil && FBSDKAccessToken .currentAccessToken() != nil){ // error
                    XAppDelegate.socialManager.loginZwigglers(FBSDKAccessToken .currentAccessToken().tokenString, completionHandler: { (result, error) -> Void in
                        if(error != nil){
                            Utilities.showAlertView(self, title: "Error occured", message: "Try again later")
                            Utilities.hideHUD(viewToHide: self.view)
                        } else {
                            dispatch_async(dispatch_get_main_queue(),{
                                self.fetchUserInfo()
                            })
                        }
                    })
                } else {
//                    Utilities.showAlertView(self, title: "Error occured", message: "Try again later")
                    Utilities.hideHUD(viewToHide: self.view)
                }
            }
        }
    }
    
    func reloadView(){
        var image = UIImage(named: "default_avatar")
        self.fbLoginBtn.setImage(image, forState: UIControlState.Normal)
        loginLabel.text = self.userFBName
        loginLabel.textColor = UIColor.whiteColor()
        loginLabel.font = UIFont.systemFontOfSize(14)
        
        if let url = NSURL(string: userFBImageURL) {
            self.downloadImage(url)
        }
    }
    
    func fetchUserInfo(){
        var params = Dictionary<String,String>()
        // params["fields"] = "name,id,gender,birthday"
            FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
                if(error == nil){
                    self.userFBID = result["id"] as! String
                    self.userFBName = result["name"] as! String
                    self.userFBImageURL = "https://graph.facebook.com/\(self.userFBID)/picture?type=large&height=75&width=75"
                    self.reloadView()
                    Utilities.hideHUD(viewToHide: self.view)
                } else {
                    Utilities.hideHUD(viewToHide: self.view)
                    println("fetch Info Error = \(error)")
                }
            })
        
    }
    
    // MARK: helpers
    
    func downloadImage(url:NSURL){
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                var downloadedImage = UIImage(data: data!)
                self.fbLoginBtn.setImage(downloadedImage, forState: UIControlState.Normal)
                self.fbLoginBtn.imageView!.layer.cornerRadius = 0.5 * self.fbLoginBtn.bounds.size.width
            }
        }
    }
    
    // MARK: Delegata methods
    
    override func wheelDidChangeValue(newValue : Horoscope?){
        
        if let newValue = newValue {
            self.signNameLabel.text = newValue.sign.uppercaseString
            self.signDateLabel.text = Utilities.getSignDateString(newValue.startDate, endDate: newValue.endDate)
            var index = find(XAppDelegate.horoscopesManager.horoscopesSigns, newValue)
            if(index != nil){
                self.selectedIndex = index!
            }
            self.starIcon.hidden = (XAppDelegate.userSettings.horoscopeSign != Int32(self.selectedIndex))
            self.signNameLabel.alpha = 0
            UILabel.beginAnimations("Fade-in", context: nil)
            UILabel.setAnimationDuration(0.6)
            self.signNameLabel.alpha = 1
            UILabel.commitAnimations()
        } else {
            self.signNameLabel.text = ""
            self.signDateLabel.text = ""
            return
        }
        
    }
    
    override func doneSelectedSign(){
        self.pushToDailyViewController()
    }
    
    // MARK: Button handlers
    
    func startButtonTapped(sender:UIButton!)
    {
        self.pushToDailyViewController()
    }
    
    func pushToDailyViewController(){
        XAppDelegate.userSettings.horoscopeSign = Int32(self.selectedIndex)
        var label = String(format: "type=primary,sign=%d", self.selectedIndex)
        XAppDelegate.sendTrackEventWithActionName(defaultChangeSetting, label: String(format: "default_sign=%d", self.selectedIndex), value: XAppDelegate.mobilePlatform.tracker.appOpenCounter)
        let customTabBarController = XAppDelegate.window!.rootViewController as! CustomTabBarController
        customTabBarController.selectedSign = self.selectedIndex
        customTabBarController.reload()
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
    
    @IBAction func birthdayButtonTapped(sender: AnyObject) {
        let selectBirthdayVC = self.storyboard!.instantiateViewControllerWithIdentifier("MyDatePickerViewController") as! MyDatePickerViewController
        selectBirthdayVC.setupViewController(self, type: BirthdayParentViewControllerType.LoginViewController, currentSetupBirthday: XAppDelegate.userSettings.birthday)
        var formSheet = MZFormSheetController(viewController: selectBirthdayVC)
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom;
        formSheet.cornerRadius = 0.0;
        formSheet.portraitTopInset = 0.0;
        formSheet.presentedFormSheetSize = Utilities.getScreenSize()
        
        XAppDelegate.window?.rootViewController?.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    func finishedSelectingBirthday(dateString : String){
        var signIndex = XAppDelegate.horoscopesManager.getSignIndexOfDate(birthday)
        self.wheel.autoRollToSignIndex(Int32(signIndex))
        birthdaySelectButton.titleLabel?.textAlignment = NSTextAlignment.Center
        birthdaySelectButton.setTitle(self.getBirthdayString(), forState: UIControlState.Normal)
        XAppDelegate.userSettings.birthday = birthday
        // TODO: sending updating Birthday is wrong, should do it later
         XAppDelegate.horoscopesManager.sendUpdateBirthdayRequest(dateString, completionHandler: { (responseDict, error) -> Void in
        })
    }
    
    func getBirthdayString() -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        
        let dayOfMonthFormatter = NSDateFormatter()
        dayOfMonthFormatter.dateFormat = "d"
        
        var dateString = dateFormatter.stringFromDate(birthday)
        var dayOfMonthFormatterString = dayOfMonthFormatter.stringFromDate(birthday)
        
        var date_day = dayOfMonthFormatterString.toInt()
        var suffix_string = "|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st"
        var suffixes = suffix_string.componentsSeparatedByString("|")
        var suffix = suffixes[date_day!]
        dateString = dateString.stringByAppendingString(suffix)
        
        return dateString
    }
    
}
