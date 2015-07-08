//
//  SocialManager.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class SocialManager : NSObject, UIAlertViewDelegate {
    
//    var globalFeeds = []
    
    override init(){
        
    }
    
    // MARK: Network - Newsfeed
    
    func getUserNewsfeed(pageNo : Int, uid : Int){
        var postData = NSMutableDictionary()
        var uidString = String(format:"%d",uid)
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
        Utilities.showHUD()
        var postData = NSMutableDictionary()
        var pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_GLOBAL_FEED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                println("Error when get getGlobalNewsfeed = \(error)")
                NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
            } else {
                println("getGlobalNewsfeed response = \(response)")
                var result = Utilities.parseNSDictionaryToDictionary(response)
                var errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
                } else { // no error
                    var userDict = result["user"] as! Dictionary<String, AnyObject>
                    var postsArray = result["posts"] as! [AnyObject]
                    var feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: feedsArray)
                }
            }
            
        })
    }
    
    func getFollowingNewsfeed(pageNo : Int){
        Utilities.showHUD()
        var postData = NSMutableDictionary()
        var pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_FOLLOWING_FEED,withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                println("Error when get getGlobalNewsfeed = \(error)")

                NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
            } else {
                println("getFollowingNewsfeed response = \(response)")
                var result = Utilities.parseNSDictionaryToDictionary(response)
                var errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                } else { // no error
                    var userDict = result["user"] as! Dictionary<String, AnyObject>
                    var postsArray = result["posts"] as! [AnyObject]
                    var feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: feedsArray)
                }
            }
            
        })
    }
    
    func sendHeart(postId : String, type : String){
        Utilities.showHUD()
        var postData = NSMutableDictionary()
        postData.setObject(postId, forKey: "post_id")
        postData.setObject(type, forKey: "type")
        XAppDelegate.mobilePlatform.sc.sendRequest(SEND_HEART,withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                println("Error when get getGlobalNewsfeed = \(error)")
            } else {
                println("sendHeart sendHeart response = \(response)")
                var result = Utilities.parseNSDictionaryToDictionary(response)
                var errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                    Utilities.showAlertView(self, title: "Error", message: "Please try again later!")
                } else { // no error
                    var success = result["success"] as! Int
                    if success == 1 {
                        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_SEND_HEART_FINISHED, object: nil)
                    } else {
//                        Utilities.showAlertView(self, title: "Error", message: "Please try again later!")\
                        println("Post unsuccessful")
                    }
                }
            }
        })
    }

    func createPost(type: String, message: String) {
        var postData = NSMutableDictionary()
        postData.setObject(type, forKey: "type")
        postData.setObject(message, forKey: "message")
        XAppDelegate.mobilePlatform.sc.sendRequest(CREATE_POST, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if error != nil {
                println("Error when creating post \(error)")
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(response)
                let errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                } else { // no error
                    let postId = result["post_id"] as! String
                    // TODO: - Use post id when needed
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_CREATE_POST_FINISHED, object: nil)
                }
            }
        }
    }
}