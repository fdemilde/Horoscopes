//
//  Cache.swift
//  Horoscopes
//
//  Created by Binh Dang on 10/14/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class CacheManager {
    
//    dont know why cannot make key with these
//    let CACHE_RESPONSE_KEY = "CACHE_VALUE_KEY" as String
//    let EXPIRED_TIMESTAMP_KEY = "CACHE_EXPIRED_TIMESTAMP_KEY"
    class func cacheGet(url : String, postData : NSMutableDictionary?, loginRequired: LoginReq, expiredTime : NSTimeInterval, forceExpiredKey: String?, completionHandler: (result: NSDictionary?, error: NSError?) -> Void){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let key = Utilities.getKeyFromUrlAndPostData(url, postData: postData)
//                    print("cacheGet key == \(key)")
            let cacheDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(key)
            //        print("cacheGet cacheDict == \(cacheDict)")
            if var cacheDict = cacheDict{
                cacheDict = cacheDict as! Dictionary<String, NSObject>
                let cacheValue = cacheDict["CACHE_VALUE_KEY"] as! NSDictionary
                let cacheExpiredTime = cacheDict["CACHE_EXPIRED_TIMESTAMP_KEY"] as! String
                if(NSDate().timeIntervalSince1970 < Double(cacheExpiredTime)){ // valid
//                                    print("GOT CACHE !! RETURN")
                    completionHandler(result: cacheValue, error: nil) // return cache
                    return
                }
//                            print("GOT CACHE BUT EXPIRED")
                completionHandler(result: cacheValue, error: nil) // return expired cache but still call to server
            }
            Utilities.showHUD()
            XAppDelegate.mobilePlatform.sc.sendRequest(url, withLoginRequired: loginRequired, andPostData: postData) { (response, error) -> Void in
                if let error = error {
                    completionHandler(result: nil, error: error)
                } else {
                    //                print("SERVER DATA == \(response)")
                    if let forceExpiredKey = forceExpiredKey {
                        // use for supporting page, need to force next page expired if current page is expired
                        if(forceExpiredKey != "") { CacheManager.cacheExpire(forceExpiredKey) }
                        
                    }
                    
                    if let errorRes = response["error"]{
                        if(errorRes as! Int == 0){
                            CacheManager.cachePut(key, value:response, expiredTime: expiredTime)
                        }
                    }
                    completionHandler(result: response, error: error)
                }
                Utilities.hideHUD()
            }
        }
    }
    
    class func cachePut(key:String, value: NSObject, expiredTime : NSTimeInterval){
//        print("cachePut key == \(key)")
        var cacheDict = Dictionary<String, NSObject>()
        cacheDict["CACHE_VALUE_KEY"] = value
        cacheDict["CACHE_EXPIRED_TIMESTAMP_KEY"] = String(expiredTime)
        NSUserDefaults.standardUserDefaults().setValue(cacheDict, forKey: key)
    }
    
    class func cacheExpire(url : String, postData : NSMutableDictionary?){
        let key = Utilities.getKeyFromUrlAndPostData(url, postData: postData)
        let cacheDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(key)
        if var cacheDict = cacheDict{
            cacheDict = cacheDict as! Dictionary<String, String>
            let cacheValue = cacheDict["CACHE_VALUE_KEY"] as! String
            CacheManager.cachePut(key , value: cacheValue, expiredTime: 0)
        }
    }
    
    class func cacheExpire(key : String){
//        print("cacheExpire key == \(key)")
        let cacheDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(key)
        if var cacheDict = cacheDict{
//            print("cacheExpire cacheDict == \(cacheDict)")
            cacheDict = cacheDict as! Dictionary<String, NSObject>
            let cacheValue = cacheDict["CACHE_VALUE_KEY"] as! NSDictionary
            CacheManager.cachePut(key , value: cacheValue, expiredTime: 0)
        }
    }
    
    // MARK: Notification Cache
    // There is a special case for the Notification data. Notifications should be stored for a week after they are retrieved from the notification.getall endpoint. Keep a counter of the last checked time and submit it as the “since” parameter to request an incremental update of the latest notifications from the server. Add the new notifications to the notifications store.
    /* ------------------------- How it works --------------------------
     + Notification will be stored as a Dictionary<expiredTime, [NotificationObject]>
     + First, we check if there is any Notifications that haven't expired using Retrieve Time (notification will be expired after 7 days from retrieve time) and return to display, then remove all expired notifications and finally request new notifications from server using Since timestamp.
     + Update Notification data with new data from server and update Since timestamp
     ------------------------------------------------------------------ */
    
    class func cacheGetNotification(completionHandler: (result: [NotificationObject]?) -> Void){
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let NOTIFICATION_SINCE_KEY = "NOTIFICATION_SINCE_KEY"
    //        let NOTIFICATION_CACHE_KEY = "NOTIFICATION_CACHE_KEY"
            var lastSince = NSUserDefaults.standardUserDefaults().integerForKey(NOTIFICATION_SINCE_KEY)
            if lastSince == 0 { lastSince = 1 }
            var notificationDict = CacheManager.loadNotificationData()
            
            var resultArray = [NotificationObject]() // have cache
            let currentTime = Int(NSDate().timeIntervalSince1970)
            for (expiredTime, notifications) in notificationDict {
                let notificationArray = notifications as! [NotificationObject]
                let expiredTimeInt = Int(expiredTime)!
                if expiredTimeInt > currentTime { // hasn't expired
                    resultArray += notificationArray
                } else {
                    notificationDict[expiredTime] = nil
                }
                completionHandler(result: resultArray)
            }
            let newSince = Int(NSDate().timeIntervalSince1970)
//            print("get data since resultArray = \(lastSince)")
            XAppDelegate.mobilePlatform.platformNotiff.getAllwithSince(Int32(lastSince), andCompleteBlock: { (result) -> Void in
                var notifArray = result as! [NotificationObject]
                notifArray = CacheManager.checkAndRemoveDuplicatingNotification(notifArray, oldArray: resultArray)
                if(notifArray.count > 0){ // has new data
                    let newExpireTime = String(newSince + (7 * 3600 * 24))
                    notificationDict[newExpireTime] = notifArray
                    resultArray += notifArray
                    CacheManager.saveNotificationsData(notificationDict)
                    NSUserDefaults.standardUserDefaults().setValue(Int(newSince), forKey: NOTIFICATION_SINCE_KEY)
                    completionHandler(result: resultArray)
                } else {
                    completionHandler(result: resultArray)
                }
            })
        }
    }
    
    // MARK: Helper
    // prevent duplicating notification
    class func checkAndRemoveDuplicatingNotification(newArray : [NotificationObject], oldArray : [NotificationObject]) -> [NotificationObject]{
        var resultArray = newArray
        var index: Int
//        print("checkAndRemoveDuplicatingNotification newArray == \(newArray.count)")
        for (index = 0; index < newArray.count; index++) {
            for oldNotif in oldArray {
                // notif exists, remove from new Array
                if(oldNotif.notification_id == newArray[index].notification_id){
                    resultArray.removeAtIndex(index)
                }
            }
        }
        
        return resultArray
    }
    
    class func saveNotificationsData(cacheDict : Dictionary<String, AnyObject>){
        NSKeyedArchiver.archiveRootObject(cacheDict, toFile: NotificationObject.getFilePath())
    }
    
    class func loadNotificationData() -> Dictionary<String, AnyObject>{
        let cacheDict = NSKeyedUnarchiver.unarchiveObjectWithFile(NotificationObject.getFilePath()) as? Dictionary<String, AnyObject> ?? Dictionary<String, AnyObject>()
        return cacheDict
    }
}
