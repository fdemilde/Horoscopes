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
    @objc optional func facebookLoginFinished(_ result : [AnyHashable: Any]?, error : NSError?)
    @objc optional func facebookLoginTokenExists(_ token : FBSDKAccessToken)
    @objc optional func reloadView(_ result : [AnyHashable: Any]?, error : NSError?)
}

class SocialManager: NSObject, UIAlertViewDelegate {

    
//    var globalFeeds = []
    static let sharedInstance = SocialManager()
    
    var delegate : SocialManagerDelegate!
    
    override init(){
        
    }
    
    // MARK: Network - Newsfeed
    
    fileprivate func expiredKeyForPaging (_ isRefreshed: Bool, pageKey: String, requestMethod: String, pageNumber: Int, postData: NSMutableDictionary) -> String {
        let expiredPostData = postData.mutableCopy() as! NSMutableDictionary
        var expiredPageString = ""
        var expiredKey = ""
        if isRefreshed { // force refresh right away, used at Pull-to-refresh
            expiredPageString = String(format:"%d", 0)
            expiredPostData.setObject(expiredPageString, forKey: pageKey as NSCopying)
            expiredKey = Utilities.getKeyFromUrlAndPostData(requestMethod, postData: expiredPostData)
            CacheManager.cacheExpire(expiredKey)
            expiredKey = ""
        }
        expiredPageString = String(format:"%d",(pageNumber + 1))
        expiredPostData.setObject(expiredPageString, forKey: pageKey as NSCopying)
        expiredKey = Utilities.getKeyFromUrlAndPostData(requestMethod, postData: expiredPostData)
        return expiredKey
    }
    
    func getGlobalNewsfeed(_ pageNo : Int, isAddingData : Bool, isRefreshing: Bool = false, ignoreCache : Bool = false){
        if(XAppDelegate.dataStore.newsfeedGlobal.count == 0){
            let haveShownWelcome = UserDefaults.standard.bool(forKey: HAVE_SHOWN_WELCOME_SCREEN)
            if(haveShownWelcome){
                Utilities.showHUD()
            }
        }
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page" as NSCopying)
        let expiredTime = Date().timeIntervalSince1970 + 600
        
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
                    let userDict = result["profiles"] as! Dictionary<String, AnyObject>
                    let postsArray = result["posts"] as! [AnyObject]
                    let isLastAsNumber = result["last"] as! Int
                    let feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postsArray)
                    
