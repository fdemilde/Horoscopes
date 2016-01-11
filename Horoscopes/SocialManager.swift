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
    
    private func expiredKeyForPaging (isRefreshed: Bool, pageKey: String, requestMethod: String, pageNumber: Int, postData: NSMutableDictionary) -> String {
        let expiredPostData = postData.mutableCopy() as! NSMutableDictionary
        var expiredPageString = ""
        var expiredKey = ""
        if isRefreshed { // force refresh right away, used at Pull-to-refresh
            expiredPageString = String(format:"%d", 0)
            expiredPostData.setObject(expiredPageString, forKey: pageKey)
            expiredKey = Utilities.getKeyFromUrlAndPostData(requestMethod, postData: expiredPostData)
            CacheManager.cacheExpire(expiredKey)
            expiredKey = ""
        }
        expiredPageString = String(format:"%d",(pageNumber + 1))
        expiredPostData.setObject(expiredPageString, forKey: pageKey)
        expiredKey = Utilities.getKeyFromUrlAndPostData(requestMethod, postData: expiredPostData)
        return expiredKey
    }
    
    func getGlobalNewsfeed(pageNo : Int, isAddingData : Bool, isRefreshing: Bool = false){
        if(XAppDelegate.dataStore.newsfeedGlobal.count == 0){
            Utilities.showHUD()
        }
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        let expiredTime = NSDate().timeIntervalSince1970 + 600
        
        // need to expire next page if current page is expired
        let expiredKey = expiredKeyForPaging(isRefreshing, pageKey: "page", requestMethod: GET_GLOBAL_FEED, pageNumber: pageNo, postData: postData)
        CacheManager.cacheGet(GET_GLOBAL_FEED, postData: postData, loginRequired: OPTIONAL, expiredTime: expiredTime, forceExpiredKey: expiredKey) { (response, error) -> Void in
            if(error != nil){
                print("Error when get getGlobalNewsfeed = \(error)")
                Utilities.showError(error!)
                Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
            } else {
                var result = Utilities.parseNSDictionaryToDictionary(response!)
//                print("getGlobalNewsfeed result = \(result)")
                let errorCode = result["error"] as! Int
                if(errorCode != 0){
                    print("Error code = \(errorCode)")
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
                } else { // no error
                    //                    println("result == \(result)")
                    let userDict = result["profiles"] as! Dictionary<String, AnyObject>
                    let postsArray = result["posts"] as! [AnyObject]
                    let isLastAsNumber = result["last"] as! Int
                    let feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    if(isAddingData){
                        XAppDelegate.dataStore.addDataArray(feedsArray, type: NewsfeedTabType.Global, isLastPage: Bool(isLastAsNumber))
                    } else {
                        XAppDelegate.dataStore.updateData(feedsArray, type: NewsfeedTabType.Global)
                    }
                }
            }
        }
    }
    
    func getFollowingNewsfeed(pageNo : Int, isAddingData : Bool, isRefreshing: Bool = false){
        if(XAppDelegate.dataStore.newsfeedFollowing.count == 0){
            Utilities.showHUD()
        }
        
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        // change to test  GET_FOLLOWING_FEED
        let expiredTime = NSDate().timeIntervalSince1970 + 600
        
        let expiredKey = expiredKeyForPaging(isRefreshing, pageKey: "page", requestMethod: GET_FOLLOWING_FEED, pageNumber: pageNo, postData: postData)
        CacheManager.cacheGet(GET_FOLLOWING_FEED, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: expiredKey) { (response, error) -> Void in
            if(error != nil){
                print("Error when get getFollowingNewsfeed = \(error)")
                Utilities.showError(error!)
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
            } else {
//                                print("getFollowingNewsfeed == \(response)")
                var result = Utilities.parseNSDictionaryToDictionary(response!)
                //                println("result when get getFollowingNewsfeed = \(result)")
                let errorCode = result["error"] as! Int
                if(errorCode != 0){
                    print("Error code = \(errorCode)")
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                } else { // no error
                    let userDict = result["profiles"] as! Dictionary<String, AnyObject>
                    let postsArray = result["posts"] as! [AnyObject]
                    let isLastAsNumber = result["last"] as! Int
                    let feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    if(isAddingData){
                        XAppDelegate.dataStore.addDataArray(feedsArray, type: NewsfeedTabType.Following, isLastPage: Bool(isLastAsNumber))
                    } else {
                        XAppDelegate.dataStore.updateData(feedsArray, type: NewsfeedTabType.Following)
                    }
                }
            }
        }
    }
    
    func sendHeart(receiverId: Int, postId : String, type : String){
        let postData = NSMutableDictionary()
        postData.setObject(postId, forKey: "post_id")
        postData.setObject(type, forKey: "type")
        XAppDelegate.mobilePlatform.sc.sendRequest(SEND_HEART,withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                print("Error when get sendHeart = \(error)")
            } else {
                var result = Utilities.parseNSDictionaryToDictionary(response)
                let errorCode = result["error"] as! Int
                if(errorCode != 0){
                    print("Error code = \(errorCode)")
                    Utilities.showError(error)
                } else { // no error
                    let success = result["success"] as! Int
                    if success == 1 {
//                        self.sendHeartServerNotification(receiverId, postId: postId)
//                        Utilities.postNotification(NOTIFICATION_SEND_HEART_FINISHED, object: postId)
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: postId)
                    } else {
                        print("Post unsuccessful")
                    }
                }
            }
        })
    }
    
    // MARK: Post

    func createPost(type: String, message: String, postToFacebook : Bool = false, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject(type, forKey: "type")
        postData.setObject(message, forKey: "message")
        if(postToFacebook){
            postData.setObject("1", forKey: "post_to_facebook")
            postData.setObject(FACEBOOK_APP_ID, forKey: "app_id")
            postData.setObject(FBSDKAccessToken .currentAccessToken().tokenString, forKey: "access_token")
            
        }
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
    
    func getUserFeed(uid: Int, page: Int = 0, isRefreshed: Bool = false, completionHandler: (result: ([UserPost], isLastPage: Bool)?, error: NSError?) -> Void) {
        getProfile("\(uid)",ignoreCache : false, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let userProfile = result?[0]{
                    let postData = NSMutableDictionary()
                    postData.setObject("\(page)", forKey: "page")
                    postData.setObject("\(uid)", forKey: "uid")
                    let expiredTime = NSDate().timeIntervalSince1970 + 600
                    
                    // need to expire next page if current page is expired
                    let expiredKey = self.expiredKeyForPaging(isRefreshed, pageKey: "page", requestMethod: GET_USER_FEED, pageNumber: page, postData: postData)
                    CacheManager.cacheGet(GET_USER_FEED, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: expiredKey, completionHandler: { (response, error) -> Void in
                        if let error = error {
                            completionHandler(result: nil, error: error)
                        } else {
                            let json = Utilities.parseNSDictionaryToDictionary(response!)
                            let last = json["last"] as! Int
                            let results = json["posts"] as! [NSDictionary]
                            let posts = UserPost.postsFromResults(results)
                            for post in posts {
                                post.user = userProfile
                            }
                            let result = (posts, isLastPage: last == 1)
                            completionHandler(result: result, error: nil)
                        }
                    })
                } else {
                    print("Cannot save getUserFeed!!")
                    completionHandler(result: nil, error: error)
                }
            }
        })
    }
    
    // get post with post ids string
    func getPost(postIds : String, ignoreCache: Bool = false, completionHandler: (result: [UserPost]?, error: NSError?) -> Void){
        let postData = NSMutableDictionary()
        postData.setObject("\(postIds)", forKey: "post_id")
        let expiredTime = NSDate().timeIntervalSince1970 + 600
        CacheManager.cacheGet(GET_POST, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: nil, ignoreCache: ignoreCache) { (response, error) -> Void in
//            print("response response == \(response)")
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let results = Utilities.parseNSDictionaryToDictionary(response!)
                let userDict = results["profiles"] as! Dictionary<String, AnyObject>
                let postsDict = results["posts"] as! Dictionary<String, AnyObject>
                var postArray = [AnyObject]()
                for (_,post) in postsDict {
                    postArray.append(post)
                }
                let feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postArray)
                completionHandler(result: feedsArray, error: nil)
            }
        }
    }
    
    // MARK: Profile
    
    func getProfileCounts(usersId: [Int], completionHandler: (result: [UserProfileCounts]?, error: NSError?) -> Void) {
        let usersIdString = usersId.map({ String($0) }).joinWithSeparator(",")
        let postData = NSMutableDictionary()
        postData.setObject(usersIdString, forKey: "uid")
        let expiredTime = NSDate().timeIntervalSince1970 + 600
        CacheManager.cacheGet(GET_PROFILE_COUNTS, postData: postData, loginRequired: OPTIONAL, expiredTime: expiredTime, forceExpiredKey: nil) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response!)
                var result = [UserProfileCounts]()
                if let dictionary = json["counts"] as? [String: AnyObject] {
                    for count in dictionary.values {
                        result.append(UserProfileCounts(dictionary: count as! [String : AnyObject]))
                    }
                    completionHandler(result: result, error: nil)
                }
            }
        }
    }
    
    func follow(user: UserProfile, completionHandler: (error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(user.uid)", forKey: "uid")
        XAppDelegate.mobilePlatform.sc.sendRequest(FOLLOW, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(error: error)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_FOLLOW, object: user)
                })
