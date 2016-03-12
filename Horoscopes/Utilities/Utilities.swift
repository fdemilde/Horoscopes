//
//  Utilities.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class Utilities {
    
    // MARK: - Construct a shape layer for drawing circle
    class func layerForCircle(centerPoint: CGPoint, radius: CGFloat, lineWidth: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        let layer = CAShapeLayer()
        layer.path = path.CGPath
        layer.lineWidth = lineWidth
        return layer
    }
    
    // MARK: Parsing helpers
    class func parseNSDictionaryToDictionary(dict : NSDictionary) -> Dictionary<String, AnyObject>{
        var result = Dictionary<String, AnyObject>()
        let keys = dict.allKeys
        for key in keys{
            let keyString = key as! String
            result[keyString] = dict.objectForKey(keyString)
        }
        return result
    }
    
    class func parseDictionaryToNSDictionary(dict : Dictionary<String, AnyObject>) -> NSDictionary{
        let result = NSMutableDictionary()
        let keys = dict.keys
        
        for key in keys{
            let keyString = key as String
            result.setObject(dict[keyString]!, forKey: keyString)
        }
        return result
    }
    
    class func parseArrayToNSArray(array : [AnyObject]) -> NSArray{
        let result = NSMutableArray()
        
        for var i = 0; i < array.count; i++ {
            result.addObject(array[i])
        }
        return result
    }
    
    // MARK: Screen size
    
    class func getScreenSize() -> CGSize{
        let screenRect = UIScreen.mainScreen().bounds
        let height = screenRect.height
        let width = screenRect.width
        return CGSizeMake(width, height)
    }
    
    class func getPositionBaseOn568hScreenSize(positionX : Float, positionY: Float) -> CGPoint{
        let screenSize = Utilities.getScreenSize()
        
        let percentageX = positionX / 320
        let percentageY = positionY / 568
        
        let result =  CGPointMake(screenSize.width * CGFloat(percentageX), screenSize.height * CGFloat(percentageY))
        
        return result
    }
    
    class func getRatioForViewWithWheel() -> CGFloat {
        let screenSize = Utilities.getScreenSize()
        // 211 is wheel height
        let customScreenSize = screenSize.height - 211
        
        let ratio = Float(customScreenSize/(800-211))
        return CGFloat(ratio)
    }
    
    class func getRatio() -> CGFloat {
        let screenSize = Utilities.getScreenSize()
        let customScreenSize = screenSize.height
        
        let ratio = Float(customScreenSize/568)
        return CGFloat(ratio)
    }
    
    // support when set view.backgroundColor with image pattern, we need to get the image with right screensize first or the image will be displayed repeatedly
    class func getImageToSupportSize(name : String,size : CGSize, frame : CGRect) -> UIImage{
        UIGraphicsBeginImageContext(size)
        UIImage(named: name)!.drawInRect(frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    // MARK: HUD
    class func showHUD(viewToShow : UIView? = nil){
        
        dispatch_async(dispatch_get_main_queue(),{
            var loadingNotification : MBProgressHUD!
            if let viewToShow = viewToShow {
                loadingNotification = MBProgressHUD.showHUDAddedTo(viewToShow, animated: true)
            } else {
                let viewController = XAppDelegate.window!.rootViewController
                loadingNotification = MBProgressHUD.showHUDAddedTo(viewController!.view, animated: true)
            }
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            
        })
    }
    
    class func hideHUD(viewToHide : UIView? = nil){
        dispatch_async(dispatch_get_main_queue(),{
            if let viewToHide = viewToHide {
                MBProgressHUD.hideAllHUDsForView(viewToHide, animated: true)
            } else {
                let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
                let viewController = appDelegate.window!.rootViewController
                MBProgressHUD.hideAllHUDsForView(viewController!.view, animated: true)
            }
        })
    }
    
    // MARK: Newsfeed, User profile and user post parsing helpers
    
    class func parseFeedsArray(userDataDict : Dictionary<String, AnyObject>, postsDataArray : [AnyObject]) -> [UserPost]{
        var resultArray = [UserPost]()
        var userDict = Utilities.parseUsersArray(userDataDict)
        
        for postData in postsDataArray{
            
            let postObject = UserPost(data: postData as! NSDictionary)
            if(postObject != nil){
                let uid = postObject!.uid
                let uidString = String(format: "%d", uid)
                if let userObj = userDict[uidString] {
                    postObject!.user = userObj
                }
                resultArray.append(postObject!)
            }
            
        }
        
        return resultArray
    }
    
    class func parseUsersArray(userDataDict : Dictionary<String, AnyObject>) -> Dictionary<String, UserProfile>{ // return Dict<uid,UserProfile>
        var userDict = Dictionary<String, UserProfile>()
        for (uid, userData) in userDataDict {
            let userObject = UserProfile(data: userData as! NSDictionary)
            userDict[uid] = userObject
        }
        return userDict
    }
    
    class func getNewsfeedTypeByString(typeString : String) -> NewsfeedType{
        if(typeString == "onyourmind") {return NewsfeedType.OnYourMind}
        if(typeString == "shareadvice") {return NewsfeedType.ShareAdvice}
        if(typeString == "howhoroscope") {return NewsfeedType.HowHoroscope}
        if(typeString == "fortune") {return NewsfeedType.Fortune}
        return NewsfeedType.Invalid
    }
    
    class func getDefaultBirthday() -> StandardDate{ // return default birthday for first load
        return StandardDate(day: 22, month: 11)
    }
    
    class func getMonthAsNumberFromMonthName(monthName : String) -> Int{
        let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        if let monthIdex = monthArray.indexOf(monthName){
            return monthIdex + 1;
        }
        return 12;
    }
    
    // MARK: Alert
    class func showAlertView(delegate: UIAlertViewDelegate?, title:String, message:String, tag : Int? = -1){
        dispatch_async(dispatch_get_main_queue(),{
            let alertView: UIAlertView = UIAlertView()
            
            alertView.delegate = delegate
            alertView.title = title
            alertView.message = message
            alertView.addButtonWithTitle("OK")
            alertView.tag = tag!
            alertView.show()
        })
    }
    
    class func showAlert(viewController: UIViewController, title: String, message: String = "", error: NSError?) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if #available(iOS 8.0, *) {
                if viewController.presentedViewController == nil {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
//                    if let error = error {
//                        alert.message = "\(message) \(error)"
//                    }
                    let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(action)
                    viewController.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                Utilities.showAlertView(nil, title: title, message: message)
            }
        })
    }
    
    // MARK: - Convenience
    
    class func showError(error: NSError, viewController : UIViewController? = nil) {
        if let viewController = viewController{
            self.showAlert(viewController, title: "Network Error", message: "There is an error. Action cannot be completed. Please try again later!", error: error)
        } else {
            self.showAlert(XAppDelegate.window!.rootViewController!, title: "Network Error", message: "There is an error. Action cannot be completed. Please try again later!", error: error)
        }
        
    }
    
    // MARK: Helpers
    
    class func horoscopeSignString(fromSignNumber sign: Int) -> String {
        if sign >= 0 {
            return HoroscopesManager.sharedInstance.getHoroscopesSigns()[sign].sign
        } else {
            return ""
        }
    }
    
    class func horoscopeSignImage(fromSignNumber sign: Int) -> UIImage {
        if sign >= 0 {
            return UIImage(named: String(format:"%@_selected", horoscopeSignString(fromSignNumber: sign)))!
        } else {
            return UIImage()
        }
    }
    
    class func horoscopeSignIconImage(fromSignNumber sign: Int) -> UIImage {
        if sign >= 0 {
            return UIImage(named: String(format:"%@_icon_selected", horoscopeSignString(fromSignNumber: sign)))!
        } else {
            return UIImage()
        }
    }
    
    class func getImageFromUrlString(imgUrl: String, completionHandler: (image: UIImage?) -> Void) {
        if let url = NSURL(string: imgUrl) {
            NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    completionHandler(image: UIImage(data: data))
                } else {
                    completionHandler(image: UIImage())
                }
                
                
            }).resume()
        }
    }
    
    class func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    class func loadNIB(file:String) -> AnyObject{
        var arr = NSBundle.mainBundle().loadNibNamed(file, owner: nil, options: nil)
        
        let ret: AnyObject = arr[0];
        return ret;
    }
    
    class func getLabelSizeWithString(text : String, font: UIFont) -> CGSize {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, CGFloat.max, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }
    
    class func getParentUIViewController(view : UIView) -> UIResponder{
        var responder = view as UIResponder
        while(responder.isKindOfClass(UIView.classForCoder())){
            responder = responder.nextResponder()!
        }
        return responder
        
    }
    
    class func getHoroscopeNameWithIndex(index: Int) -> String{
        let horo = XAppDelegate.horoscopesManager.horoscopesSigns[index] as Horoscope
        return horo.sign
    }
    
    
    class func getFeedTypeImageName(type : NewsfeedType) -> String{
        switch(type){
        case NewsfeedType.OnYourMind:
            return "post_type_mind"
        case NewsfeedType.HowHoroscope:
            return "post_type_horoscope"
        case NewsfeedType.ShareAdvice:
            return "post_type_advice"
        case NewsfeedType.Fortune:
            return "post_type_fortune"
        case NewsfeedType.Invalid:
            return ""
        }
    }
    
    // Corner Radius manipulation 
    class func makeCornerRadius(view : UIView, maskFrame : CGRect, roundOptions : UIRectCorner, radius : CGFloat) -> UIView {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: roundOptions, cornerRadii: CGSizeMake(radius, radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = maskFrame
        maskLayer.path = maskPath.CGPath
        view.layer.mask = maskLayer
        return view
    }
    
    // MARK: Time format
    class func getTimeAgoString(ts : Int) -> String {
        let timeAgoDate = NSDate(timeIntervalSince1970: NSTimeInterval(ts))
        return timeAgoDate.timeAgoSinceNow()
    }
    
    class func getSignDateString(startDate : NSDate, endDate:NSDate) -> String{
//        print("getSignDateString == \(startDate) || endDate = \(endDate)")
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return String(format: "%@ - %@", dateFormatter.stringFromDate(startDate),dateFormatter.stringFromDate(endDate))
    }
    
    class func getDateStringFromTimestamp(ts : NSTimeInterval, dateFormat : String) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let date = NSDate(timeIntervalSince1970:ts)
        let dateString = String(format: "%@", dateFormatter.stringFromDate(date))
        return dateString
    }
    
    class func getDateFromDateString(dateString : String, format : String, useLocalTimezone : Bool? = false) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString(dateString)!
    }
    
    // MARK: Notification support
    class func postNotification(name: String, object:AnyObject?){
        dispatch_async(dispatch_get_main_queue(),{
            NSNotificationCenter.defaultCenter().postNotificationName(name, object: object)
        })
    }
    
    // MARK: - Share helper
    
    class func presentShareFormSheetController(hostViewController: UIViewController, shareViewController: ShareViewController) {
        let formSheet = MZFormSheetController(viewController: shareViewController)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.SlideFromBottom
        formSheet.cornerRadius = 5.0
        formSheet.portraitTopInset = (Utilities.getScreenSize().height - SHARE_HYBRID_HEIGHT) / 2
        formSheet.presentedFormSheetSize = CGSizeMake(Utilities.getScreenSize().width - 20, SHARE_HYBRID_HEIGHT)
        hostViewController.mz_presentFormSheetController(formSheet, animated: true, completionHandler: nil)
    }
    
    class func getShareViewController() -> ShareViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareViewController = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        return shareViewController
    }
    
    // MARK: Cache helpers
    class func getKeyFromUrlAndPostData(url : String, postData : NSMutableDictionary?) -> String {
        var key = url
        if let postData = postData{
            for (postKey, value) in postData {
                key += "|\(postKey)|\(value)"
            }
        }
        return key
    }
    
    // MARK: Remote & Local Notification
    
    class func isNotificationGranted() -> Bool {
        if #available(iOS 8.0, *) {
            if let notificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings() {
                let currentNotificationTypes = notificationSettings.types
                if currentNotificationTypes.isEmpty {
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        } else {
            // Fallback on earlier versions
            let enabledNotificationTypes = UIApplication.sharedApplication().enabledRemoteNotificationTypes()
            if(enabledNotificationTypes.isEmpty){
                return false
            } else {
                return true
            }
        }
    }
    
    class func registerForRemoteNotification(){
        if #available(iOS 8.0, *) {
            let types : UIUserNotificationType = [.Sound, .Badge, .Alert]
            let notifSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(notifSettings)
        } else {
            // Fallback on earlier versions
            let types : UIRemoteNotificationType = [.Sound, .Badge, .Alert]
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }
    }
    
    class func isFirstTimeUsing() -> Bool {
        if(XAppDelegate.userSettings.horoscopeSign == -1){
            return true
        } else { return false }
        
    }
    
    
    class func setLocalPush(dateComponents : NSDateComponents){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let localNotification = UILocalNotification()
        let components: NSCalendarUnit = [.Year, .Month, .Day, .Hour, .Minute, .Second]
        let dateComps = NSCalendar.currentCalendar().components(components, fromDate: NSDate().dateByAddingTimeInterval(24*3600)) // tomorrow date components
        let selectedTime = dateComponents
        dateComps.hour = selectedTime.hour
        dateComps.minute = selectedTime.minute
        dateComps.second = 0
        
        let alertTime = NSCalendar.currentCalendar().dateFromComponents(dateComps)
        //        println("set local push == \(alertTime)")
        localNotification.fireDate = alertTime
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.repeatInterval = [.Day]
        localNotification.alertBody = "Your Horoscope has arrived"
        localNotification.soundName = "Glass.aiff"
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    class func setLocalPushForTesting(){
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let localNotification = UILocalNotification()
        //        println("set local push == \(alertTime)")
        let time = NSDate().timeIntervalSince1970 + 8
        localNotification.fireDate = NSDate(timeIntervalSince1970: time)
        localNotification.timeZone = NSTimeZone.defaultTimeZone()
        localNotification.repeatInterval = [.Day]
        localNotification.alertBody = "Test arrived"
        localNotification.soundName = "Glass.aiff"
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    // MARK: Tabbar Helpers
    
    class func getViewController(className : AnyClass) -> UIViewController? {
        if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
            let tabbarVC = XAppDelegate.window!.rootViewController! as? UITabBarController
            for nav in tabbarVC!.viewControllers! {
                let nav = nav as! UINavigationController
                if let vc = nav.viewControllers.first { // every tab in tabbar vc is a Navigation bar with vc as first element
                    if vc.isKindOfClass(className) {
                        return vc
                    }
                }
            }
        }
        return nil
    }
    
    class func popCurrentViewControllerToTop(){ // this will pop current viewcontroller to its top viewcontroller
        if(XAppDelegate.window!.rootViewController!.isKindOfClass(UITabBarController)){
            let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
            for nav in rootVC!.viewControllers! {
                let navController = nav as! UINavigationController
                navController.popToRootViewControllerAnimated(false)
            }
        }
    }
    
    class func updateNotificationBadge(){
        if (XAppDelegate.window!.rootViewController!.isKindOfClass(CustomTabBarController)){
            let tabbarViewController = XAppDelegate.window!.rootViewController! as! CustomTabBarController
            tabbarViewController.updateNotificationBadge()
        }
    }
    
    // extrack weblink information (the link and showing text) from a text
    // return array [weblink, text]
    // Dictionary<String,String>
    class func getTextWithWeblink(text: String, isTruncated: Bool) -> NSMutableAttributedString {
        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: .CaseInsensitive)
            let matches = regex.matchesInString(text, options: NSMatchingOptions.ReportProgress, range:NSMakeRange(0, text.utf16.count))
            var urls = [String]()
            for match in matches {
                let nsText = text as NSString
                let substring = nsText.substringWithRange(match.range)
                let types: NSTextCheckingType = .Link
                let detector = try NSDataDetector(types: types.rawValue)
                let matches = detector.matchesInString(substring, options: .ReportProgress, range: NSMakeRange(0, substring.utf16.count))
                for match in matches {
                    if let url = match.URL {
                        //NSUTF8StringEncoding
                        urls.append(url.absoluteString)
                    }
                }
                
            }
            
            var replacedText = regex.stringByReplacingMatchesInString(text,
                options: NSMatchingOptions.ReportCompletion,
                range:NSMakeRange(0, text.utf16.count) ,
                withTemplate: "")
            let readMorePhrase = "... Read more"
            // check if it's trucated by server
            if isTruncated {
                replacedText += readMorePhrase
            }
            
            let attString = NSMutableAttributedString(string: replacedText)
            let font = UIFont(name: "Book Antiqua", size: 14)
            let textColor = UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1)
            attString.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, replacedText.utf16.count))
            attString.addAttribute(NSForegroundColorAttributeName, value: textColor, range: NSMakeRange(0, replacedText.utf16.count))
            let nsReplacedText = replacedText as NSString
            let readMoreRange = nsReplacedText.rangeOfString("Read more")
            if isTruncated {
                attString.addAttribute(CCHLinkAttributeName, value: "readmore", range: readMoreRange)
            }
            
            
            let numberOfMatches = regex.numberOfMatchesInString(text, options: .ReportProgress, range: NSMakeRange(0, text.utf16.count))
            if numberOfMatches / 2 == urls.count {
                for index in 0..<numberOfMatches {
                    if index % 2 == 0 && index != numberOfMatches - 1 {
                        let nsText = text as NSString
                        let startTag = nsText.substringWithRange(matches[index].range)
                        let endTag = nsText.substringWithRange(matches[index + 1].range)
                        let link = text.componentsSeparatedByString(startTag).last?.componentsSeparatedByString(endTag).first
                        
                        if let link = link {
                            let nsLinkRange = nsReplacedText.rangeOfString(link)
                            attString.addAttribute(CCHLinkAttributeName, value: urls[index/2], range: nsLinkRange)
                        }
                    }
                }
            }
            return attString
        }
        catch {
            let attString = NSMutableAttributedString(string: "\(text)")
            return attString
        }
    }
    
    // Method to check if client should truncate the text
    // Base on current device size to check
    class func shouldBeTruncatedOnClient(text: String) -> Bool{
        let width = Utilities.getScreenSize().width - 16 // Margin = 8
        let font = UIFont(name: "Book Antiqua", size: 14)
        let checkTextView = CCHLinkTextView()
        checkTextView.font = font
        checkTextView.text = text
        
        let size = checkTextView.sizeThatFits(CGSizeMake(width, CGFloat.max))
        
        let lineHeight = font?.lineHeight
        let bottomInset = checkTextView.contentInset.bottom
        let topInset = checkTextView.contentInset.bottom
        let numberOfLine = ceil((size.height - topInset - bottomInset) / lineHeight!)
        
        
        if(DeviceType.IS_IPHONE_4_OR_LESS) {
            if numberOfLine > MAX_LINES_IP4 { return true }
        }
        
        if(DeviceType.IS_IPHONE_5) {
            if numberOfLine > MAX_LINES_IP5 { return true }
        }
        
        if(DeviceType.IS_IPHONE_6) {
            if numberOfLine > MAX_LINES_IP6 { return true }
        }
        
        if(DeviceType.IS_IPHONE_6P) {
            if numberOfLine > MAX_LINES_IP6P {
                return true
            }
        }
        
        return false
    }
    
    class func getTextViewMaxLines() -> Int{
        if (DeviceType.IS_IPHONE_4_OR_LESS){
             return Int(MAX_LINES_IP4)
        }
        if (DeviceType.IS_IPHONE_5) {
            return Int(MAX_LINES_IP5)
        }
        
        if (DeviceType.IS_IPHONE_6) {
            return Int(MAX_LINES_IP6)
        }
        
        if (DeviceType.IS_IPHONE_6P) {
            return Int(MAX_LINES_IP6P)
        }
        
        return Int(MAX_LINES_IP5)
    }
}


