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
    @IBOutlet var containerView: UIView!
    var birthdayStringInServerFormat : String!
    
    @IBOutlet weak var fbLoginButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbLoginLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fbNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var DOBLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var birthdayBgTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signNameLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var signDateLabelTopConstraint: NSLayoutConstraint!
    var startButton : UIButton!
    var popUp : CMPopTipView!
    var pickerView : MyDatePickerView!
    
    var userFBID = ""
    var userFBName = ""
    var userFBImageURL = ""
    var userFBBirthdayString = ""
    var birthday : StandardDate!
    var agreeToDailyPush = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginBtn.backgroundColor = UIColor.clearColor()
        fbLoginBtn.imageView!.clipsToBounds = true
        XAppDelegate.socialManager.delegate = self
        if Utilities.isFirstTimeUsing() {
            self.showNotificationEverydayAlert()
        }
        self.setupComponents()
        self.initialBirthday()
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dobOpen, label: nil)
        
    }
    
    func initialBirthday(){
        birthday = XAppDelegate.userSettings.birthday
        birthdaySelectButton.titleLabel?.textAlignment = NSTextAlignment.Center
        birthdaySelectButton.setTitle(self.getBirthdayString(), forState: UIControlState.Normal)
    }
    
    func setupComponents(){
        let ratio = Utilities.getRatioForViewWithWheel()
        fbLoginButtonTopConstraint.constant = (fbLoginButtonTopConstraint.constant * ratio)
        fbLoginLabelTopConstraint.constant = (fbLoginLabelTopConstraint.constant * ratio)
        DOBLabelTopConstraint.constant = (DOBLabelTopConstraint.constant * ratio)
        
        birthdayBgTopConstraint.constant = (birthdayBgTopConstraint.constant * ratio)
        signNameLabelTopConstraint.constant = (signNameLabelTopConstraint.constant * ratio)
        signDateLabelTopConstraint.constant = (signDateLabelTopConstraint.constant * ratio)
        
        let startButtonImage = UIImage(named: "start_button")
        let startButtonFrame = CGRectMake((Utilities.getScreenSize().width - startButtonImage!.size.width)/2, Utilities.getScreenSize().height - startButtonImage!.size.height, startButtonImage!.size.width, startButtonImage!.size.height)
        startButton = UIButton(type: UIButtonType.Custom)
        startButton.frame = startButtonFrame
        startButton.setImage(startButtonImage, forState: UIControlState.Normal)
        startButton.setTitle("", forState: UIControlState.Normal)
//        startButton.backgroundColor = UIColor.blueColor()
        self.view .addSubview(startButton)
        startButton.addTarget(self, action: #selector(LoginVC.startButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        birthdaySelectButton.layer.shadowColor = UIColor.blackColor().CGColor
        birthdaySelectButton.layer.shadowOffset = CGSizeMake(0, 2)
        birthdaySelectButton.layer.shadowRadius = 2
        birthdaySelectButton.layer.shadowOpacity = 0.3
        birthdaySelectButton.layer.cornerRadius = 4
        
        if(XAppDelegate.socialManager.isLoggedInFacebook()){
            if let url = NSURL(string: XAppDelegate.currentUser.imgURL) {
                self.downloadImage(url)
            }
            loginLabel.text = XAppDelegate.currentUser.name
            loginLabel.textColor = UIColor.whiteColor()
            loginLabel.font = UIFont.boldSystemFontOfSize(18)
            fbLoginBtn.userInteractionEnabled = false
        } else {
            fbLoginBtn.userInteractionEnabled = true
        }
        
        self.view .bringSubviewToFront(fbLoginBtn)
        self.view .bringSubviewToFront(loginLabel)
        self.view .bringSubviewToFront(birthdaySelectButton)
        self.view .bringSubviewToFront(signNameLabel)
        self.view .bringSubviewToFront(signDateLabel)
        self.view .bringSubviewToFront(DOBLabel)
        self.view .bringSubviewToFront(startButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view .bringSubviewToFront(startButton)
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        Utilities.showHUD(self.view)
        if(XAppDelegate.socialManager.isLoggedInFacebook()){
            self.fetchUserInfo()
        } else {
            XAppDelegate.socialManager.login(self) { (error, permissionGranted) -> Void in
                Utilities.hideHUD(self.view)
                if(error != nil){
                    print("loginTapped error == \(error)")
                    Utilities.showAlertView(self, title: "Error", message: "An error has occured, please try again later")
                    return
                } else {
                    if(permissionGranted == false){
                        Utilities.showAlertView(self, title: "Permission denied", message: "Please grant permissions and try again")
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
        let image = UIImage(named: "default_avatar")
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
        let permissionLabel = "additional permission = \(params["fields"])"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginAsk, label: permissionLabel)
        
            FBSDKGraphRequest(graphPath: "me", parameters: params).startWithCompletionHandler({ (connection, result, error) -> Void in
                if(error == nil){
                    self.userFBID = result["id"] as! String
                    self.userFBName = result["name"] as! String
                    self.userFBImageURL = "https://graph.facebook.com/\(self.userFBID)/picture?type=large&height=75&width=75"
                    self.reloadView()
                    Utilities.hideHUD(self.view)
                } else {
                    Utilities.hideHUD(self.view)
                    print("fetch Info Error = \(error)")
                }
            })
        
    }
    
    func showNotificationEverydayAlert(){
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.firstLoadDailyAsk, label: "")
        let alertView: UIAlertView = UIAlertView()
        alertView.delegate = self
        alertView.title = "Notify everyday"
        alertView.message = "Do you want to be notified of your horoscope every day?"
        alertView.addButtonWithTitle("No")
        alertView.addButtonWithTitle("Yes")
        alertView.tag = 1
        alertView.show()
    }
    
    // MARK: helpers
    
    func downloadImage(url:NSURL){
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                if let checkData = data {
                    let downloadedImage = UIImage(data: checkData)
                    self.fbLoginBtn.setImage(downloadedImage, forState: UIControlState.Normal)
                    self.fbLoginBtn.imageView!.layer.cornerRadius = 0.5 * self.fbLoginBtn.bounds.size.width
                }
                
            }
        }
    }
    
    // MARK: Delegata methods
    
    override func wheelDidChangeValue(newValue: Horoscope!, becauseOf autoRoll: Bool) {
        if let newValue = newValue {
            self.signNameLabel.text = newValue.sign.uppercaseString
            self.signDateLabel.text = Utilities.getSignDateString(newValue.startDate, endDate: newValue.endDate)
            let index = XAppDelegate.horoscopesManager.horoscopesSigns.indexOf(newValue)
            if(index != nil){
                if(self.selectedIndex != index!){
                    XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dobSignChange, label: "sign = \(index! + 1)")
                }
                self.selectedIndex = index!
            }
            self.signNameLabel.alpha = 0
            UILabel.beginAnimations("Fade-in", context: nil)
            UILabel.setAnimationDuration(0.6)
            self.signNameLabel.alpha = 1
            UILabel.commitAnimations()
            if !autoRoll {
                var year = defaultYear
                if let appDelegateBirthday = XAppDelegate.userSettings.birthday {
                    year = (Int)(appDelegateBirthday.year)
                }
                XAppDelegate.userSettings.birthday = StandardDate(day: newValue.startDate.day, month: newValue.startDate.month, year: (Int32)(year))
                initialBirthday()
            }
        } else {
            self.signNameLabel.text = ""
            self.signDateLabel.text = ""
            birthdaySelectButton.setTitle("", forState: UIControlState.Normal)
            return
        }
    }
    
    override func doneSelectedSign(){
        var trackerLabel = "sign = \(self.selectedIndex + 1)"
        if let dobString = birthdaySelectButton.titleLabel!.text {
            trackerLabel += ", dob = \(dobString)"
        }
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dobSaveSign, label: trackerLabel)
        self.pushToDailyViewController()
    }
    
    // MARK: AlertView Delegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if(alertView.tag == 1){
            var replyLabel = ""
            if(buttonIndex == 0){
                replyLabel += "daily = 0"
                agreeToDailyPush = false
            } else {
                replyLabel += "daily = 1"
                agreeToDailyPush = true
            }
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.firstLoadDailyReply, label: replyLabel)
            let alertView: UIAlertView = UIAlertView()
            alertView.delegate = self
            alertView.title = "Did you know?"
            alertView.message = "You can change your horoscope sign and delivery preferences from your profile page"
            alertView.addButtonWithTitle("OK, I get it")
            alertView.tag = 2
            alertView.show()
        }
        
        if(alertView.tag == 2){
            if(agreeToDailyPush){
                Utilities.registerForRemoteNotification()
                Utilities.setLocalPush(getNotificationFiredTime())
                XAppDelegate.userSettings.notifyOfNewHoroscope = true
            }
            
        }
    }
    
    func getNotificationFiredTime() -> NSDateComponents{
        let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        // use local time to fire notification
        let timeInterval = NSDate().timeIntervalSince1970 - 60 // set it 1 minute ealier to avoid firing immediately
        let date = NSDate(timeIntervalSince1970: timeInterval)
        return NSCalendar.currentCalendar().components(components, fromDate: date)
    }
    
    // MARK: Button handlers
    
    func startButtonTapped(sender:UIButton!)
    {
        var trackerLabel = "sign = \(self.selectedIndex + 1)"
        if let dobString = birthdaySelectButton.titleLabel!.text {
            trackerLabel += ", dob = \(dobString)"
        }
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dobStart, label: trackerLabel)
        self.pushToDailyViewController()
    }
    
    func pushToDailyViewController(){
        XAppDelegate.userSettings.horoscopeSign = Int32(self.selectedIndex)
        let customTabBarController = XAppDelegate.window!.rootViewController as! CustomTabBarController
        customTabBarController.selectedSign = self.selectedIndex
        customTabBarController.reload()
        
        // update user birthday and sign
        if(self.birthdayStringInServerFormat != nil){
            birthdaySelectButton.setTitle(self.getBirthdayString(), forState: UIControlState.Normal)
            XAppDelegate.horoscopesManager.sendUpdateBirthdayRequest(self.birthdayStringInServerFormat, completionHandler: { (responseDict, error) -> Void in
            })
        }
        
        if(XAppDelegate.socialManager.isLoggedInFacebook()){
            // server sign is 1 - 12
            if(XAppDelegate.socialManager.isLoggedInZwigglers()){
                sendUpdateSign()
            } else {
                SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        self.sendUpdateSign()
                    }
                })
            }
        }

        self.dismissViewControllerAnimated(true, completion: nil)
