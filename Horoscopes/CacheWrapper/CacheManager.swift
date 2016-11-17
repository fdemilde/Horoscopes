//
//  Cache.swift
//  Horoscopes
//
//  Created by Binh Dang on 10/14/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

class CacheManager {
    
static let NOTIFICATION_SINCE_KEY = "NOTIFICATION_SINCE_KEY"
static let GET_DATA_KEY = "GET_DATA_KEY"
    
    class func cacheGet(_ url : String, postData : NSMutableDictionary?, loginRequired: LoginReq, expiredTime : TimeInterval, forceExpiredKey: String?, ignoreCache : Bool = false, completionHandler: @escaping (_ result: NSDictionary?, _ error: NSError?) -> Void){
        DispatchQueue.main.async { () -> Void in
            var cacheValue = NSDictionary()
            var key = ""
            if(url == GET_DATA_METHOD || url == REFRESH_DATA_METHOD){
                key = GET_DATA_KEY
            } else {
                key = Utilities.getKeyFromUrlAndPostData(url, postData: postData)
            }
            let cacheDict = UserDefaults.standard.dictionary(forKey: key)
            if(!ignoreCache){
                if var cacheDict = cacheDict{
                    cacheDict = cacheDict as! Dictionary<String, NSObject>
                    cacheValue = cacheDict["CACHE_VALUE_KEY"] as! NSDictionary
                    let cacheExpiredTime = cacheDict["CACHE_EXPIRED_TIMESTAMP_KEY"] as! String
                    if(Date().timeIntervalSince1970 < Double(cacheExpiredTime)){ // valid
                        completionHandler(cacheValue, nil) // return cache
                        return
                    }
                    completionHandler(cacheValue, nil) // return expired cache but still call to server
                }
            } else {
                if(url == GET_DATA_METHOD || url == REFRESH_DATA_METHOD) {
                    if var cacheDict = cacheDict{
                        cacheDict = cacheDict as! Dictionary<String, NSObject>
                        cacheValue = cacheDict["CACHE_VALUE_KEY"] as! NSDictionary
                    }
                }
            }
            XAppDelegate.mobilePlatform.sc.sendRequest(url, withLoginRequired: loginRequired, andPostData: postData) { (response, error) -> Void in
                if let error = error {
                    // error when retrieve from server, we get the last cache value to show, only apply to get data method since don't have enough time to test on the other
                    if((url == GET_DATA_METHOD || url == REFRESH_DATA_METHOD) && error.code == 8008135){
                        if(cacheValue.count != 0){
                            completionHandler(result: cacheValue, error: nil)
                            return
                        }
                    }
                    completionHandler(result: nil, error: error)
                } else {
                    if let forceExpiredKey = forceExpiredKey {
                        // use for supporting page, need to force next page expired if current page is expired
                        if(forceExpiredKey != "") { CacheManager.cacheExpire(forceExpiredKey) }
                        
                    }
                    if let response = response {
                        if let errorRes = response["error"]{
                            if(errorRes as? Int == 0){
                                CacheManager.cachePut(key, value:response, expiredTime: expiredTime)
                            } else {
                                print("error code is != 0")
                                if let errorCode = response["error_code"]{
                                    if(errorCode as? String == "error.invalidtoken"){
                                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                                    }
                                }
                            }
                        }
                    }
                    completionHandler(result: response, error: error)
                }
            }
        }
    }
    
    class func cachePut(_ key:String, value: NSObject, expiredTime : TimeInterval){
//        print("cachePut key == \(key)")
        var cacheDict = Dictionary<String, NSObject>()
        cacheDict["CACHE_VALUE_KEY"] = value
        cacheDict["CACHE_EXPIRED_TIMESTAMP_KEY"] = String(expiredTime) as NSObject?
        UserDefaults.standard.setValue(cacheDict, forKey: key)
    }
    
    class func cacheExpire(_ url : String, postData : NSMutableDictionary?){
        let key = Utilities.getKeyFromUrlAndPostData(url, postData: postData)
        let cacheDict = UserDefaults.standard.dictionary(forKey: key)
        if var cacheDict = cacheDict{
            cacheDict = cacheDict as! Dictionary<String, String>
            let cacheValue = cacheDict["CACHE_VALUE_KEY"] as! String
            CacheManager.cachePut(key , value: cacheValue, expiredTime: 0)
        }
    }
    
    class func cacheExpire(_ key : String){
//        print("cacheExpire key == \(key)")
        let cacheDict = UserDefaults.standard.dictionary(forKey: key)
        if var cacheDict = cacheDict{
//            print("cacheExpire cacheDict == \(cacheDict)")
            cacheDict = cacheDict as! Dictionary<String, NSObject>
            let cacheValue = cacheDict["CACHE_VALUE_KEY"] as! NSDictionary
            CacheManager.cachePut(key , value: cacheValue, expiredTime: 0)
        }
    }
    
    // check if cache is expired or not
    class func isCacheExpired(_ url : String, postData: NSMutableDictionary?) -> Bool{
        
        let key = Utilities.getKeyFromUrlAndPostData(url, postData: postData)
        //            print("cacheGet key == \(key)")
        let cacheDict = UserDefaults.standard.dictionary(forKey: key)
        if var cacheDict = cacheDict{
            cacheDict = cacheDict as! Dictionary<String, NSObject>
            let cacheExpiredTime = cacheDict["CACHE_EXPIRED_TIMESTAMP_KEY"] as! String
            if(Date().timeIntervalSince1970 < Double(cacheExpiredTime)){ // valid
                return false
            } else {
                return true
            }
        }
        return true
    }
    