                    if (isLastPage: Bool(isLastAsNumber == 1)) {
                        
                        XAppDelegate.dataStore.addDataArray(feedsArray, type: NewsfeedTabType.global, isLastPage: Bool(true))
                    } else {
                        
                        // because each time user goes to Community page, we have to check if it should reload or not
                        // this part is for checking that if the cache is not expired, we do nothing so data will not be touched
                        // ignore this part on first load since data needs to be initialize
                        if (XAppDelegate.dataStore.newsfeedGlobal.count != 0 && !CacheManager.isCacheExpired(GET_GLOBAL_FEED, postData: postData)) {
                            return
                        }
                        let scrollToTop = pageNo == 0 ? true : false
                        XAppDelegate.dataStore.updateData(feedsArray, type: NewsfeedTabType.global,scrollToTop : scrollToTop)
                    }
                }
            }
        }
    }
    
    func getFollowingNewsfeed(_ pageNo : Int, isAddingData : Bool, isRefreshing: Bool = false){
        if(XAppDelegate.dataStore.newsfeedFollowing.count == 0){
            Utilities.showHUD()
        }
        
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page" as NSCopying)
        // change to test  GET_FOLLOWING_FEED
        let expiredTime = Date().timeIntervalSince1970 + 600
        
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
                        XAppDelegate.dataStore.addDataArray(feedsArray, type: NewsfeedTabType.following, isLastPage: Bool(isLastAsNumber))
                    } else {
                        XAppDelegate.dataStore.updateData(feedsArray, type: NewsfeedTabType.following)
                    }
                }
            }
        }
    }
    
    func sendHeart(_ receiverId: Int, postId : String, type : String){
        let postData = NSMutableDictionary()
        postData.setObject(postId, forKey: "post_id" as NSCopying)
        postData.setObject(type, forKey: "type" as NSCopying)
        XAppDelegate.mobilePlatform.sc.sendRequest(SEND_HEART,withLoginRequired: REQUIRED, andPostData: postData, andComplete: { (response,error) -> Void in
            if(error != nil){
                print("Error when get sendHeart = \(error)")
            } else {
                var result = Utilities.parseNSDictionaryToDictionary(response)
                if let errorCode = result["error"] as? Int {
                    if(errorCode != 0){
                        print("Error code = \(errorCode)")
                        Utilities.showError(error as! NSError)
                    } else { // no error
                        if let errorCode = response?["error_code"]{
                            if(errorCode as? String == "error.invalidtoken"){
                                XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                                return
                            }
                        }
                        if let success = result["success"] as? Int {
                            if success == 1 {
                                //                        self.sendHeartServerNotification(receiverId, postId: postId)
                                //                        Utilities.postNotification(NOTIFICATION_SEND_HEART_FINISHED, object: postId)
                                UserDefaults.standard.set(true, forKey: postId)
                            } else {
                                print("Post unsuccessful")
                            }
                        }
                        
                    }
                }
                
            }
        })
    }
    
    // MARK: Post

    func createPost(_ type: String, message: String, postToFacebook : Bool = false, completionHandler: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject(type, forKey: "type" as NSCopying)
        postData.setObject(message, forKey: "message" as NSCopying)
        if(postToFacebook){
            postData.setObject("1", forKey: "post_to_facebook" as NSCopying)
            postData.setObject(FACEBOOK_APP_ID, forKey: "app_id" as NSCopying)
            postData.setObject(FBSDKAccessToken .current().tokenString, forKey: "access_token" as NSCopying)
            
        }
        let createPost = { () -> () in
            XAppDelegate.mobilePlatform.sc.sendRequest(CREATE_POST, withLoginRequired: REQUIRED, andPostData: postData, andComplete: { (response, error) -> Void in
                if let error = error {
                    completionHandler(nil, error as NSError?)
                } else {
                    if let errorCode = response?["error_code"]{
                        if(errorCode as? String == "error.invalidtoken"){
                            XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                            return
                        }
                    }
                    let result = Utilities.parseNSDictionaryToDictionary(response)
                    completionHandler(result: result, error: nil)
                }
            })
        }
        
        if isLoggedInZwigglers() {
            createPost()
        } else {
            if(FBSDKAccessToken.current() != nil){
                loginZwigglers(FBSDKAccessToken.current().tokenString, completionHandler: { (responseDict, error) -> Void in
                    if let error = error {
                        completionHandler(nil, error)
                    } else {
                        createPost()
                    }
                })
            }
            
        }
    }
    
    func getUserFeed(_ uid: Int, page: Int = 0, isRefreshed: Bool = false, completionHandler: @escaping (_ result: ([UserPost], isLastPage: Bool)?, _ error: NSError?) -> Void) {
        getProfile("\(uid)",ignoreCache : false, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let userProfile = result?[0]{
                    let postData = NSMutableDictionary()
                    postData.setObject("\(page)", forKey: "page" as NSCopying)
                    postData.setObject("\(uid)", forKey: "uid" as NSCopying)
                    let expiredTime = Date().timeIntervalSince1970 + 600
                    
                    // need to expire next page if current page is expired
                    let expiredKey = self.expiredKeyForPaging(isRefreshed, pageKey: "page", requestMethod: GET_USER_FEED, pageNumber: page, postData: postData)
                    CacheManager.cacheGet(GET_USER_FEED, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: expiredKey, completionHandler: { (response, error) -> Void in
                        if let error = error {
                            completionHandler(nil, error)
                        } else {
                            let json = Utilities.parseNSDictionaryToDictionary(response!)
                            let last = json["last"] as! Int
                            let results = json["posts"] as! [NSDictionary]
                            let posts = UserPost.postsFromResults(results)
                            for post in posts {
                                post.user = userProfile
                            }
                            let result = (posts, isLastPage: last == 1)
                            completionHandler(result, nil)
                        }
                    })
                } else {
                    print("Cannot save getUserFeed!!")
                    completionHandler(nil, error)
                }
            }
        })
    }
    
    // get post with post ids string
    func getPost(_ postIds : String, ignoreCache: Bool = false, completionHandler: @escaping (_ result: [UserPost]?, _ error: NSError?) -> Void){
        let postData = NSMutableDictionary()
        postData.setObject("\(postIds)", forKey: "post_id" as NSCopying)
        let expiredTime = Date().timeIntervalSince1970 + 600
        CacheManager.cacheGet(GET_POST, postData: postData, loginRequired: OPTIONAL, expiredTime: expiredTime, forceExpiredKey: nil, ignoreCache: ignoreCache) { (response, error) -> Void in
//            print("response response == \(response)")
            if let error = error {
                completionHandler(nil, error)
            } else {
                let results = Utilities.parseNSDictionaryToDictionary(response!)
                let userDict = results["profiles"] as! Dictionary<String, AnyObject>
                let postsDict = results["posts"] as! Dictionary<String, AnyObject>
                var postArray = [AnyObject]()
                for (_,post) in postsDict {
                    postArray.append(post)
                }
                let feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postArray)
                completionHandler(feedsArray, nil)
            }
        }
    }
    
    // MARK: Profile
    
    func getProfileCounts(_ usersId: [Int], completionHandler: @escaping (_ result: [UserProfileCounts]?, _ error: NSError?) -> Void) {
        let usersIdString = usersId.map({ String($0) }).joined(separator: ",")
        let postData = NSMutableDictionary()
        postData.setObject(usersIdString, forKey: "uid" as NSCopying)
        let expiredTime = Date().timeIntervalSince1970 + 600
        CacheManager.cacheGet(GET_PROFILE_COUNTS, postData: postData, loginRequired: OPTIONAL, expiredTime: expiredTime, forceExpiredKey: nil) { (response, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response!)
                var result = [UserProfileCounts]()
                if let dictionary = json["counts"] as? [String: AnyObject] {
                    for count in dictionary.values {
                        result.append(UserProfileCounts(dictionary: count as! [String : AnyObject]))
                    }
                    completionHandler(result, nil)
                }
            }
        }
    }
    
    func follow(_ user: UserProfile, completionHandler: @escaping (_ error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(user.uid)", forKey: "uid" as NSCopying)
        XAppDelegate.mobilePlatform.sc.sendRequest(FOLLOW, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(error as NSError?)
            } else {
                if let errorCode = response?["error_code"]{
                    if(errorCode as? String == "error.invalidtoken"){
                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                        return
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_FOLLOW), object: user)
                })
//                SocialManager.sharedInstance.sendFollowNotification(user.uid)
                completionHandler(nil)
            }
        }
    }
    
    func unfollow(_ user: UserProfile, completionHandler: @escaping (_ error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(user.uid)", forKey: "uid" as NSCopying)
        XAppDelegate.mobilePlatform.sc.sendRequest(UNFOLLOW, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(error as NSError?)
            } else {
                if let errorCode = response?["error_code"]{
                    if(errorCode as? String == "error.invalidtoken"){
                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                        return
                    }
                }
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_UNFOLLOW), object: user)
                })
                completionHandler(nil)
            }
        }
    }
    
    func isFollowing(_ uid: Int, followerId: Int, completionHandler: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid" as NSCopying)
        postData.setObject("\(followerId)", forKey: "follower" as NSCopying)
        XAppDelegate.mobilePlatform.sc.sendRequest(IS_FOLLOWING, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(nil, error as NSError?)
            } else {
                if let errorCode = response?["error_code"]{
                    if(errorCode as? String == "error.invalidtoken"){
                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                        return
                    }
                }
                let result = Utilities.parseNSDictionaryToDictionary(response)
                completionHandler(result: result, error: nil)
            }
        }
    }
    
    func getProfile(_ usersIdString: String, ignoreCache : Bool = false, completionHandler: @escaping (_ result: [UserProfile]?, _ error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject(usersIdString, forKey: "uid" as NSCopying)
        let longExpiredTime = Date().timeIntervalSince1970 + 86400
        CacheManager.cacheGet(GET_PROFILE, postData: postData, loginRequired: OPTIONAL, expiredTime: longExpiredTime, forceExpiredKey: nil, ignoreCache : ignoreCache) { (response, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let response = response {
                    let json = Utilities.parseNSDictionaryToDictionary(response)
                    var result = [UserProfile]()
                    for userId in usersIdString.components(separatedBy: ",") {
                        if let users = json["profiles"] as? Dictionary<String, AnyObject> {
                            let userProfile = UserProfile(data: users[userId] as! NSDictionary)
                            result.append(userProfile)
                        }
                    }
                    completionHandler(result, nil)
                }
                
            }
        }
    }
    
    func getProfilesOfUsersFollowing(_ completionHandler: @escaping (_ result: [UserProfile]?, _ error: NSError?) -> Void) {
        getCurrentUserFollowProfile(GET_CURRENT_USER_FOLLOWING, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(result, nil)
            }
        })
    }
    
    func getProfilesOfFollowers(_ completionHandler: @escaping (_ result: [UserProfile]?, _ error: NSError?) -> Void) {
        getCurrentUserFollowProfile(GET_CURRENT_USER_FOLLOWERS, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(result, nil)
            }
        })
    }
    
    func getProfilesOfUsersFollowing(forUser uid: Int, page: Int = 0, completionHandler: @escaping (_ result: ([UserProfile], isLastPage: Bool)?, _ error: NSError?) -> Void) {
        getOtherUserFollowProfile(uid, page: page, method: GET_OTHER_USER_FOLLOWING) { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(result, nil)
            }
        }
    }
    
    func getProfilesOfFollowers(forUser uid: Int, page: Int = 0, completionHandler: @escaping (_ result: ([UserProfile], isLastPage: Bool)?, _ error: NSError?) -> Void) {
        getOtherUserFollowProfile(uid, page: page, method: GET_OTHER_USER_FOLLOWERS) { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(result, nil)
            }
        }
    }
    
    // MARK: Network - Report Issue
    
    func reportIssue(_ message : String, completionHandler: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void){
        
        let postData = NSMutableDictionary()
        postData.setObject(message, forKey: "user_message" as NSCopying)
        let systemMessage = XAppDelegate.mobilePlatform.tracker.getDeviceInfo()
        postData.setObject(systemMessage, forKey: "system_message" as NSCopying)
        
        XAppDelegate.mobilePlatform.sc.sendRequest(REPORT_ISSUE_METHOD, andPostData: postData) { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error as NSError?)
            } else {
                if let errorCode = result?["error_code"]{
                    if(errorCode as? String == "error.invalidtoken"){
                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                        return
                    }
                }
                let result = Utilities.parseNSDictionaryToDictionary(result)
                completionHandler(result: result, error: nil)
            }
        }
        
    }
    
    // MARK: Log in
    func isLoggedInFacebook() -> Bool{
        return FBSDKAccessToken .current() != nil
    }
    
    func loginFacebook(_ viewController: UIViewController, completionHandler: @escaping (_ error: NSError?, _ permissionGranted: Bool) -> Void) {
        
            let loginManager = FBSDKLoginManager()
            loginManager.loginBehavior = .systemAccount
            let permissions = ["public_profile", "email", "user_friends"]
            let permissionLabel = "permission = \(permissions)"
            XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginAsk, label: permissionLabel)
            
            loginManager.logIn(withReadPermissions: permissions, from: viewController) { (result, error) -> Void in
                if let error = error {
                    completionHandler(error as NSError?, false)
                } else {
                    if (result?.isCancelled)! {
                        completionHandler(nil, false)
                    } else {
                        let label = "granted = \(result?.grantedPermissions)"
                        XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginResult, label: label)
                        for permission in permissions {
                            if (result?.declinedPermissions.contains(permission))! {
                                completionHandler(nil, false)
                                return
                            }
                        }
                        completionHandler(nil, true)
                    }
                }
            }
    }
    
    func isLoggedInZwigglers() -> Bool{
        return XAppDelegate.mobilePlatform.userCred.hasToken()
    }
    
    func loginZwigglers(_ token: String, completionHandler: @escaping (_ responseDict: [AnyHashable: Any]?, _ error: NSError?) -> Void){
        Utilities.showHUD()
        let objects = ["facebook", FACEBOOK_APP_ID, token]
        let keys = ["login_method", "app_id", "access_token"]
        let params = NSMutableDictionary(objects: objects, forKeys: keys as [NSCopying])
        XAppDelegate.mobilePlatform.userModule.login(withParams: params, andComplete: { (responseDict, error) -> Void in
            Utilities.hideHUD()
            if let error = error {
                completionHandler(nil, error as NSError?)
            } else {
                self.persistUserProfile(completionHandler: { (error) -> Void in
                    if let error = error {
                        completionHandler(nil, error)
                    } else {
                        completionHandler(responseDict, nil)
                    }
                })
                
            }
        })
    }
    
    func logoutWhenRetrieveInvalidToken(){
        XAppDelegate.mobilePlatform.userCred.clear()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        XAppDelegate.socialManager.clearNotification()
        XAppDelegate.dataStore.clearData()
    }
    
    func logoutZwigglers(_ completionHandler: (_ responseDict: [AnyHashable: Any]?, _ error: NSError?) -> Void){
        XAppDelegate.mobilePlatform.userModule.logout { (result, error) -> Void in
            print("logoutZwigglers result == \(result)")
        }
    }
    
    // Convenience method that log in Facebook then log in Zwigglers
    func login(_ viewController: UIViewController, completionHandler: @escaping (_ error: NSError?, _ permissionGranted: Bool) -> Void) {
        loginFacebook(viewController) { (error, permissionGranted) -> Void in
            if let error = error {
                NSLog("loginFacebook ERROR = \(error)")
                let label = "success = 0"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginResult, label: label)
                completionHandler(error, false)
            } else {
                let label = "success = 1"
                XAppDelegate.sendTrackEventWithActionName(EventConfig.Event.fbLoginResult, label: label)
                if permissionGranted {
                    self.loginZwigglers(FBSDKAccessToken.current().tokenString, completionHandler: { (responseDict, error) -> Void in
                        Utilities.registerForRemoteNotification()
                        if let error = error {
                            completionHandler(error, false)
                        } else {
                            completionHandler(nil, true)
                            
                            XAppDelegate.lastGetAllNotificationsTs = 0
                            CacheManager.resetNotificationSinceTs()
                            // if user logs in Facebook first time.
                            if !UserDefaults.standard.bool(forKey: isNotLoggedInFacebookFirstTimeKey) {
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
                                                UserDefaults.standard.set(true, forKey: isNotLoggedInFacebookFirstTimeKey)
                                            }
                                        })
                                    } else {
                                        NSLog(" ko log in duoc")
                                    }
                                })
                            }
                            
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
                    completionHandler(nil, false)
                }
            }
        }
    }
    
    // MARK: Location
    
    func sendUserUpdateLocation(_ latlon : String, completionHandler: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void){
        let postData = NSMutableDictionary()
        postData.setObject(latlon, forKey: "latlon" as NSCopying)
        XAppDelegate.mobilePlatform.sc.sendRequest(SEND_USER_UPDATE, withLoginRequired: REQUIRED, andPostData: postData, andComplete: { (response, error) -> Void in
            if let error = error {
                completionHandler(nil, error as NSError?)
            } else {
                if let errorCode = response?["error_code"]{
                    if(errorCode as? String == "error.invalidtoken"){
                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                        return
                    }
                }
                let result = Utilities.parseNSDictionaryToDictionary(response)
                completionHandler(result: result, error: nil)
            }
        })
        
    }
    
    func sendUserUpdateSign(_ sign : Int?, completionHandler: @escaping (_ result: [String: AnyObject]?, _ error: NSError?) -> Void){
        var sign = sign
        let postData = NSMutableDictionary()
        if sign == nil {
            sign = 9
        }
        postData.setObject("\(sign!)", forKey: "sign" as NSCopying)
        XAppDelegate.mobilePlatform.sc.sendRequest(SEND_USER_UPDATE, withLoginRequired: REQUIRED, andPostData: postData, andComplete: { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error as NSError?)
            } else {
                if let errorCode = result?["error_code"]{
                    if(errorCode as? String == "error.invalidtoken"){
                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                        return
                    }
                }
                let result = Utilities.parseNSDictionaryToDictionary(result)
                completionHandler(result: result, error: nil)
            }
        })
        
    }
    
    // MARK: Server Notification
    
    func registerServerNotificationToken(_ token : String){
        let postData = NSMutableDictionary()
        postData.setObject(token, forKey: "device_token" as NSCopying)
        XAppDelegate.mobilePlatform.sc.sendRequest(REGISTER_SERVER_NOTIFICATION_TOKEN, andPostData: postData, andComplete: { (response,error) -> Void in
        })
    }
    
    func sendHeartServerNotification(_ receiverId : Int, postId : String){
        let alert = Alert()
        let currentUser = XAppDelegate.currentUser
        alert?.title = "Send heart"
        alert?.body = "\(currentUser?.name) sent you a heart"
        alert?.imageURL = "\(currentUser?.imgURL)"
        alert?.priority = 5
        alert?.type = "send_heart"
        
        let routeString = "/post/\(postId)/hearts"
        let recieverIdString = "\(receiverId)"
        XAppDelegate.mobilePlatform.platformNotiff.send(to: recieverIdString, withRoute: routeString, with: alert, withRef: "send_heart", withPush: 0, withData: "data") { (result) -> Void in
            print("sendHeartServerNotification result = \(result)")
        }
    }
    
    func sendFollowNotification(_ receiverId : Int) {
        let alert = Alert()
        alert?.title = "Follow"
        let currentUser = XAppDelegate.currentUser
        alert?.body = "\(currentUser?.name) followed you"
        alert?.imageURL = "\(currentUser?.imgURL)"
        alert?.priority = 5
        alert?.type = "follow"
        
        let receiverIdString = "\(receiverId)"
        let route = "/profile/\(currentUser?.uid)/feed"
        XAppDelegate.mobilePlatform.platformNotiff.send(to: receiverIdString, withRoute: route, with: alert, withRef: "follow", withPush: 0, withData: "data") { (result) -> Void in
        }
    }
    
    func getAllNotification(_ since : Int, completionHandler:@escaping (_ result : [NotificationObject]?) -> Void ){
        
        CacheManager.cacheGetNotification { (result) -> Void in
            if let result = result {
                let resultArray = result 
                completionHandler(resultArray)
            } else {
                let resultArray = [NotificationObject]()
                completionHandler(resultArray)
            }
        }
    }
    
    func clearAllNotification(_ array : [NotificationObject]){
        
        CacheManager.clearAllNotificationData()
    }
    
    func clearNotification(){
        if let notificationViewController = Utilities.getViewController(NotificationViewController.classForCoder()) {
            let notificationVC = notificationViewController as! NotificationViewController
            XAppDelegate.socialManager.clearAllNotification(notificationVC.notifArray)
        }
    }
    
    func clearNotificationWithId(_ notifId : String){
        XAppDelegate.mobilePlatform.platformNotiff.clear(withID: notifId) { (result) -> Void in
        }
    }
    
    // MARK: Helpers
    func isNotLoggedInFacebookFirstTime() -> Bool {
        return UserDefaults.standard.bool(forKey: isNotLoggedInFacebookFirstTimeKey)
    }
    
    func getCurrentUserFollowProfile(_ method: String, completionHandler: @escaping (_ result: [UserProfile]?, _ error: NSError?) -> Void) {
        XAppDelegate.mobilePlatform.sc.sendRequest(method, withLoginRequired: REQUIRED, andPostData: nil) { (response, error) -> Void in
            if let error = error {
                completionHandler(nil, error as NSError?)
            } else {
                if let errorCode = response?["error_code"]{
                    if(errorCode as? String == "error.invalidtoken"){
                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                        return
                    }
                }
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
                        completionHandler([UserProfile](), nil)
                    }
                }
            }
        }
    }
    
    func getOtherUserFollowProfile(_ uid: Int, page: Int = 0, method: String, completionHandler: @escaping (_ result: ([UserProfile], isLastPage: Bool)?, _ error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid" as NSCopying)
        postData.setObject("\(page)", forKey: "page" as NSCopying)
        let expiredTime = Date().timeIntervalSince1970 + 600
        
        // need to expire next page if current page is expired
        let expiredPostData = NSMutableDictionary()
        let expiredPageString = String(format:"%d",(page + 1))
        expiredPostData.setObject(expiredPageString, forKey: "page" as NSCopying)
        expiredPostData.setObject("\(uid)", forKey: "uid" as NSCopying)
        let expiredKey = Utilities.getKeyFromUrlAndPostData(method, postData: expiredPostData)
        
        CacheManager.cacheGet(method, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: expiredKey) { (response, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response!)
                let profiles: [UserProfile] = Array(Utilities.parseUsersArray(json["profiles"] as! Dictionary<String, AnyObject>).values)
                let last = json["last"] as! Int
                let result = (profiles, last == 1)
                completionHandler(result, nil)
            }
        }
    }
    
    fileprivate func getProfile(_ usersId: [Int],ignoreCache : Bool = false, completionHandler: @escaping (_ result: [UserProfile]?, _ error: NSError?) -> Void) {
        let usersIdString = usersId.map({"\($0)"})
        let separator = ","
        self.getProfile(usersIdString.joined(separator: separator),ignoreCache: ignoreCache, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                completionHandler(result, nil)
            }
        })
    }
    
    func persistUserProfile(_ ignoreCache : Bool = false, completionHandler: @escaping (_ error: NSError?) -> Void) {
        let uid = XAppDelegate.mobilePlatform.userCred.getUid()
        self.getProfile("\(uid)",ignoreCache : ignoreCache, completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(error)
            } else {
                if let userProfile = result?[0]{
                    
                    XAppDelegate.currentUser = userProfile
                    NSKeyedArchiver.archiveRootObject(userProfile, toFile: UserProfile.filePath)
                    completionHandler(nil)
                } else {
                    print("Cannot save userProfile!!")
                    completionHandler(nil)
                }
                
            }
        })
    }
    
    func retrieveFriendList(_ completionHandler: @escaping (_ result: [UserProfile]?, _ error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject(FACEBOOK_APP_ID, forKey: "app_id" as NSCopying)
        _ = XAppDelegate.mobilePlatform.tracker.getDeviceInfo()
        if(isLoggedInFacebook()){
            postData.setObject(FBSDKAccessToken.current().tokenString, forKey: "access_token" as NSCopying)
        }
        let expiredTime = Date().timeIntervalSince1970 + 600
        CacheManager.cacheGet(GET_FRIEND_LIST, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: nil) { (result, error) -> Void in
            if let error = error {
                completionHandler(nil, error)
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(result!)
                var userArray = [UserProfile]()
                if let profiles = result["profiles"] as? Dictionary<String, AnyObject>{
                    let userDict = Utilities.parseUsersArray(profiles)
                    for (_, user) in userDict {
                        userArray.append(user)
                    }
                }
                completionHandler(userArray, nil)
            }
        }
    }
    
    func retrieveUsersWhoLikedPost(_ postId : String, page: Int, completionHandler: @escaping (_ result: ([UserProfile], isLastPage: Bool)?, _ error: String) -> Void) {
        
        let postData = NSMutableDictionary()
        postData.setObject(postId, forKey: "post_id" as NSCopying)
        postData.setObject("\(page)", forKey: "page" as NSCopying)
        let expiredTime = Date().timeIntervalSince1970 + 10
        CacheManager.cacheGet(GET_LIKED_USERS, postData: postData, loginRequired: REQUIRED, expiredTime: expiredTime, forceExpiredKey: nil, ignoreCache: true) { (result, error) -> Void in
            if let _ = error {
                completionHandler(nil, "Network Error")
            } else {
                let result = Utilities.parseNSDictionaryToDictionary(result!)
                if result["error"] as! Int == 1 {
                    completionHandler(nil, result["error_message"] as! String)
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
                    completionHandler(result, "")
                }
                
                
            }
        }
    }
    
    // MARK: Share
    
    func registerShare(_ type : ShareType, postId : String? = "", timetag : TimeInterval? = 0, sign : Int? = 0, fortuneId : Int? = 0, completionHandler: @escaping (_ result: Dictionary<String,AnyObject>?, _ error: NSError?) -> Void ){
        let postData = NSMutableDictionary()
        switch type {
            case .shareTypeDaily:
                postData.setObject("horoscope", forKey: "type" as NSCopying)
                postData.setObject("\(timetag!)", forKey: "time_tag" as NSCopying)
                postData.setObject("\(sign!)", forKey: "sign" as NSCopying)
            case .shareTypeFortune:
                postData.setObject("fortune", forKey: "type" as NSCopying)
                postData.setObject("\(fortuneId!)", forKey: "fortune_id" as NSCopying)
            case .shareTypeNewsfeed:
                postData.setObject("userpost", forKey: "type" as NSCopying)
                postData.setObject("\(postId!)", forKey: "post_id" as NSCopying)
        }
        XAppDelegate.mobilePlatform.sc.sendRequest(REGISTER_SHARE, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(nil, error as NSError?)
            } else {
                if let errorCode = response?["error_code"]{
                    if(errorCode as? String == "error.invalidtoken"){
                        XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                        return
                    }
                }
                let result = Utilities.parseNSDictionaryToDictionary(response)
                completionHandler(result: result, error: nil)
            }
        }
    }
}