//        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
        
    func sendUpdateSign(){
        XAppDelegate.socialManager.sendUserUpdateSign(Int(XAppDelegate.userSettings.horoscopeSign + 1), completionHandler: { (result, error) -> Void in
            if let error = error {
                print("Send update user gets error = \(error)")
            } else {
                let errorCode = result?["error"] as! Int
                if(errorCode == 0){
                    XAppDelegate.socialManager.persistUserProfile(true, completionHandler: { (error) -> Void in
                    })
                } else {
                    print("Error code === \(errorCode)")
                }
            }
        })
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
        let signName = XAppDelegate.horoscopesManager.getSignNameOfDate(birthday)
        self.wheel.autoRollToSign(signName)
        birthdaySelectButton.titleLabel?.textAlignment = NSTextAlignment.Center
        
        XAppDelegate.userSettings.birthday = birthday
        self.birthdayStringInServerFormat = dateString
        birthdaySelectButton.setTitle(self.getBirthdayString(), forState: UIControlState.Normal)
    }
    
    // MARK: helpers
    
    func getBirthdayString() -> String{
        var dateString = ""
        if let birthday = birthday {
            dateString = birthday.toStringWithDaySuffix()
        } else {
            if(XAppDelegate.userSettings.horoscopeSign != -1){
                let signIndex = Int(XAppDelegate.userSettings.horoscopeSign)
                let sign = XAppDelegate.horoscopesManager.horoscopesSigns[signIndex]
                dateString = sign.startDate.toStringWithDaySuffix()
            } else {
                dateString = Utilities.getDefaultBirthday().toStringWithDaySuffix()
            }
        }
        
        return dateString
    }
    
    // MARK: Gesture Recognize
    @IBAction func outsideTapped(sender : UITapGestureRecognizer){
        if(popUp != nil) {
            popUp.dismissAnimated(true)
            popTipViewWasDismissedByUser(popUp)
            popUp = nil
        }
    }
    
    // MARK: Poptipview setip
    
    func setupDatePickerPopup(){
        pickerView = MyDatePickerView(frame: CGRectMake(0, 0, 280, 80))
        pickerView.delegate = self
        if let birthday = XAppDelegate.userSettings.birthday {
            pickerView.setCurrentBirthday(birthday)
        } else {
            pickerView.setCurrentBirthday(Utilities.getDefaultBirthday())
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
    func didFinishPickingDate(dayString: String, monthString: String, var yearString: String) {
        
        yearString = yearString == "" ? String(defaultYear) : yearString
        
        let dateString = String(format:"%@/%@/%@",dayString,monthString, yearString)
        let label = "dob = " + dateString
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.dobDobChange, label: label)
        let monthAsInt = Utilities.getMonthAsNumberFromMonthName(monthString)
        let selectedDate = StandardDate(day: (Int32)(dayString)!, month: (Int32)(monthAsInt), year: (Int32)(yearString)!)
        
        let dateStringInNumberFormat = self.getDateStringInNumberFormat(selectedDate!)
        self.birthday = selectedDate
        self.finishedSelectingBirthday(dateStringInNumberFormat)
    }
    
    func getDateStringInNumberFormat(date : StandardDate) -> String{
        let result = String(format:"%d/%02d/%04d", date.day, date.month, date.year)
        return result
    }
    
    
    
}
