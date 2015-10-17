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
}