    // MARK: Notification Cache
    // There is a special case for the Notification data. Notifications should be stored for a week after they are retrieved from the notification.getall endpoint. Keep a counter of the last checked time and submit it as the “since” parameter to request an incremental update of the latest notifications from the server. Add the new notifications to the notifications store.
    /* ------------------------- How it works --------------------------
     + Notification will be stored as a Dictionary<expiredTime, [NotificationObject]>
     + First, we check if there is any Notifications that haven't expired using Retrieve Time (notification will be expired after 7 days from retrieve time) and return to display, then remove all expired notifications and finally request new notifications from server using Since timestamp.
     + Update Notification data with new data from server and update Since timestamp
     ------------------------------------------------------------------ */
    
    class func cacheGetNotification(_ completionHandler: @escaping (_ result: [NotificationObject]?) -> Void){
        DispatchQueue.main.async { () -> Void in
            var lastSince = UserDefaults.standard.integer(forKey: NOTIFICATION_SINCE_KEY)
            if lastSince == 0 { lastSince = 1 }
            var notificationDict = CacheManager.loadNotificationData()
            
            var resultArray = [NotificationObject]() // have cache
            let currentTime = Int(Date().timeIntervalSince1970)
            for (expiredTime, notifications) in notificationDict {
                let notificationArray = notifications as! [NotificationObject]
                let expiredTimeInt = Int(expiredTime)!
                if expiredTimeInt > currentTime { // hasn't expired
                    resultArray += notificationArray
                } else {
                    notificationDict[expiredTime] = nil
                }
            }
            
            resultArray.sort(by: { $0.created > $1.created })
            completionHandler(resultArray)
            
            let newSince = Int(Date().timeIntervalSince1970)
            XAppDelegate.mobilePlatform.platformNotiff.getAllwithSince(Int32(lastSince), andComplete: { (result) -> Void in
                if let result = result {
                    let notifArray = result as! [NotificationObject]
                    CacheManager.addNotificationIdToReadList(notifArray)
                    UserDefaults.standard.setValue(Int(newSince), forKey: NOTIFICATION_SINCE_KEY)
                    let checkArray = CacheManager.checkAndRemoveDuplicatingNotification(notifArray, oldArray: resultArray)
                    if(checkArray.count > 0){ // has new data
                        let newExpireTime = String(newSince + (7 * 3600 * 24))
                        notificationDict[newExpireTime] = checkArray
                        resultArray += checkArray
                        CacheManager.saveNotificationsData(notificationDict)
                        resultArray.sort(by: { $0.created > $1.created })
                        completionHandler(result: resultArray)
                    }
                }
            })
        }
    }
    
    // MARK: Helper
    // prevent duplicating notification
    class func checkAndRemoveDuplicatingNotification(_ newArray : [NotificationObject], oldArray : [NotificationObject]) -> [NotificationObject]{
        var needRemoveArray = [NotificationObject]()
        var result = newArray
        for newNotif in result {
            for oldNotif in oldArray {
                // notif exists, remove from new Array
                if(oldNotif.notification_id == newNotif.notification_id){
                    needRemoveArray.append(newNotif)
                }
            }
        }
        
        for notif in needRemoveArray {
            result.remove(notif)
        }
        return result
    }
    
    class func addNotificationIdToReadList(_ notifArray : [NotificationObject]){
        var notificationIds = Set<String>()
        if let notifData = UserDefaults.standard.data(forKey: notificationKey) {
            notificationIds = NSKeyedUnarchiver.unarchiveObject(with: notifData) as! Set<String>
        }
        // check if notification from server cleared or not, if they're cleared, add to cleared list
        for notif in notifArray {
            if (notif.cleared == true) {
                if (!notificationIds.contains(notif.notification_id)) {
                    notificationIds.insert(notif.notification_id)
                }
            }
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: notificationIds)
        UserDefaults.standard.set(data, forKey: notificationKey)
    }
    
    class func saveNotificationsData(_ cacheDict : Dictionary<String, AnyObject>){
        NSKeyedArchiver.archiveRootObject(cacheDict, toFile: NotificationObject.getFilePath())
    }
    
    class func loadNotificationData() -> Dictionary<String, AnyObject>{
        let cacheDict = NSKeyedUnarchiver.unarchiveObject(withFile: NotificationObject.getFilePath()) as? Dictionary<String, AnyObject> ?? Dictionary<String, AnyObject>()
        return cacheDict
    }
    
    class func clearAllNotificationData() {
        UserDefaults.standard.setValue(Int(1), forKey: NOTIFICATION_SINCE_KEY)
        let data = NSKeyedArchiver.archivedData(withRootObject: Set<String>())
        UserDefaults.standard.set(data, forKey: notificationKey)
        NSKeyedArchiver.archiveRootObject(Dictionary<String, AnyObject>(), toFile: NotificationObject.getFilePath())
        XAppDelegate.lastGetAllNotificationsTs = 0
    }
    
    class func resetNotificationSinceTs() {
        UserDefaults.standard.setValue(Int(1), forKey: NOTIFICATION_SINCE_KEY)
    }
}
