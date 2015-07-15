//
//  LoginVC.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/9/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class LoginVC : SpinWheelVC, SocialManagerDelegate {
    
    @IBOutlet weak var fbLoginBtn: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var separator: UIImageView!
    @IBOutlet weak var birthdayBg: UIView!
    @IBOutlet weak var birthdayLabel: UILabel!
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fbLoginBtn.layer.cornerRadius = 0.5 * fbLoginBtn.bounds.size.width
        fbLoginBtn.layer.cornerRadius = 100
        fbLoginBtn.imageView?.contentMode = UIViewContentMode.ScaleAspectFill
        fbLoginBtn.backgroundColor = UIColor.clearColor()
        fbLoginBtn.clipsToBounds = true
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
        self.view .bringSubviewToFront(birthdayBg)
        self.view .bringSubviewToFront(birthdayLabel)
        self.view .bringSubviewToFront(signNameLabel)
        self.view .bringSubviewToFront(signDateLabel)
        self.view .bringSubviewToFront(DOBLabel)
        self.view .bringSubviewToFront(starIcon)
        self.view .bringSubviewToFront(startButton)
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        XAppDelegate.socialManager.loginFacebook()
    }
    
    
    
    func facebookLoginFinishsed(result: FBSDKLoginManagerLoginResult, error: NSError?) {
        if(error != nil){
            println("Error when login FB = \(error)")
        } else if (result.isCancelled) {
            // Handle cancellations
        } else {
            if (result.grantedPermissions.contains("public_profile")) {
                // Do work
                fetchUserInfo()
            } else {
                // Permission denied
                println("Permission denied");
            }
        }
    }
    
    func facebookLoginTokenExists(token: FBSDKAccessToken) {
        fetchUserInfo()
    }
    
    func fetchUserInfo(){
        var params = Dictionary<String,String>()
//            params["fields"] = "name,id,gender,birthday"
        FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler({ (connection, result, error) -> Void in
            if(error == nil){
                println("User information = \(result)")
                self.userFBID = result["id"] as! String
                self.userFBName = result["name"] as! String
                self.userFBImageURL = "https://graph.facebook.com/\(self.userFBID)/picture?type=large&height=75&width=75"
                self.loginZwigglers(FBSDKAccessToken .currentAccessToken().tokenString)
            } else {
                Utilities.hideHUD()
                println("fetch Info Error = \(error)")
            }
        })
    }
    
    func loginZwigglers(token: String){
        var params = NSMutableDictionary(objectsAndKeys: "facebook","login_method",FACEBOOK_APP_ID,"app_id",token, "access_token")
        XAppDelegate.mobilePlatform.userModule.loginWithParams(params, andCompleteBlock: { (responseDict, error) -> Void in
            if ((error) != nil){
                println("Error when Login Zwigglers = \(error)")
            }
            else {
                println("responseDict when Login Zwigglers = \(responseDict)")
//                XAppDelegate.currentUser.uid = ...
            }
            Utilities.hideHUD()
            self.reloadView()
        })
    }
    
    // MARK: helpers
    func reloadView(){
        var image = UIImage(named: "default_avatar")
        println("Image width 1111 === \(image?.size.width)")
        fbLoginBtn.imageView!.image = image
        loginLabel.text = self.userFBName
        loginLabel.textColor = UIColor.whiteColor()
        loginLabel.font = UIFont.systemFontOfSize(14)
        
        if let url = NSURL(string: userFBImageURL) {
            self.downloadImage(url)
        }
        
    }
    
    func downloadImage(url:NSURL){
        println("Started downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
        Utilities.getDataFromUrl(url) { data in
            dispatch_async(dispatch_get_main_queue()) {
                println("Finished downloading \"\(url.lastPathComponent!.stringByDeletingPathExtension)\".")
                var downloadedImage = UIImage(data: data!)
                println("Image width === \(downloadedImage?.size.width)")
                self.fbLoginBtn.imageView!.image = downloadedImage
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
                self.selectedIndex = index!;
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
        let customTabBarController = self.storyboard!.instantiateViewControllerWithIdentifier("CustomTabBarController") as! CustomTabBarController
        customTabBarController.selectedSign = self.selectedIndex
        
        self.mz_dismissFormSheetControllerAnimated(true, completionHandler: nil)
    }
    
}
