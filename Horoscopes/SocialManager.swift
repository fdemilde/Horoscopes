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
//                println("getGlobalNewsfeed result = \(result)")
                var errorCode = result["error"] as! Int
                if(errorCode != 0){
                    println("Error code = \(errorCode)")
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
                } else { // no error
//                    println("result == \(result)")
                    var userDict = result["users"] as! Dictionary<String, AnyObject>
                    var postsArray = result["posts"] as! [AnyObject]
                    var isLastAsNumber = result["last"] as! Int
                    var feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    if(isAddingData){
                        XAppDelegate.dataStore.addDataArray(feedsArray, type: NewsfeedTabType.Global, isLastPage: Bool(isLastAsNumber))
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
                    var isLastAsNumber = result["last"] as! Int
                    var feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    if(isAddingData){
                        XAppDelegate.dataStore.addDataArray(feedsArray, type: NewsfeedTabType.Following, isLastPage: Bool(isLastAsNumber))
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
    
    // MARK: Log in
    func isLoggedInFacebook() -> Bool{
        return FBSDKAccessToken .currentAccessToken() != nil
    }
    
    func loginFacebook(completionHandler: (error: NSError?, permissionGranted: Bool) -> Void) {
        var loginManager = FBSDKLoginManager()
        var permissions = ["public_profile", "email", "user_birthday","user_friends"]
        loginManager.logInWithReadPermissions(permissions, handler: { (result, error) -> Void in
            if let error = error {
                completionHandler(error: error, permissionGranted: false)
            } else {
                if result.isCancelled {
                    completionHandler(error: nil, permissionGranted: false)
                } else {
                    if result.grantedPermissions.contains("public_profile") {
                        completionHandler(error: nil, permissionGranted: true)
                    } else {
                        completionHandler(error: nil, permissionGranted: false)
                    }
                }
            }
        })
    }
    
    func isLoggedInZwigglers() -> Bool{
        return XAppDelegate.mobilePlatform.userCred.hasToken()
    }
    
    func loginZwigglers(token: String, completionHandler: (responseDict: [NSObject: AnyObject]?, error: NSError?) -> Void){
        var params = NSMutableDictionary(objectsAndKeys: "facebook","login_method",FACEBOOK_APP_ID,"app_id",token, "access_token")
        XAppDelegate.mobilePlatform.userModule.loginWithParams(params, andCompleteBlock: { (responseDict, error) -> Void in
            if let error = error {
                completionHandler(responseDict: nil, error: error)
            } else {
                XAppDelegate.locationManager.setupLocationService()
                self.persistUserProfile({ (error) -> Void in
                    
                })
                completionHandler(responseDict: responseDict, error: nil)
            }
        })
    }
    
    // Convenience method that log in Facebook then log in Zwigglers
    func login(completionHandler: (error: NSError?, permissionGranted: Bool) -> Void) {
        loginFacebook { (error, permissionGranted) -> Void in
            if let error = error {
                completionHandler(error: error, permissionGranted: false)
            } else {
                if permissionGranted {
                    self.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                        if let error = error {
                            completionHandler(error: error, permissionGranted: false)
                        } else {
                            completionHandler(error: nil, permissionGranted: true)
                        }
                    })
                } else {
                    completionHandler(error: nil, permissionGranted: false)
                }
            }
        }
    }
    
    // MARK: Location
    
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
    
    // MARK: Server Notification
    
    
    
    func registerAPNSNotificationToken(token : String, completionHandler:(response : Dictionary<String,AnyObject>?, error : NSError?) -> Void ){
        var postData = NSMutableDictionary()
        postData.setObject(token, forKey: "device_token")
        XAppDelegate.mobilePlatform.sc.sendRequest(REGISTER_APNS_NOTIFICATION_TOKEN, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            var result = Utilities.parseNSDictionaryToDictionary(response)
            completionHandler(response: result, error: error)
        })
    }
    
    
    
    func registerServerNotificationToken(token : String){
        var postData = NSMutableDictionary()
        postData.setObject(token, forKey: "device_token")
        
        XAppDelegate.mobilePlatform.sc.sendRequest(REGISTER_SERVER_NOTIFICATION_TOKEN, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            println("registerServerNotificationToken == \(response)")
            var success = response["success"] as! Int
            if(success == 1){
                println("registerServerNotificationToken successful")
            } else {
                println("registerServerNotificationToken failed")
            }
        })
    }
    
    func sendHeartServerNotification(receiverId : Int, postId : String){
        var alert = Alert()
        var currentUser = XAppDelegate.currentUser
        alert.title = "Send heart"
        alert.body = "\(currentUser.name) sent you a heart"
        alert.imageURL = "\(currentUser.imgURL)"
        alert.priority = 5
        
        var routeString = "/post/\(postId)/hearts"
        var recieverIdString = "\(receiverId)"
        XAppDelegate.mobilePlatform.platformNotiff.sendTo(recieverIdString, withRoute: routeString, withAlert: alert, withRef: "send_heart", withPush: 0, withData: "data") { (result) -> Void in
            println("sendHeartServerNotification result = \(result)")
        }
    }
    
    func sendFollowNotification(receiverId : Int) {
        var alert = Alert()
        alert.title = "Follow"
        var currentUser = XAppDelegate.currentUser
        alert.body = "\(currentUser.name) followed you"
        alert.imageURL = "\(currentUser.imgURL)"
        alert.priority = 5
        
        var receiverIdString = "\(receiverId)"
        let route = "/profile/\(currentUser.uid)/feed"
        XAppDelegate.mobilePlatform.platformNotiff.sendTo(receiverIdString, withRoute: route, withAlert: alert, withRef: "follow", withPush: 0, withData: "data") { (result) -> Void in
            println("sendFollowNotification result \(result)")
        }
    }
    
    func getAllNotification(since : Int, completionHandler:(result : [NotificationObject]?) -> Void ){
        XAppDelegate.mobilePlatform.platformNotiff.getAllwithSince(Int32(since), andCompleteBlock: { (result) -> Void in
            var resultArray = result as AnyObject as! [NotificationObject]
            completionHandler(result: resultArray)
        })
    }
    
    func clearAllNotification(){
        var listIds = [String]()
        listIds.append("21_8")
//        listIds.append("9_8")
//        listIds.append("10_8")
//        listIds.append("11_8")
//        listIds.append("12_8")
//        listIds.append("16_8")
//        listIds.append("17_8")
        XAppDelegate.mobilePlatform.platformNotiff.clearWithListID(listIds, andCompleteBlock: { (result) -> Void in
            println("clearAllNotification result = \(result)")
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
        XAppDelegate.mobilePlatform.sc.sendRequest(method, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response)
                let profiles = Utilities.parseUsersArray(json["profiles"] as! Dictionary<String, AnyObject>).values.array
                completionHandler(result: profiles, error: nil)
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
    
    func persistUserProfile(completionHandler: (error: NSError?) -> Void) {
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
        self.getProfile("\(uid)", completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(error: error)
            } else {
                let userProfile = result![0]
                XAppDelegate.currentUser = userProfile
                NSKeyedArchiver.archiveRootObject(userProfile, toFile: UserProfile.filePath)
                completionHandler(error: nil)
            }
        })
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