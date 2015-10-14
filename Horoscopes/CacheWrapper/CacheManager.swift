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
    
    class func cacheGet(url : String, postData : NSMutableDictionary?, loginRequired: LoginReq, expiredTime : NSTimeInterval, completionHandler: (result: NSDictionary?, error: NSError?) -> Void){
        let key = CacheManager.getKeyFromUrlAndPostData(url, postData: postData)
//        print("cacheGet key == \(key)")
        let cacheDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(key)
//        print("cacheGet cacheDict == \(cacheDict)")
        if var cacheDict = cacheDict{
            cacheDict = cacheDict as! Dictionary<String, NSObject>
            let cacheValue = cacheDict["CACHE_VALUE_KEY"] as! NSDictionary
            let cacheExpiredTime = cacheDict["CACHE_EXPIRED_TIMESTAMP_KEY"] as! String
            if(NSDate().timeIntervalSince1970 < Double(cacheExpiredTime)){ // valid
//                print("GOT CACHE !! RETURN")
                completionHandler(result: cacheValue, error: nil) // return cache
                return
            }
//            print("GOT CACHE BUT EXPIRED")
            completionHandler(result: cacheValue, error: nil) // return expired cache but still call to server
        }
        XAppDelegate.mobilePlatform.sc.sendRequest(url, withLoginRequired: loginRequired, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                //                print("SERVER DATA == \(response)")
                CacheManager.cachePut(key, value:response, expiredTime: expiredTime)
                completionHandler(result: response, error: error)
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
        let key = CacheManager.getKeyFromUrlAndPostData(url, postData: postData)
        let cacheDict = NSUserDefaults.standardUserDefaults().dictionaryForKey(key)
        if var cacheDict = cacheDict{
            cacheDict = cacheDict as! Dictionary<String, String>
            let cacheValue = cacheDict["CACHE_VALUE_KEY"] as! String
            CacheManager.cachePut(key , value: cacheValue, expiredTime: 0)
        }
    }
    
    class func getKeyFromUrlAndPostData(url : String, postData : NSMutableDictionary?) -> String {
        var key = url
        if let postData = postData{
            for (postKey, value) in postData {
                key += "|\(postKey)|\(value)"
            }
        }
        return key
    }
}