//                SocialManager.sharedInstance.sendFollowNotification(user.uid)
                completionHandler(error: nil)
            }
        }
    }
    
    func unfollow(user: UserProfile, completionHandler: (error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(user.uid)", forKey: "uid")
        XAppDelegate.mobilePlatform.sc.sendRequest(UNFOLLOW, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(error: error)
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_UNFOLLOW, object: user)
                })
                completionHandler(error: nil)
            }
        }
    }
    
    func isFollowing(uid: Int, followerId: Int, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
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
    
    func getProfile(usersIdString: String, ignoreCache : Bool = false, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject(usersIdString, forKey: "uid")
        let longExpiredTime = NSDate().timeIntervalSince1970 + 86400
        CacheManager.cacheGet(GET_PROFILE, postData: postData, loginRequired: OPTIONAL, expiredTime: longExpiredTime, forceExpiredKey: nil, ignoreCache : ignoreCache) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if(response != nil){
                    let json = Utilities.parseNSDictionaryToDictionary(response!)
                    var result = [UserProfile]()
                    for userId in usersIdString.componentsSeparatedByString(",") {
                        if let users = json["profiles"] as? Dictionary<String, AnyObject> {
                            let userProfile = UserProfile(data: users[userId] as! NSDictionary)
                            result.append(userProfile)
                        }
                    }
                    completionHandler(result: result, error: nil)
                }
                
            }
        }
    }
    
    func getProfilesOfUsersFollowing(completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        getCurrentUserFollowProfile(GET_CURRENT_USER_FOLLOWING, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        })
    }
    
    func getProfilesOfFollowers(completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        getCurrentUserFollowProfile(GET_CURRENT_USER_FOLLOWERS, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        })
    }
    
    func getProfilesOfUsersFollowing(forUser uid: Int, page: Int = 0, completionHandler: (result: ([UserProfile], isLastPage: Bool)?, error: NSError?) -> Void) {
        getOtherUserFollowProfile(uid, page: page, method: GET_OTHER_USER_FOLLOWING) { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        }
    }
    
    func getProfilesOfFollowers(forUser uid: Int, page: Int = 0, completionHandler: (result: ([UserProfile], isLastPage: Bool)?, error: NSError?) -> Void) {
        getOtherUserFollowProfile(uid, page: page, method: GET_OTHER_USER_FOLLOWERS) { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        }
    }
    
    // MARK: Network - Report Issue
    
    func reportIssue(message : String, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void){
        
        let postData = NSMutableDictionary()
        postData.setObject(message, forKey: "user_message")
        let systemMessage = XAppDelegate.mobilePlatform.tracker.getDeviceInfo()
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
    
    func loginFacebook(viewController: UIViewController, completionHandler: (error: NSError?, permissionGranted: Bool) -> Void) {
        
            let loginManager = FBSDKLoginManager()
            loginManager.loginBehavior = .SystemAccount
            let permissions = ["public_profile", "email", "user_friends"]
            let permissionLabel = "permission = \(permissions)"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginAsk, label: permissionLabel)
            
            loginManager.logInWithReadPermissions(permissions, fromViewController: viewController) { (result, error) -> Void in
                if let error = error {
                    completionHandler(error: error, permissionGranted: false)
                } else {
                    if result.isCancelled {
                        completionHandler(error: nil, permissionGranted: false)
                    } else {
                        let label = "granted = \(result.grantedPermissions)"
                        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginResult, label: label)
                        for permission in permissions {
                            if result.declinedPermissions.contains(permission) {
                                completionHandler(error: nil, permissionGranted: false)
                                return
                            }
                        }
                        completionHandler(error: nil, permissionGranted: true)
                        // if user logs in Facebook first time.
                        if !NSUserDefaults.standardUserDefaults().boolForKey(isNotLoggedInFacebookFirstTimeKey) {
                            let pickedSign = XAppDelegate.userSettings.horoscopeSign
                            var signSentToServer = 0
                            if pickedSign != -1 {
                                signSentToServer = Int(XAppDelegate.userSettings.horoscopeSign + 1)
                            }
                            self.sendUserUpdateSign(signSentToServer, completionHandler: { (result, error) -> Void in
                                let errorCode = result?["error"] as! Int
                                if errorCode == 0 {
                                    self.persistUserProfile(true, completionHandler: { (error) -> Void in
                                        if let _ = error {
                                            
                                        } else {
                                            NSUserDefaults.standardUserDefaults().setBool(true, forKey: isNotLoggedInFacebookFirstTimeKey)
                                        }
                                    })
                                }
                            })
                        }
                    }
                }
            }
    }
    
    func isLoggedInZwigglers() -> Bool{
        return XAppDelegate.mobilePlatform.userCred.hasToken()
    }
    
    func loginZwigglers(token: String, completionHandler: (responseDict: [NSObject: AnyObject]?, error: NSError?) -> Void){
        Utilities.showHUD()
        let objects = ["facebook", FACEBOOK_APP_ID, token]
        let keys = ["login_method", "app_id", "access_token"]
        let params = NSMutableDictionary(objects: objects, forKeys: keys)
        XAppDelegate.mobilePlatform.userModule.loginWithParams(params, andCompleteBlock: { (responseDict, error) -> Void in
            Utilities.hideHUD()
            if let error = error {
                completionHandler(responseDict: nil, error: error)
            } else {
                self.persistUserProfile(completionHandler: { (error) -> Void in
                    if let error = error {
                        completionHandler(responseDict: nil, error: error)
                    } else {
                        completionHandler(responseDict: responseDict, error: nil)
                    }
                })
                
            }
        })
    }
    
    func logoutZwigglers(completionHandler: (responseDict: [NSObject: AnyObject]?, error: NSError?) -> Void){
        XAppDelegate.mobilePlatform.userModule.logoutWithCompleteBlock { (result, error) -> Void in
            print("logoutZwigglers result == \(result)")
        }
    }
    
    // Convenience method that log in Facebook then log in Zwigglers
    func login(viewController: UIViewController, completionHandler: (error: NSError?, permissionGranted: Bool) -> Void) {
        loginFacebook(viewController) { (error, permissionGranted) -> Void in
            if let error = error {
                let label = "success = 0"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginResult, label: label)
                completionHandler(error: error, permissionGranted: false)
            } else {
                let label = "success = 1"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginResult, label: label)
                if permissionGranted {
                    self.loginZwigglers(FBSDKAccessToken.currentAccessToken().tokenString, completionHandler: { (responseDict, error) -> Void in
                        Utilities.registerForRemoteNotification()
                        if let error = error {
                            completionHandler(error: error, permissionGranted: false)
                        } else {
                            completionHandler(error: nil, permissionGranted: true)
                            
                            XAppDelegate.locationManager.setupLocationService()
                                self.getProfilesOfUsersFollowing({ (result, error) -> Void in
                                if let _ = error {
                                    
                                } else {
                                    XAppDelegate.dataStore.usersFollowing = result!
                                }
                            })
                        }
                    })
                } else {
                    completionHandler(error: nil, permissionGranted: false)
                }
            }
        }
    }
    
    // MARK: Location
    
    func sendUserUpdateLocation(latlon : String, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void){
        let postData = NSMutableDictionary()
        postData.setObject(latlon, forKey: "latlon")
        
        XAppDelegate.mobilePlatform.sc.sendRequest(SEND_USER_UPDATE, withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(result)
                print("sendUserUpdateLocation sendUserUpdateLocation == \(result)")
                completionHandler(result: result, error: nil)
            }
        })
        
    }
    
    func sendUserUpdateSign(sign : Int?, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void){
        
        let postData = NSMutableDictionary()
        postData.setObject("\(sign!)", forKey: "sign")
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
        let postData = NSMutableDictionary()
        postData.setObject(token, forKey: "device_token")
        XAppDelegate.mobilePlatform.sc.sendRequest(REGISTER_APNS_NOTIFICATION_TOKEN, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            let result = Utilities.parseNSDictionaryToDictionary(response)
            completionHandler(response: result, error: error)
        })
    }
    
    
    
    func registerServerNotificationToken(token : String){
        let postData = NSMutableDictionary()
        postData.setObject(token, forKey: "device_token")
//        print("registerServerNotificationToken == \(token)")
        XAppDelegate.mobilePlatform.sc.sendRequest(REGISTER_SERVER_NOTIFICATION_TOKEN, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
//            print("registerServerNotificationToken == \(response)")
            if let success = response["success"] as? Int {
                if(success == 1){
                    //                print("registerServerNotificationToken successful")
                } else {
                    //                print("registerServerNotificationToken failed")
                }
            }
            
        })
    }
    
    func sendHeartServerNotification(receiverId : Int, postId : String){
        let alert = Alert()
        let currentUser = XAppDelegate.currentUser
        alert.title = "Send heart"
        alert.body = "\(currentUser.name) sent you a heart"
        alert.imageURL = "\(currentUser.imgURL)"
        alert.priority = 5
        alert.type = "send_heart"
        
        let routeString = "/post/\(postId)/hearts"
        let recieverIdString = "\(receiverId)"
        XAppDelegate.mobilePlatform.platformNotiff.sendTo(recieverIdString, withRoute: routeString, withAlert: alert, withRef: "send_heart", withPush: 0, withData: "data") { (result) -> Void in
            print("sendHeartServerNotification result = \(result)")
        }
    }
    
    func sendFollowNotification(receiverId : Int) {
        let alert = Alert()
        alert.title = "Follow"
        let currentUser = XAppDelegate.currentUser
        alert.body = "\(currentUser.name) followed you"
        alert.imageURL = "\(currentUser.imgURL)"
        alert.priority = 5
        alert.type = "follow"
        
        let receiverIdString = "\(receiverId)"
        let route = "/profile/\(currentUser.uid)/feed"
        XAppDelegate.mobilePlatform.platformNotiff.sendTo(receiverIdString, withRoute: route, withAlert: alert, withRef: "follow", withPush: 0, withData: "data") { (result) -> Void in
        }
    }
    
    func getAllNotification(since : Int, completionHandler:(result : [NotificationObject]?) -> Void ){
        
        CacheManager.cacheGetNotification { (result) -> Void in
            if let result = result {
                let resultArray = result 
                completionHandler(result: resultArray)
            } else {
                let resultArray = [NotificationObject]()
                completionHandler(result: resultArray)
            }
        }
    }
    
    func clearAllNotification(array : [NotificationObject]){
        var listIds = [String]()
        for notification in array {
            listIds.append(notification.notification_id)
        }
        XAppDelegate.mobilePlatform.platformNotiff.clearWithListID(listIds, andCompleteBlock: { (result) -> Void in
//            print("clearAllNotification result = \(result)")
        })
        CacheManager.clearAllNotificationData()
    }
    
    // MARK: Helpers
    func isNotLoggedInFacebookFirstTime() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(isNotLoggedInFacebookFirstTimeKey)
    }
    
    func getCurrentUserFollowProfile(method: String, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        XAppDelegate.mobilePlatform.sc.sendRequest(method, withLoginRequired: REQUIRED, andPostData: nil) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
//                println("getCurrentUserFollowProfile == \(response)")
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
    
    func getOtherUserFollowProfile(uid: Int, page: Int = 0, method: String, completionHandler: (result: ([UserProfile], isLastPage: Bool)?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid")
        postData.setObject("\(page)", forKey: "page")
        let expiredTime = NSDate().timeIntervalSince1970 + 600
        
        // need to expire next page if current page is expired
        let expiredPostData = NSMutableDictionary()
        let expiredPageString = String(format:"%d",(page + 1))
        expiredPostData.setObject(expiredPageString, forKey: "page")
        expiredPostData.setObject("\(uid)", forKey: "uid")
        let expiredKey = Utilities.getKeyFromUrlAndPostData(method, postData: expiredPostData)
        
        CacheManager.cacheGet(method, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: expiredKey) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response!)
                let profiles: [UserProfile] = Array(Utilities.parseUsersArray(json["profiles"] as! Dictionary<String, AnyObject>).values)
                let last = json["last"] as! Int
                let result = (profiles, last == 1)
                completionHandler(result: result, error: nil)
            }
        }
    }
    
    private func getProfile(usersId: [Int],ignoreCache : Bool = false, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        let usersIdString = usersId.map({"\($0)"})
        let separator = ","
        self.getProfile(usersIdString.joinWithSeparator(separator),ignoreCache: ignoreCache, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
            }
        })
    }
    
    func persistUserProfile(ignoreCache : Bool = false, completionHandler: (error: NSError?) -> Void) {
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
        self.getProfile("\(uid)",ignoreCache : ignoreCache, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(error: error)
            } else {
                if let userProfile = result?[0]{
                    
                    XAppDelegate.currentUser = userProfile
                    print("persistUserProfile XAppDelegate.currentUser == \(XAppDelegate.currentUser)")
                    NSKeyedArchiver.archiveRootObject(userProfile, toFile: UserProfile.filePath)
                    completionHandler(error: nil)
                } else {
                    print("Cannot save userProfile!!")
                    completionHandler(error: nil)
                }
                
            }
        })
    }
    
    func retrieveFriendList(completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject(FACEBOOK_APP_ID, forKey: "app_id")
        _ = XAppDelegate.mobilePlatform.tracker.getDeviceInfo()
        if(isLoggedInFacebook()){
            postData.setObject(FBSDKAccessToken.currentAccessToken().tokenString, forKey: "access_token")
        }
        let expiredTime = NSDate().timeIntervalSince1970 + 600
        CacheManager.cacheGet(GET_FRIEND_LIST, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: nil) { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(result!)
                var userArray = [UserProfile]()
                if let profiles = result["profiles"] as? Dictionary<String, AnyObject>{
                    let userDict = Utilities.parseUsersArray(profiles)
                    for (_, user) in userDict {
                        userArray.append(user)
                    }
                }
                completionHandler(result: userArray, error: nil)
            }
        }
    }
    
    func retrieveUsersWhoLikedPost(postId : String, page: Int, completionHandler: (result: ([UserProfile], isLastPage: Bool)?, error: String) -> Void) {
        
        let postData = NSMutableDictionary()
        postData.setObject(postId, forKey: "post_id")
        postData.setObject("\(page)", forKey: "page")
        let expiredTime = NSDate().timeIntervalSince1970 + 10
        CacheManager.cacheGet(GET_LIKED_USERS, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: nil, ignoreCache: true) { (result, error) -> Void in
            if let _ = error {
                completionHandler(result: nil, error: "Network Error")
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(result!)
                if result["error"] as! Int == 1 {
                    completionHandler(result: nil, error: result["error_message"] as! String)
                } else {
                    var userArray = [UserProfile]()
                    let profiles = result["profiles"] as! Dictionary<String, AnyObject>
                    let last = result["last"] as! Int
                    let profileIDArray = result["hearts"] as! [Int]
                    let userDict = Utilities.parseUsersArray(profiles)
                    // sort userdict following server profileIDArray
                    for userId in profileIDArray {
                        for (keyId, userProfile) in userDict {
                            if keyId == "\(userId)" {
                                userArray.append(userProfile)
                            }
                        }
                    }
                    let result = (userArray, isLastPage: last == 1)
                    completionHandler(result: result, error: "")
                }
                
                
            }
        }
    }
}