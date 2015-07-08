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
        var keys = dict.allKeys
        for key in keys{
            var keyString = key as! String
            result[keyString] = dict.objectForKey(keyString)
        }
        return result
    }
    
    class func parseDictionaryToNSDictionary(dict : Dictionary<String, AnyObject>) -> NSDictionary{
        var result = NSMutableDictionary()
        var keys = dict.keys
        
        for key in keys{
            var keyString = key as String
            result.setObject(dict[keyString]!, forKey: keyString)
        }
        return result
    }
    
    class func parseArrayToNSArray(array : [AnyObject]) -> NSArray{
        var result = NSMutableArray()
        
        for var i = 0; i < array.count; i++ {
            result.addObject(array[i])
        }
        return result
    }
    
    // MARK: Screen size
    
    class func getScreenSize() -> CGSize{
        var screenRect = UIScreen.mainScreen().bounds
        var height = screenRect.height
        var width = screenRect.width
        return CGSizeMake(width, height)
    }
    
    class func getPositionBaseOn568hScreenSize(positionX : Float, positionY: Float) -> CGPoint{
        var screenSize = Utilities.getScreenSize()
        
        var percentageX = positionX / 320
        var percentageY = positionY / 568
        
        var result =  CGPointMake(screenSize.width * CGFloat(percentageX), screenSize.height * CGFloat(percentageY))
        
        return result
    }
    
    class func getRatio() -> CGFloat {
        var screenSize = Utilities.getScreenSize()
        var customScreenSize = screenSize.height - 211
        
        var ratio = Float(customScreenSize/(800-211))
        return CGFloat(ratio)
    }
    
    // MARK: HUD
    class func showHUD(){
        
        dispatch_async(dispatch_get_main_queue(),{
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let viewController = appDelegate.window!.rootViewController
            
            let loadingNotification = MBProgressHUD.showHUDAddedTo(viewController!.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Loading"
            
        })
    }
    
    class func hideHUD(){
        dispatch_async(dispatch_get_main_queue(),{
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let viewController = appDelegate.window!.rootViewController
            MBProgressHUD.hideAllHUDsForView(viewController!.view, animated: true)
        })
    }
    
    // MARK: Newsfeed, User profile and user post parsing helpers
    
    class func parseFeedsArray(userDataDict : Dictionary<String, AnyObject>, postsDataArray : [AnyObject]) -> [UserPost]{
        var resultArray = [UserPost]()
        var userDict = Dictionary<String, UserProfile>()
        var user = UserProfile()
        for (uid, userData) in userDataDict {
            var userObject = UserProfile(data: userData as! NSDictionary)
            userDict[uid] = userObject
        }
        
        for postData in postsDataArray{
            var postObject = UserPost(data: postData as! NSDictionary)
            var uid = postObject.uid
            var uidString = String(format: "%d", uid)
            if let userObj = userDict[uidString] {
                postObject.user = userObj
            }
            resultArray.append(postObject)
        }
        
        println("parseFeedsArray userDict === \(resultArray)")
        
        return resultArray
    }
    
    class func getNewsfeedTypeByString(typeString : String) -> NewsfeedType{
        if(typeString == "onyourmind") {return NewsfeedType.OnYourMind}
        if(typeString == "story") {return NewsfeedType.Story}
        if(typeString == "feeling") {return NewsfeedType.Feeling}
        return NewsfeedType.OnYourMind
    }
    
    // MARK: AlertView
    class func showAlertView(delegate: UIAlertViewDelegate, title:String, message:String){
        dispatch_async(dispatch_get_main_queue(),{
            var alertView: UIAlertView = UIAlertView()
            
            alertView.delegate = delegate
            alertView.title = title
            alertView.message = message
            alertView.addButtonWithTitle("OK")
            alertView.show()
        })
    }
    
    // MARK: Helpers
    
    class func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    class func loadNIB(file:String) -> AnyObject{
        var arr = NSBundle.mainBundle().loadNibNamed(file, owner: nil, options: nil)
        
        var ret: AnyObject = arr[0];
        return ret;
    }
    
    class func getSignDateString(startDate : NSDate, endDate:NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        return String(format: "%@ - %@", dateFormatter.stringFromDate(startDate),dateFormatter.stringFromDate(endDate))
    }
    
    class func getDateStringFromTimestamp(ts : NSTimeInterval, dateFormat : String) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        var date = NSDate(timeIntervalSince1970:ts)
        var dateString = String(format: "%@", dateFormatter.stringFromDate(date))
        return dateString
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
        var horo = XAppDelegate.horoscopesManager.horoscopesSigns[index] as Horoscope
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
        default:
            return ""
        }
    }
    
    // MARK: Notification support
    class func postNotification(name: String, object:AnyObject?){
        dispatch_async(dispatch_get_main_queue(),{
            NSNotificationCenter.defaultCenter().postNotificationName(name, object: object)
        })
    }
}


