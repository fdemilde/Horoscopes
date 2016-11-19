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
        fbLoginBtn.backgroundColor = UIColor.clear
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
        birthdaySelectButton.titleLabel?.textAlignment = NSTextAlignment.center
        birthdaySelectButton.setTitle(self.getBirthdayString(), for: UIControlState())
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
        let startButtonFrame = CGRect(x: (Utilities.getScreenSize().width - startButtonImage!.size.width)/2, y: Utilities.getScreenSize().height - startButtonImage!.size.height, width: startButtonImage!.size.width, height: startButtonImage!.size.height)
        startButton = UIButton(type: UIButtonType.custom)
        startButton.frame = startButtonFrame
        startButton.setImage(startButtonImage, for: UIControlState())
        startButton.setTitle("", for: UIControlState())
//        startButton.backgroundColor = UIColor.blueColor()
        self.view .addSubview(startButton)
        startButton.addTarget(self, action: #selector(LoginVC.startButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        birthdaySelectButton.layer.shadowColor = UIColor.black.cgColor
        birthdaySelectButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        birthdaySelectButton.layer.shadowRadius = 2
        birthdaySelectButton.layer.shadowOpacity = 0.3
        birthdaySelectButton.layer.cornerRadius = 4
        
        if(XAppDelegate.socialManager.isLoggedInFacebook()){
            if let url = URL(string: XAppDelegate.currentUser.imgURL) {
                self.downloadImage(url)
            }
            loginLabel.text = XAppDelegate.currentUser.name
            loginLabel.textColor = UIColor.white
            loginLabel.font = UIFont.boldSystemFont(ofSize: 18)
            fbLoginBtn.isUserInteractionEnabled = false
        } else {
            fbLoginBtn.isUserInteractionEnabled = true
        }
        
        self.view .bringSubview(toFront: fbLoginBtn)
        self.view .bringSubview(toFront: loginLabel)
        self.view .bringSubview(toFront: birthdaySelectButton)
        self.view .bringSubview(toFront: signNameLabel)
        self.view .bringSubview(toFront: signDateLabel)
        self.view .bringSubview(toFront: DOBLabel)
        self.view .bringSubview(toFront: startButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view .bringSubview(toFront: startButton)
    }
    
    @IBAction func loginTapped(_ sender: AnyObject) {
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
                        DispatchQueue.main.async(execute: {
                            self.fetchUserInfo()
                        })
                    }
                }
            }
        }
    }
    
    func reloadView(){
        let image = UIImage(named: "default_avatar")
        self.fbLoginBtn.setImage(image, for: UIControlState())
        loginLabel.text = self.userFBName
        loginLabel.textColor = UIColor.white
        loginLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        if let url = URL(string: userFBImageURL) {
            self.downloadImage(url)
        }
    }
    
    func fetchUserInfo(){
        var params = Dictionary<String,String>()
        params["fields"] = "name,id,gender,birthday"
        let permissionLabel = "additional permission = \(params["fields"])"
        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginAsk, label: permissionLabel)
        
        FBSDKGraphRequest(graphPath: "me", parameters: params).start(completionHandler: { (connection, result, error) -> Void in
            if(error == nil){
                let json = result as! [String: AnyObject]
                self.userFBID = json["id"] as! String
                self.userFBName = json["name"] as! String
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
        alertView.addButton(withTitle: "No")
        alertView.addButton(withTitle: "Yes")
        alertView.tag = 1
        alertView.show()
    }
    
    // MARK: helpers
    
    func downloadImage(_ url:URL){
        Utilities.getDataFromUrl(url) { data in
            DispatchQueue.main.async {
                if let checkData = data {
                    let downloadedImage = UIImage(data: checkData)
                    self.fbLoginBtn.setImage(downloadedImage, for: UIControlState())
                    self.fbLoginBtn.imageView!.layer.cornerRadius = 0.5 * self.fbLoginBtn.bounds.size.width
                }
                
            }
        }
    }
    
    // MARK: Delegata methods
    
    override func wheelDidChangeValue(_ newValue: Horoscope!, becauseOf autoRoll: Bool) {
        if let newValue = newValue {
            self.signNameLabel.text = newValue.sign.uppercased()
            self.signDateLabel.text = Utilities.getSignDateString(newValue.startDate, endDate: newValue.endDate)
            let index = XAppDelegate.horoscopesManager.horoscopesSigns.index(of: newValue)
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
            birthdaySelectButton.setTitle("", for: UIControlState())
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
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
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
            alertView.addButton(withTitle: "OK, I get it")
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
    
    func getNotificationFiredTime() -> DateComponents{
        let components: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second]
        // use local time to fire notification
        let timeInterval = Date().timeIntervalSince1970 - 60 // set it 1 minute ealier to avoid firing immediately
        let date = Date(timeIntervalSince1970: timeInterval)
        return (Calendar.current as NSCalendar).components(components, from: date)
    }
    
    // MARK: Button handlers
    
    func startButtonTapped(_ sender:UIButton!)
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
            birthdaySelectButton.setTitle(self.getBirthdayString(), for: UIControlState())
            XAppDelegate.horoscopesManager.sendUpdateBirthdayRequest(self.birthdayStringInServerFormat, completionHandler: { (responseDict, error) -> Void in
            })
        }
        
        if(XAppDelegate.socialManager.isLoggedInFacebook()){
            // server sign is 1 - 12
            if(XAppDelegate.socialManager.isLoggedInZwigglers()){
                sendUpdateSign()
            } else {
                SocialManager.sharedInstance.loginZwigglers(FBSDKAccessToken.current().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        Utilities.showError(error, viewController: self)
                    } else {
                        self.sendUpdateSign()
                    }
                })
            }
        }

        self.dismiss(animated: true, completion: nil)
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
    
    @IBAction func birthdayButtonTapped(_ sender: AnyObject) {
        if(self.popUp == nil) {
            self.setupDatePickerPopup()
        } else {
            popUp.dismiss(animated: true)
            popTipViewWasDismissed(byUser: popUp)
            popUp = nil
        }
    }
    
    func finishedSelectingBirthday(_ dateString : String){
        let signName = XAppDelegate.horoscopesManager.getSignNameOfDate(birthday)
        self.wheel.autoRoll(toSign: signName)
        birthdaySelectButton.titleLabel?.textAlignment = NSTextAlignment.center
        XAppDelegate.userSettings.birthday = birthday
        self.birthdayStringInServerFormat = dateString
        birthdaySelectButton.setTitle(self.getBirthdayString(), for: UIControlState())
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
    @IBAction func outsideTapped(_ sender : UITapGestureRecognizer){
        if(popUp != nil) {
            popUp.dismiss(animated: true)
            popTipViewWasDismissed(byUser: popUp)
            popUp = nil
        }
    }
    
    // MARK: Poptipview setip
    
    func setupDatePickerPopup(){
        pickerView = MyDatePickerView(frame: CGRect(x: 0, y: 0, width: 280, height: 80))
        pickerView.delegate = self
        if let birthday = XAppDelegate.userSettings.birthday {
            pickerView.setCurrentBirthday(birthday)
        } else {
            pickerView.setCurrentBirthday(Utilities.getDefaultBirthday())
        }
        
        popUp = CMPopTipView(customView: pickerView)
        popUp.backgroundColor = UIColor(red:133.0/255, green:124.0/255, blue:173.0/255, alpha:1)
        popUp.delegate = self
        popUp.presentPointing(at: birthdaySelectButton, in: self.view, animated: true)
        popUp.borderColor = UIColor.clear
        popUp.borderWidth = 0
        popUp.cornerRadius = 4.0
        popUp.preferredPointDirection = PointDirection.down
        popUp.hasGradientBackground = false
        popUp.has3DStyle = false
        popUp.hasShadow = true
    }
    
    // MARK: Poptipview delegate
    func popTipViewWasDismissed(byUser popTipView: CMPopTipView!) {
        self.popUp = nil
    }
    
    // DatePickerView Delegate
    func didFinishPickingDate(_ dayString: String, monthString: String, yearString: String) {
        var yearString = yearString
        
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
    
    func getDateStringInNumberFormat(_ date : StandardDate) -> String{
        let result = String(format:"%d/%02d/%04d", date.day, date.month, date.year)
        return result
    }
    
    
    
}
