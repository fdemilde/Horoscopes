//
//  LoginVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class LoginVC : SpinWheelVC, SocialManagerDelegate, UIAlertViewDelegate, CMPopTipViewDelegate, MyDatePickerViewDelegate {
    
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var birthdaySelectButton: UIButton!
    @IBOutlet weak var signNameLabel: UILabel!
    @IBOutlet weak var signDateLabel: UILabel!
    @IBOutlet weak var DOBLabel: UILabel!
    
    @IBOutlet weak var starIcon: UIImageView!
    @IBOutlet var containerView: UIView!
    
    
    @IBOutlet weak var fbLoginButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbLoginLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var DOBLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var birthdayBgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signDateLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var starIconTopConstraint: NSLayoutConstraint!
    var startButton : UIButton!
    var popUp : CMPopTipView!
    var pickerView : MyDatePickerView!
    
    var userFBID = ""
    var userFBName = ""
    var userFBImageURL = ""
    var userFBBirthdayString = ""
    var birthday : NSDate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginBtn.backgroundColor = UIColor.clearColor()
        fbLoginBtn.imageView!.clipsToBounds = true
        XAppDelegate.socialManager.delegate = self
        self.setupComponents()
        self.initialBirthday()
    }
    
    func initialBirthday(){
        birthday = XAppDelegate.userSettings.birthday
        birthdaySelectButton.titleLabel?.textAlignment = NSTextAlignment.Center
        birthdaySelectButton.setTitle(self.getBirthdayString(), forState: UIControlState.Normal)
    }
    
    func setupComponents(){
        var ratio = Utilities.getRatio()
        fbLoginButtonTopConstraint.constant = (fbLoginButtonTopConstraint.constant * ratio)
        fbLoginLabelTopConstraint.constant = (fbLoginLabelTopConstraint.constant * ratio)
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
        
        birthdaySelectButton.layer.shadowColor = UIColor.blackColor().CGColor
        birthdaySelectButton.layer.shadowOffset = CGSizeMake(0, 2)
        birthdaySelectButton.layer.shadowRadius = 2
        birthdaySelectButton.layer.shadowOpacity = 0.3
        birthdaySelectButton.layer.cornerRadius = 4
        
        self.view .bringSubviewToFront(fbLoginBtn)
        self.view .bringSubviewToFront(loginLabel)
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
            XAppDelegate.socialManager.login { (error, permissionGranted) -> Void in
                Utilities.hideHUD(viewToHide: self.view)
                if(error != nil){
                    Utilities.showAlertView(self, title: "Error occured", message: "Try again later")
                    return
                } else {
                    if(permissionGranted == false){
                        Utilities.showAlertView(self, title: "Permission denied", message: "Please check your permission again")
                        return
                    } else {
                        dispatch_async(dispatch_get_main_queue(),{
                            self.fetchUserInfo()
                        })
                    }
                }
            }
        }
    }
    
    func reloadView(){
        var image = UIImage(named: "default_avatar")
        self.fbLoginBtn.setImage(image, forState: UIControlState.Normal)
        loginLabel.text = self.userFBName
        loginLabel.textColor = UIColor.whiteColor()
        loginLabel.font = UIFont.boldSystemFontOfSize(18)
        
        if let url = NSURL(string: userFBImageURL) {
            self.downloadImage(url)
        }
    }
    
    func fetchUserInfo(){
        var params = Dictionary<String,String>()
         params["fields"] = "name,id,gender,birthday"
            FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
                if(error == nil){
                    println("result result === \(result)")
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
        if(self.popUp == nil) {
            self.setupDatePickerPopup()
        } else {
            popUp.dismissAnimated(true)
            popTipViewWasDismissedByUser(popUp)
            popUp = nil
        }
    }
    
    func finishedSelectingBirthday(dateString : String){
        var signName = XAppDelegate.horoscopesManager.getSignNameOfDate(birthday)
        self.wheel.autoRollToSign(signName)
        birthdaySelectButton.titleLabel?.textAlignment = NSTextAlignment.Center
        XAppDelegate.userSettings.birthday = birthday
        birthdaySelectButton.setTitle(self.getBirthdayString(), forState: UIControlState.Normal)
        // TODO: sending updating Birthday is wrong, should do it later
//         XAppDelegate.horoscopesManager.sendUpdateBirthdayRequest(dateString, completionHandler: { (responseDict, error) -> Void in
//        })
    }
    
    // MARK: helpers
    
    func getBirthdayString() -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let dayOfMonthFormatter = NSDateFormatter()
        dayOfMonthFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dayOfMonthFormatter.dateFormat = "d"
        var dateString = dateFormatter.stringFromDate(getDefaultBirthday())
        var dayOfMonthFormatterString = dayOfMonthFormatter.stringFromDate(getDefaultBirthday())
        if let birthday = birthday{
            dateString = dateFormatter.stringFromDate(birthday)
            dayOfMonthFormatterString = dayOfMonthFormatter.stringFromDate(birthday)
        }
        
        
        var date_day = dayOfMonthFormatterString.toInt()
        var suffix_string = "|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st"
        var suffixes = suffix_string.componentsSeparatedByString("|")
        var suffix = suffixes[date_day!]
        dateString = dateString.stringByAppendingString(suffix)
        
        return dateString
    }
    
    // MARK: Gesture Recognize
    @IBAction func outsideTapped(sender : UITapGestureRecognizer){
        var touchLocation = sender.locationInView(self.containerView)
        if(popUp != nil) {
            popUp.dismissAnimated(true)
            popTipViewWasDismissedByUser(popUp)
            popUp = nil
        }
    }
    
    // MARK: Poptipview setip
    
    func setupDatePickerPopup(){
        pickerView = MyDatePickerView(frame: CGRectMake(0, -60, 240, 80))
        pickerView.delegate = self
        if let birthday = XAppDelegate.userSettings.birthday {
            pickerView.setCurrentBirthday(XAppDelegate.userSettings.birthday)
        } else {
            pickerView.setCurrentBirthday(getDefaultBirthday())
        }
        
        popUp = CMPopTipView(customView: pickerView)
        popUp.backgroundColor = UIColor(red:133.0/255, green:124.0/255, blue:173.0/255, alpha:1)
        popUp.delegate = self
        popUp.presentPointingAtView(birthdaySelectButton, inView: self.view, animated: true)
        popUp.borderColor = UIColor.clearColor()
        popUp.borderWidth = 0
        popUp.cornerRadius = 4.0
        popUp.preferredPointDirection = PointDirection.Down
        popUp.hasGradientBackground = false
        popUp.has3DStyle = false
        popUp.hasShadow = true
    }
    
    // MARK: Poptipview delegate
    func popTipViewWasDismissedByUser(popTipView: CMPopTipView!) {
        self.popUp = nil
    }
    
    // DatePickerView Delegate
    func didFinishPickingDate(dayString: String, monthString: String) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        var dateString = String(format:"%@/%@",dayString,monthString)
        var selectedDate = dateFormatter.dateFromString(dateString)
        var dateStringInNumberFormat = self.getDateStringInNumberFormat(selectedDate!)
        self.birthday = selectedDate
        self.finishedSelectingBirthday(dateStringInNumberFormat)
    }
    
    func getDateStringInNumberFormat(date : NSDate) -> String{
        let components = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
        var comp = NSCalendar.currentCalendar().components(components, fromDate: date)
        var result = String(format:"%d/%02d", comp.day, comp.month)
        return result
    }
    
    func getDefaultBirthday() -> NSDate{ // return default birthday for first load
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString("25/11")!
    }
    
}
