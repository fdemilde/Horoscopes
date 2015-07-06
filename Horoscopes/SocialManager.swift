//
//  SocialManager.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class SocialManager : NSObject {
    
//    var globalFeeds = []
    
    override init(){
        
    }
    
    // MARK: Network - Newsfeed
    
    func getUserNewsfeed(pageNo : Int, uid : String){
        var postData = NSMutableDictionary()
        var uidString = String(format:"%@",uid)
        var pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        postData.setObject(uid, forKey: "uid")

        XAppDelegate.mobilePlatform.sc.sendRequest(GET_USER_FEED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                println("Error when get getUserNewsfeed = \(error)")
            } else {
                println("getUserNewsfeed response = \(response)")
            }
            
        })
    }
    
    func getGlobalNewsfeed(pageNo : Int){
        var postData = NSMutableDictionary()
        var pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_GLOBAL_FEED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                println("Error when get getGlobalNewsfeed = \(error)")
            } else {
                println("getGlobalNewsfeed response = \(response)")
                var result = Utilities.parseNSDictionaryToDictionary(response)
                var errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                } else { // no error
                    var userDict = result["user"] as! Dictionary<String, AnyObject>
                    var postsArray = result["posts"] as! [AnyObject]
//                    println("userDict code = \(userDict)")
//                    println("postsArray code = \(postsArray)")
                    var feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: feedsArray)
                }
            }
            
        })
    }
    
    func getFollowingNewsfeed(String){
        
    }
}