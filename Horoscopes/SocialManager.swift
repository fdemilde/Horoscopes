//
//  SocialManager.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

@objc protocol SocialManagerDelegate
{
    optional func facebookLoginFinished(result : [NSObject : AnyObject]?, error : NSError?)
    optional func facebookLoginTokenExists(token : FBSDKAccessToken)
    optional func reloadView(result : [NSObject : AnyObject]?, error : NSError?)
}

class SocialManager: NSObject, UIAlertViewDelegate {

    
//    var globalFeeds = []
    static let sharedInstance = SocialManager()
    
    var delegate : SocialManagerDelegate!
    
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
    
    func getGlobalNewsfeed(pageNo : Int, isAddingData : Bool){
        if(XAppDelegate.dataStore.newsfeedGlobal.count == 0){
            Utilities.showHUD()
        }
        var postData = NSMutableDictionary()
        var pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_GLOBAL_FEED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            Utilities.hideHUD()
            if(error != nil){
                println("Error when get getGlobalNewsfeed = \(error)")
                Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
            } else {
                var result = Utilities.parseNSDictionaryToDictionary(response)
                var errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
                } else { // no error
//                    println("result == \(result)")
                    var userDict = result["users"] as! Dictionary<String, AnyObject>
                    var postsArray = result["posts"] as! [AnyObject]
                    var feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    if(isAddingData){
                        XAppDelegate.dataStore.addDataArray(feedsArray, type: NewsfeedTabType.Global)
                    } else {
                        XAppDelegate.dataStore.updateData(feedsArray, type: NewsfeedTabType.Global)
                    }
                }
            }
            
        })
    }
    
    func getFollowingNewsfeed(pageNo : Int, isAddingData : Bool){
        if(XAppDelegate.dataStore.newsfeedFollowing.count == 0){
            Utilities.showHUD()
        }
        
        var postData = NSMutableDictionary()
        var pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        // change to test  GET_FOLLOWING_FEED
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_FOLLOWING_FEED,withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            Utilities.hideHUD()
            if(error != nil){
                println("Error when get getFollowingNewsfeed = \(error)")
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
            } else {
                var result = Utilities.parseNSDictionaryToDictionary(response)
//                println("result when get getFollowingNewsfeed = \(result)")
                var errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                } else { // no error
                    var userDict = result["users"] as! Dictionary<String, AnyObject>
                    var postsArray = result["posts"] as! [AnyObject]
                    var feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    if(isAddingData){
                        XAppDelegate.dataStore.addDataArray(feedsArray, type: NewsfeedTabType.Following)
                    } else {
                        XAppDelegate.dataStore.updateData(feedsArray, type: NewsfeedTabType.Following)
                    }
                    
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
                println("Error when get sendHeart = \(error)")
            } else {
                var result = Utilities.parseNSDictionaryToDictionary(response)
                var errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                    Utilities.hideHUD()
                    Utilities.showAlertView(self, title: "Error", message: "Please try again later!")
                } else { // no error
                    var success = result["success"] as! Int
                    if success == 1 {
                        Utilities.postNotification(NOTIFICATION_SEND_HEART_FINISHED, object: nil)
                    } else {
//                        Utilities.showAlertView(self, title: "Error", message: "Please try again later!")\
                        Utilities.hideHUD()
                        println("Post unsuccessful")
                    }
                }
            }
        })
    }
    
    // MARK: Post

    func createPost(type: String, message: String, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void) {
        var postData = NSMutableDictionary()
        postData.setObject(type, forKey: "type")
        postData.setObject(message, forKey: "message")
        
        let createPost = { () -> () in
            XAppDelegate.mobilePlatform.sc.sendRequest(CREATE_POST, withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response, error) -> Void in
                if let error = error {
                    completionHandler(result: nil, error: error)
                } else {
                    let result = Utilities.parseNSDictionaryToDictionary(response)
                    completionHandler(result: result, error: nil)
                }
            })
        }
        
        if isLoggedInZwigglers() {
            createPost()
        } else {
            if(FBSDKAccessToken.currentAccessToken() != nil){
                loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        completionHandler(result: nil, error: error)
                    } else {
                        createPost()
                    }
                })
            }
            
        }
    }
    
    func getPost(uid: Int, page: Int = 0, completionHandler: (result: [UserPost]?, error: NSError?) -> Void) {
        getProfile("\(uid)", completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                var userProfile = result![0]
                var postData = NSMutableDictionary()
                postData.setObject("\(page)", forKey: "page")
                postData.setObject("\(uid)", forKey: "uid")
                
                XAppDelegate.mobilePlatform.sc.sendRequest(GET_USER_FEED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
                    if let error = error {
                        completionHandler(result: nil, error: error)
                    } else {
                        let json = Utilities.parseNSDictionaryToDictionary(response)
                        let results = json["posts"] as! [NSDictionary]
                        let posts = UserPost.postsFromResults(results)
                        for post in posts {
                            post.user = userProfile
                        }
                        completionHandler(result: posts, error: nil)
                    }
                })
            }
        })
    }
    
    // MARK: Profile
    
    func follow(uid: Int, completionHandler: (error: NSError?) -> Void) {
        var postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid")
        XAppDelegate.mobilePlatform.sc.sendRequest(FOLLOW, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(error: error)
            } else {
                completionHandler(error: nil)
            }
        }
    }
    
    func unfollow(uid: Int, completionHandler: (error: NSError?) -> Void) {
        var postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid")
        XAppDelegate.mobilePlatform.sc.sendRequest(UNFOLLOW, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(error: error)
            } else {
                completionHandler(error: nil)
            }
        }
    }
    
    func isFollowing(uid: Int, followerId: Int, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void) {
        var postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid")
        postData.setObject("\(followerId)", forKey: "follower")
        XAppDelegate.mobilePlatform.sc.sendRequest(IS_FOLLOWING, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(response)
                completionHandler(result: result, error: nil)
            }
        }
    }
    
    func getProfile(usersIdString: String, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        var postData = NSMutableDictionary()
        postData.setObject(usersIdString, forKey: "uid")
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_PROFILE, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if(response != nil){
                    let json = Utilities.parseNSDictionaryToDictionary(response)
                    var result = [UserProfile]()
                    for userId in usersIdString.componentsSeparatedByString(",") {
                        if let users = json["result"] as? Dictionary<String, AnyObject> {
                            let userProfile = UserProfile(data: users[userId] as! NSDictionary)
                            result.append(userProfile)
                        }
                    }
                    completionHandler(result: result, error: nil)
                }
                
            }
        }
    }
    
    func getCurrentUserFollowingProfile(completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        getCurrentUserFollowProfile(GET_CURRENT_USER_FOLLOWING, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        })
    }
    
    func getCurrentUserFollowersProfile(completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        getCurrentUserFollowProfile(GET_CURRENT_USER_FOLLOWERS, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        })
    }
    
    func getOtherUserFollowersProfile(uid: Int, page: Int = 0, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        getOtherUserFollowProfile(uid, page: page, method: GET_OTHER_USER_FOLLOWERS) { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        }
    }
    
    func getOtherUserFollowingProfile(uid: Int, page: Int = 0, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        getOtherUserFollowProfile(uid, page: page, method: GET_OTHER_USER_FOLLOWING) { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        }
    }
    
    func loginFacebook(completionHandler: (result: FBSDKLoginManagerLoginResult?, error: NSError?) -> ()) {
        var loginManager = FBSDKLoginManager()
        var permissions = ["public_profile", "email", "user_birthday","user_friends"]
        loginManager.logInWithReadPermissions(permissions, handler: { (result, error : NSError?) -> Void in
            if let error = error {
                Utilities.showAlertView(self, title: "Login Error", message: "Cannot login to facebook")
                completionHandler(result: nil, error : error)
            } else if let result = result {
                if result.isCancelled {
                    Utilities.showAlertView(self, title: "Permission denied", message: "")
                    completionHandler(result: result, error : nil)
                } else {
                    if result.grantedPermissions.contains("public_profile") {
                        completionHandler(result: result, error : nil)
                    } else {
                        Utilities.showAlertView(self, title: "Permission denied", message: "")
                        completionHandler(result: nil, error : error)
                    }
                    
                }
            }
            
        })
    }
    
    // MARK: Network - Report Issue
    
    func reportIssue(message : String, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void){
        
        var postData = NSMutableDictionary()
        postData.setObject(message, forKey: "user_message")
        var systemMessage = XAppDelegate.mobilePlatform.tracker.getDeviceInfo()
        postData.setObject(systemMessage, forKey: "system_message")
        
        XAppDelegate.mobilePlatform.sc.sendRequest(REPORT_ISSUE_METHOD, andPostData: postData) { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(result)
                completionHandler(result: result, error: nil)
            }
        }
        
    }
    
    func sendUserUpdateLocation(location : String?, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void){
        
        var postData = NSMutableDictionary()
        postData.setObject(location!, forKey: "location_result")
        
        XAppDelegate.mobilePlatform.sc.sendRequest(SEND_USER_UPDATE, withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(result)
                completionHandler(result: result, error: nil)
            }
        })
        
    }
    
    // MARK: Helpers
    func getCurrentUserFollowProfile(method: String, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        XAppDelegate.mobilePlatform.sc.sendRequest(method, withLoginRequired: REQUIRED, andPostData: nil) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response)
                var key = ""
                if method == GET_CURRENT_USER_FOLLOWERS {
                    key = "followers"
                } else {
                    key = "following"
                }
                if let usersId = json[key] as? [Int] {
                    if !usersId.isEmpty {
                        self.getProfile(usersId, completionHandler: { (result, error) -> Void in
                            if let error = error {
                                completionHandler(result: nil, error: error)
                            } else {
                                completionHandler(result: result, error: nil)
                            }
                        })
                    } else {
                        completionHandler(result: [UserProfile](), error: nil)
                    }
                }
            }
        }
    }
    
    func getOtherUserFollowProfile(uid: Int, page: Int = 0, method: String, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        var postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid")
        postData.setObject("\(page)", forKey: "page")
        println("postData \(postData)")
        XAppDelegate.mobilePlatform.sc.sendRequest(method, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response)
                println(json)
            }
        }
    }
    
    private func getProfile(usersId: [Int], completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        let usersIdString = usersId.map({"\($0)"})
        self.getProfile(",".join(usersIdString), completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        })
    }
    
    func isLoggedInFacebook() -> Bool{
        return FBSDKAccessToken .currentAccessToken() != nil
    }
    
    func isLoggedInZwigglers() -> Bool{
        return XAppDelegate.mobilePlatform.userCred.hasToken()
    }
    
    func loginZwigglers(token: String, completionHandler: (responseDict: [NSObject: AnyObject]?, error: NSError?) -> Void){
        var params = NSMutableDictionary(objectsAndKeys: "facebook","login_method",FACEBOOK_APP_ID,"app_id",token, "access_token")
        XAppDelegate.mobilePlatform.userModule.loginWithParams(params, andCompleteBlock: { (responseDict, error) -> Void in
            completionHandler(responseDict: responseDict, error: error)
        })
    }
    
    func persistUserProfile(completionHandler: (error: NSError?) -> Void) {
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
        self.getProfile("\(uid)", completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(error: error)
            } else {
                if result!.count > 0 {
                    let userProfile = result![0]
                    XAppDelegate.currentUser = userProfile
                    NSKeyedArchiver.archiveRootObject(userProfile, toFile: UserProfile.filePath)
                    completionHandler(error: nil)
                }
            }
        })
    }
    
    func login(completionHandler: (error: NSError?) -> Void) {
        if !isLoggedInFacebook() {
            loginFacebook({ (result, error) -> () in
                if let error = error {
                    completionHandler(error: error)
                } else {
                    if !self.isLoggedInZwigglers() {
                        self.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                            if let error = error {
                                completionHandler(error: error)
                            } else {
                                XAppDelegate.locationManager.setupLocationService()
                                self.persistUserProfile({ (error) -> Void in
                                    if let error = error {
                                        completionHandler(error: error)
                                    } else {
                                        completionHandler(error: nil)
                                    }
                                })
                            }
                        })
                    }
                }
            })
        }
    }
    
    func retrieveFriendList(completionHandler: (result: [UserProfile]!, error: NSError?) -> Void) {
        var postData = NSMutableDictionary()
        postData.setObject(FACEBOOK_APP_ID, forKey: "app_id")
        var systemMessage = XAppDelegate.mobilePlatform.tracker.getDeviceInfo()
        if(isLoggedInFacebook()){
            postData.setObject(FBSDKAccessToken.currentAccessToken().tokenString, forKey: "access_token")
        }

        XAppDelegate.mobilePlatform.sc.sendRequest(GET_FRIEND_LIST, withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(result)
                var userArray = [UserProfile]()
                if let profiles = result["profiles"] as? Dictionary<String, AnyObject>{
                    var userDict = Utilities.parseUsersArray(profiles)
                    for (uid, user) in userDict {
                        userArray.append(user)
                    }
                }
                completionHandler(result: userArray, error: nil)
            }
        })
    }
}