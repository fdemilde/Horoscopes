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
    class func layerForCircle(_ centerPoint: CGPoint, radius: CGFloat, lineWidth: CGFloat) -> CAShapeLayer {
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.lineWidth = lineWidth
        return layer
    }
    
    // MARK: Parsing helpers
    class func parseNSDictionaryToDictionary(_ dict : NSDictionary) -> Dictionary<String, AnyObject>{
        var result = Dictionary<String, AnyObject>()
        let keys = dict.allKeys
        for key in keys{
            let keyString = key as! String
            result[keyString] = dict.object(forKey: keyString) as AnyObject?
        }
        return result
    }
    
    class func parseDictionaryToNSDictionary(_ dict : Dictionary<String, AnyObject>) -> NSDictionary{
        let result = NSMutableDictionary()
        let keys = dict.keys
        
        for key in keys{
            let keyString = key as String
            result.setObject(dict[keyString]!, forKey: keyString as NSCopying)
        }
        return result
    }
    
    class func parseArrayToNSArray(_ array : [AnyObject]) -> NSArray{
        let result = NSMutableArray()
        
        for i in 0 ..< array.count {
            result.add(array[i])
        }
        return result
    }
    
    // MARK: Screen size
    
    class func getScreenSize() -> CGSize{
        let screenRect = UIScreen.main.bounds
        let height = screenRect.height
        let width = screenRect.width
        return CGSize(width: width, height: height)
    }
    
    class func getPositionBaseOn568hScreenSize(_ positionX : Float, positionY: Float) -> CGPoint{
        let screenSize = Utilities.getScreenSize()
        
        let percentageX = positionX / 320
        let percentageY = positionY / 568
        
        let result =  CGPoint(x: screenSize.width * CGFloat(percentageX), y: screenSize.height * CGFloat(percentageY))
        
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
    class func getImageToSupportSize(_ name : String,size : CGSize, frame : CGRect) -> UIImage{
        UIGraphicsBeginImageContext(size)
        UIImage(named: name)!.draw(in: frame)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // MARK: HUD
    class func showHUD(_ viewToShow : UIView? = nil){
        
        DispatchQueue.main.async(execute: {
            var loadingNotification : MBProgressHUD!
            if let viewToShow = viewToShow {
                loadingNotification = MBProgressHUD.showAdded(to: viewToShow, animated: true)
            } else {
                let viewController = XAppDelegate.window!.rootViewController
                loadingNotification = MBProgressHUD.showAdded(to: viewController!.view, animated: true)
            }
            loadingNotification.mode = MBProgressHUDMode.indeterminate
            
        })
    }
    
    class func hideHUD(_ viewToHide : UIView? = nil){
        DispatchQueue.main.async(execute: {
            if let viewToHide = viewToHide {
                MBProgressHUD.hideAllHUDs(for: viewToHide, animated: true)
            } else {
                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                let viewController = appDelegate.window!.rootViewController
                MBProgressHUD.hideAllHUDs(for: viewController!.view, animated: true)
            }
        })
    }
    
    // MARK: Newsfeed, User profile and user post parsing helpers
    
    class func parseFeedsArray(_ userDataDict : Dictionary<String, AnyObject>, postsDataArray : [AnyObject]) -> [UserPost]{
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
    
    class func parseUsersArray(_ userDataDict : Dictionary<String, AnyObject>) -> Dictionary<String, UserProfile>{ // return Dict<uid,UserProfile>
        var userDict = Dictionary<String, UserProfile>()
        for (uid, userData) in userDataDict {
            let userObject = UserProfile(data: userData as! NSDictionary)
            userDict[uid] = userObject
        }
        return userDict
    }
    
    class func getNewsfeedTypeByString(_ typeString : String) -> NewsfeedType{
        if(typeString == "onyourmind") {return NewsfeedType.onYourMind}
        if(typeString == "shareadvice") {return NewsfeedType.shareAdvice}
        if(typeString == "howhoroscope") {return NewsfeedType.howHoroscope}
        if(typeString == "fortune") {return NewsfeedType.fortune}
        return NewsfeedType.invalid
    }
    
    class func getDefaultBirthday() -> StandardDate{ // return default birthday for first load
        return StandardDate(day: 22, month: 11)
    }
    
    class func getMonthAsNumberFromMonthName(_ monthName : String) -> Int{
        let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        if let monthIdex = monthArray.index(of: monthName){
            return monthIdex + 1;
        }
        return 12;
    }
    
    // MARK: Alert
    class func showAlertView(_ delegate: UIAlertViewDelegate?, title:String, message:String, tag : Int? = -1){
        DispatchQueue.main.async(execute: {
            let alertView: UIAlertView = UIAlertView()
            
            alertView.delegate = delegate
            alertView.title = title
            alertView.message = message
            alertView.addButton(withTitle: "OK")
            alertView.tag = tag!
            alertView.show()
        })
    }
    
    class func showAlert(_ viewController: UIViewController, title: String, message: String = "", error: NSError?) {
        DispatchQueue.main.async(execute: { () -> Void in
            if #available(iOS 8.0, *) {
                if viewController.presentedViewController == nil {
                    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//                    if let error = error {
//                        alert.message = "\(message) \(error)"
//                    }
                    let action = UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(action)
                    viewController.present(alert, animated: true, completion: nil)
                }
            } else {
                Utilities.showAlertView(nil, title: title, message: message)
            }
        })
    }
    
    // MARK: - Convenience
    
    class func showError(_ error: NSError, viewController : UIViewController? = nil) {
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
    
    class func getImageFromUrlString(_ imgUrl: String, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        if let url = URL(string: imgUrl) {
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
                if let data = data {
                    completionHandler(UIImage(data: data))
                } else {
                    completionHandler(UIImage())
                }
                
                
            }).resume()
        }
    }
    
    class func getDataFromUrl(_ urL:URL, completion: @escaping ((_ data: Data?) -> Void)) {
        URLSession.shared.dataTask(with: urL, completionHandler: { (data, response, error) in
            completion(data)
            }) .resume()
    }
    
    class func loadNIB(_ file:String) -> AnyObject{
        var arr = Bundle.main.loadNibNamed(file, owner: nil, options: nil)
        
        let ret: AnyObject = arr[0];
        return ret;
    }
    
    class func getLabelSizeWithString(_ text : String, font: UIFont) -> CGSize {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.size
    }
    
    class func getParentUIViewController(_ view : UIView) -> UIResponder{
        var responder = view as UIResponder
        while(responder.isKind(of: UIView.classForCoder())){
            responder = responder.next!
        }
        return responder
        
    }
    
    class func getHoroscopeNameWithIndex(_ index: Int) -> String{
        let horo = XAppDelegate.horoscopesManager.horoscopesSigns[index] as Horoscope
        return horo.sign
    }
    
    
    class func getFeedTypeImageName(_ type : NewsfeedType) -> String{
        switch(type){
        case NewsfeedType.onYourMind:
            return "post_type_mind"
        case NewsfeedType.howHoroscope:
            return "post_type_horoscope"
        case NewsfeedType.shareAdvice:
            return "post_type_advice"
        case NewsfeedType.fortune:
            return "post_type_fortune"
        case NewsfeedType.invalid:
            return ""
        }
    }
    
    // Corner Radius manipulation 
    class func makeCornerRadius(_ view : UIView, maskFrame : CGRect, roundOptions : UIRectCorner, radius : CGFloat) -> UIView {
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: roundOptions, cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = maskFrame
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
        return view
    }
    
    // MARK: Time format
    class func getTimeAgoString(_ ts : Int) -> String {
        let timeAgoDate = Date(timeIntervalSince1970: TimeInterval(ts))
        return (timeAgoDate as NSDate).timeAgoSinceNow()
    }
    
    class func getSignDateString(_ startDate : StandardDate, endDate:StandardDate) -> String{
        return String(format: "%@ - %@", startDate.toString("MMM dd"),endDate.toString("MMM dd"))
    }
    
    class func getDateStringFromTimestamp(_ ts : TimeInterval, dateFormat : String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let date = Date(timeIntervalSince1970:ts)
        let dateString = String(format: "%@", dateFormatter.string(from: date))
        return dateString
    }
    
    class func getDateFromDateString(_ dateString : String, format : String, useLocalTimezone : Bool? = false) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)!
    }
    
    // MARK: Notification support
    class func postNotification(_ name: String, object:AnyObject?){
        DispatchQueue.main.async(execute: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object)
        })
    }
    
    // MARK: - Share helper
    
    class func presentShareFormSheetController(_ hostViewController: UIViewController, shareViewController: ShareViewController) {
        let formSheet = MZFormSheetController(viewController: shareViewController)
        formSheet.shouldDismissOnBackgroundViewTap = true
        formSheet.transitionStyle = MZFormSheetTransitionStyle.slideFromBottom
        formSheet.cornerRadius = 5.0
        formSheet.portraitTopInset = (Utilities.getScreenSize().height - SHARE_HYBRID_HEIGHT) / 2
        formSheet.presentedFormSheetSize = CGSize(width: Utilities.getScreenSize().width - 20, height: SHARE_HYBRID_HEIGHT)
        hostViewController.mz_present(formSheet, animated: true, completionHandler: nil)
    }
    
    class func getShareViewController() -> ShareViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareViewController = storyBoard.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        return shareViewController
    }
    
    // MARK: Cache helpers
    class func getKeyFromUrlAndPostData(_ url : String, postData : NSMutableDictionary?) -> String {
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
            if let notificationSettings = UIApplication.shared.currentUserNotificationSettings {
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
            let enabledNotificationTypes = UIApplication.shared.enabledRemoteNotificationTypes()
            if(enabledNotificationTypes.isEmpty){
                return false
            } else {
                return true
            }
        }
    }
    
    class func registerForRemoteNotification(){
        if #available(iOS 8.0, *) {
            let types : UIUserNotificationType = [.sound, .badge, .alert]
            let notifSettings = UIUserNotificationSettings(types: types, categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notifSettings)
        } else {
            // Fallback on earlier versions
            let types : UIRemoteNotificationType = [.sound, .badge, .alert]
            UIApplication.shared.registerForRemoteNotifications(matching: types)
        }
    }
    
    class func isFirstTimeUsing() -> Bool {
        if(XAppDelegate.userSettings.horoscopeSign == -1){
            return true
        } else { return false }
        
    }
    
    
    class func setLocalPush(_ dateComponents : DateComponents){
        UIApplication.shared.cancelAllLocalNotifications()
        let localNotification = UILocalNotification()
        let components: NSCalendar.Unit = [.year, .month, .day, .hour, .minute, .second]
        var dateComps = (Calendar.current as NSCalendar).components(components, from: Date().addingTimeInterval(24*3600)) // tomorrow date components
        let selectedTime = dateComponents
        dateComps.hour = selectedTime.hour
        dateComps.minute = selectedTime.minute
        dateComps.second = 0
        
        let alertTime = Calendar.current.date(from: dateComps)
        //        println("set local push == \(alertTime)")
        localNotification.fireDate = alertTime
        localNotification.timeZone = TimeZone.current
        localNotification.repeatInterval = [.day]
        localNotification.alertBody = "Your Horoscope has arrived"
        localNotification.soundName = "Glass.aiff"
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    class func setLocalPushForTesting(){
        UIApplication.shared.cancelAllLocalNotifications()
        let localNotification = UILocalNotification()
        //        println("set local push == \(alertTime)")
        let time = Date().timeIntervalSince1970 + 8
        localNotification.fireDate = Date(timeIntervalSince1970: time)
        localNotification.timeZone = TimeZone.current
        localNotification.repeatInterval = [.day]
        localNotification.alertBody = "Test arrived"
        localNotification.soundName = "Glass.aiff"
        localNotification.applicationIconBadgeNumber = 1
        UIApplication.shared.scheduleLocalNotification(localNotification)
    }
    
    // MARK: Tabbar Helpers
    
    class func getViewController(_ className : AnyClass) -> UIViewController? {
        if(XAppDelegate.window!.rootViewController!.isKind(of: UITabBarController.self)){
            let tabbarVC = XAppDelegate.window!.rootViewController! as? UITabBarController
            for nav in tabbarVC!.viewControllers! {
                let nav = nav as! UINavigationController
                if let vc = nav.viewControllers.first { // every tab in tabbar vc is a Navigation bar with vc as first element
                    if vc.isKind(of: className) {
                        return vc
                    }
                }
            }
        }
        return nil
    }
    
    class func popCurrentViewControllerToTop(){ // this will pop current viewcontroller to its top viewcontroller
        if(XAppDelegate.window!.rootViewController!.isKind(of: UITabBarController.self)){
            let rootVC = XAppDelegate.window!.rootViewController! as? UITabBarController
            for nav in rootVC!.viewControllers! {
                let navController = nav as! UINavigationController
                navController.popToRootViewController(animated: false)
            }
        }
    }
    
    class func updateNotificationBadge(){
        if (XAppDelegate.window!.rootViewController!.isKind(of: CustomTabBarController.self)){
            let tabbarViewController = XAppDelegate.window!.rootViewController! as! CustomTabBarController
            tabbarViewController.updateNotificationBadge()
        }
    }
    
    // extrack weblink information (the link and showing text) from a text
    // return array [weblink, text]
    // Dictionary<String,String>
    class func getTextWithWeblink(_ text: String, isTruncated: Bool) -> NSMutableAttributedString {
        do {
            let regex = try NSRegularExpression(pattern: "<[^>]+>", options: .caseInsensitive)
            let matches = regex.matches(in: text, options: NSRegularExpression.MatchingOptions.reportProgress, range:NSMakeRange(0, text.utf16.count))
            var urls = [String]()
            for match in matches {
                let nsText = text as NSString
                let substring = nsText.substring(with: match.range)
                let types: NSTextCheckingResult.CheckingType = .link
                let detector = try NSDataDetector(types: types.rawValue)
                let matches = detector.matches(in: substring, options: .reportProgress, range: NSMakeRange(0, substring.utf16.count))
                for match in matches {
                    if let url = match.url {
                        //NSUTF8StringEncoding
                        urls.append(url.absoluteString)
                    }
                }
                
            }
            
            var replacedText = regex.stringByReplacingMatches(in: text,
                options: NSRegularExpression.MatchingOptions.reportCompletion,
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
            let readMoreRange = nsReplacedText.range(of: "Read more")
            if isTruncated {
                attString.addAttribute(CCHLinkAttributeName, value: "readmore", range: readMoreRange)
            }
            
            
            let numberOfMatches = regex.numberOfMatches(in: text, options: .reportProgress, range: NSMakeRange(0, text.utf16.count))
            if numberOfMatches / 2 == urls.count {
                for index in 0..<numberOfMatches {
                    if index % 2 == 0 && index != numberOfMatches - 1 {
                        let nsText = text as NSString
                        let startTag = nsText.substring(with: matches[index].range)
                        let endTag = nsText.substring(with: matches[index + 1].range)
                        let link = text.components(separatedBy: startTag).last?.components(separatedBy: endTag).first
                        
                        if let link = link {
                            let nsLinkRange = nsReplacedText.range(of: link)
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
    class func shouldBeTruncatedOnClient(_ text: String) -> Bool{
        let width = Utilities.getScreenSize().width - 16 // Margin = 8
        let font = UIFont(name: "Book Antiqua", size: 14)
        let checkTextView = CCHLinkTextView()
        checkTextView.font = font
        checkTextView.text = text
        
        let size = checkTextView.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        
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


