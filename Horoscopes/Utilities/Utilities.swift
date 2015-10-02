//
//  Utilities.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class Utilities {
    
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
                let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
                let viewController = appDelegate.window!.rootViewController
                
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
            let uid = postObject.uid
            let uidString = String(format: "%d", uid)
            if let userObj = userDict[uidString] {
                postObject.user = userObj
            }
            resultArray.append(postObject)
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
        if(typeString == "story") {return NewsfeedType.Story}
        if(typeString == "feeling") {return NewsfeedType.Feeling}
        return NewsfeedType.OnYourMind
    }
    
    // MARK: Birthday Format helpers
    class func getBirthdayString(date : NSDate) -> String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        let dayOfMonthFormatter = NSDateFormatter()
        dayOfMonthFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dayOfMonthFormatter.dateFormat = "d"
        var dateString = dateFormatter.stringFromDate(date)
        let dayOfMonthFormatterString = dayOfMonthFormatter.stringFromDate(date)
        
        let date_day = Int(dayOfMonthFormatterString)
        let suffix_string = "|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st"
        var suffixes = suffix_string.componentsSeparatedByString("|")
        let suffix = suffixes[date_day!]
        dateString = dateString.stringByAppendingString(suffix)
        
        return dateString
    }
    
    class func getDefaultBirthday() -> NSDate{ // return default birthday for first load
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString("25/11")!
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
                    if let error = error {
                        alert.message = "\(message) \(error)"
                    }
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alert.addAction(action)
                    viewController.presentViewController(alert, animated: true, completion: nil)
                }
            } else {
                Utilities.showAlertView(nil, title: title, message: message)
            }
        })
    }
    
    // MARK: - Convenience
    
    class func showError(viewController: UIViewController, error: NSError) {
        self.showAlert(viewController, title: "Network Error", message: "There is an error. Action cannot be completed. Please try again later!", error: error)
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
    
    class func getSignDateString(startDate : NSDate, endDate:NSDate) -> String{
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
    
    class func getDateFromDateString(dateString : String, format : String) -> NSDate {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        return dateFormatter.dateFromString(dateString)!
    }
    
    class func getTimestampFromDateString(dateString: String, dateFormat: String) -> NSTimeInterval {
        return getDateFromDateString(dateString, format: dateFormat).timeIntervalSince1970
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
    
    
    class func getFeedTypeImageName(userPost : UserPost) -> String{
        switch(userPost.type){
        case NewsfeedType.OnYourMind:
            return "post_type_mind"
        case NewsfeedType.Feeling:
            return "post_type_feel"
        case NewsfeedType.Story:
            return "post_type_story"
        }
    }
    
    class func getTimeAgoString(ts : Int) -> String {
        let timeAgoDate = NSDate(timeIntervalSince1970: NSTimeInterval(ts))
        let facebookTimeAgoString = timeAgoDate.formattedAsTimeAgo()
        return facebookTimeAgoString
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
    
    class func shareViewControllerForType(viewType: ShareViewType, shareType: ShareType, timeTag: NSTimeInterval = 0, horoscopeSignName : String = "", sharingText: String, pictureURL : String = "") -> ShareViewController {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let shareViewController = storyBoard.instantiateViewControllerWithIdentifier("ShareViewController") as! ShareViewController
        shareViewController.populateShareData(viewType, shareType: shareType, timeTag: timeTag, horoscopeSignName: horoscopeSignName, sharingText: sharingText, pictureURL: pictureURL)
        return shareViewController
    }
    
}


