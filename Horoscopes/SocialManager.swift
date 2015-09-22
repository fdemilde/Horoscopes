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
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        postData.setObject(uid, forKey: "uid")

        XAppDelegate.mobilePlatform.sc.sendRequest(GET_USER_FEED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                print("Error when get getUserNewsfeed = \(error)")
            } else {
//                println("getUserNewsfeed response = \(response)")
            }
            
        })
    }
    
    func getGlobalNewsfeed(pageNo : Int, isAddingData : Bool){
        if(XAppDelegate.dataStore.newsfeedGlobal.count == 0){
            Utilities.showHUD()
        }
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_GLOBAL_FEED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            Utilities.hideHUD()
            if(error != nil){
                print("Error when get getGlobalNewsfeed = \(error)")
                Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
            } else {
                var result = Utilities.parseNSDictionaryToDictionary(response)
//                println("getGlobalNewsfeed result = \(result)")
                let errorCode = result["error"] as! Int
                if(errorCode != 0){
                    print("Error code = \(errorCode)")
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
                } else { // no error
//                    println("result == \(result)")
                    let userDict = result["users"] as! Dictionary<String, AnyObject>
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
            
        })
    }
    
    func getFollowingNewsfeed(pageNo : Int, isAddingData : Bool){
        if(XAppDelegate.dataStore.newsfeedFollowing.count == 0){
            Utilities.showHUD()
        }
        
        let postData = NSMutableDictionary()
        let pageString = String(format:"%d",pageNo)
        postData.setObject(pageString, forKey: "page")
        // change to test  GET_FOLLOWING_FEED
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_FOLLOWING_FEED,withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            Utilities.hideHUD()
            if(error != nil){
                print("Error when get getFollowingNewsfeed = \(error)")
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
            } else {
//                print("getFollowingNewsfeed == \(response)")
                var result = Utilities.parseNSDictionaryToDictionary(response)
//                println("result when get getFollowingNewsfeed = \(result)")
                let errorCode = result["error"] as! Int
                if(errorCode != 0){
                    print("Error code = \(errorCode)")
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                } else { // no error
                    let userDict = result["users"] as! Dictionary<String, AnyObject>
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
            
        })
    }
    
    func sendHeart(receiverId: Int, postId : String, type : String){
        let postData = NSMutableDictionary()
        postData.setObject(postId, forKey: "post_id")
        postData.setObject(type, forKey: "type")
        Utilities.showHUD()
        XAppDelegate.mobilePlatform.sc.sendRequest(SEND_HEART,withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                print("Error when get sendHeart = \(error)")
                Utilities.hideHUD()
            } else {
                var result = Utilities.parseNSDictionaryToDictionary(response)
                let errorCode = result["error"] as! Int
                if(errorCode != 0){
                    print("Error code = \(errorCode)")
                    Utilities.hideHUD()
                    Utilities.showAlertView(self, title: "Error", message: "Please try again later!")
                } else { // no error
                    let success = result["success"] as! Int
                    if success == 1 {
                        self.sendHeartServerNotification(receiverId, postId: postId)
                        Utilities.postNotification(NOTIFICATION_SEND_HEART_FINISHED, object: postId)
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: postId)
                    } else {
                        print("Post unsuccessful")
                    }
                    Utilities.hideHUD()
                }
            }
        })
    }
    
    // MARK: Post

    func createPost(type: String, message: String, completionHandler: (result: [String: AnyObject]?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
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
    
    func getUserFeed(uid: Int, page: Int = 0, completionHandler: (result: ([UserPost], isLastPage: Bool)?, error: NSError?) -> Void) {
        getProfile("\(uid)", completionHandler: { (result, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let userProfile = result![0]
                let postData = NSMutableDictionary()
                postData.setObject("\(page)", forKey: "page")
                postData.setObject("\(uid)", forKey: "uid")
                
                XAppDelegate.mobilePlatform.sc.sendRequest(GET_USER_FEED, withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response, error) -> Void in
                    if let error = error {
                        completionHandler(result: nil, error: error)
                    } else {
                        let json = Utilities.parseNSDictionaryToDictionary(response)
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
            }
        })
    }
    
    // get post with post ids string
    func getPost(postIds : String, completionHandler: (result: [UserPost]?, error: NSError?) -> Void){
        let postData = NSMutableDictionary()
        postData.setObject("\(postIds)", forKey: "post_id")
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_POST, withLoginRequired: REQUIRED, andPostData: postData, andCompleteBlock: { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                
                let results = Utilities.parseNSDictionaryToDictionary(response)
                let userDict = results["users"] as! Dictionary<String, AnyObject>
                let postsDict = results["posts"] as! Dictionary<String, AnyObject>
                var postArray = [AnyObject]()
                for (_,post) in postsDict {
                    postArray.append(post)
                }
                let feedsArray = Utilities.parseFeedsArray(userDict, postsDataArray: postArray)
                completionHandler(result: feedsArray, error: nil)
                
                
            }
        })
    }
    
    // MARK: Profile
    
    func getProfileCounts(usersId: [Int], completionHandler: (result: [UserProfileCounts]?, error: NSError?) -> Void) {
        let usersIdString = usersId.map({ String($0) }).joinWithSeparator(",")
        let postData = NSMutableDictionary()
        postData.setObject(usersIdString, forKey: "uid")
        XAppDelegate.mobilePlatform.sc.sendRequest(GET_PROFILE_COUNTS, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response)
                print(json)
            }
        }
    }
    
    func follow(uid: Int, completionHandler: (error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid")
        XAppDelegate.mobilePlatform.sc.sendRequest(FOLLOW, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(error: error)
            } else {
                SocialManager.sharedInstance.sendFollowNotification(uid)
                completionHandler(error: nil)
            }
        }
    }
    
    func unfollow(uid: Int, completionHandler: (error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
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
    
    func getProfile(usersIdString: String, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
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
    
    func loginFacebook(completionHandler: (error: NSError?, permissionGranted: Bool) -> Void) {
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email", "user_birthday","user_friends"]
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
        let objects = ["facebook", FACEBOOK_APP_ID, token]
        let keys = ["login_method", "app_id", "access_token"]
        let params = NSMutableDictionary(objects: objects, forKeys: keys)
        XAppDelegate.mobilePlatform.userModule.loginWithParams(params, andCompleteBlock: { (responseDict, error) -> Void in
            if let error = error {
                completionHandler(responseDict: nil, error: error)
            } else {
                XAppDelegate.locationManager.setupLocationService()
                self.persistUserProfile({ (error) -> Void in
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
        
        let postData = NSMutableDictionary()
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
        
        XAppDelegate.mobilePlatform.sc.sendRequest(REGISTER_SERVER_NOTIFICATION_TOKEN, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            print("registerServerNotificationToken == \(response)")
            let success = response["success"] as! Int
            if(success == 1){
                print("registerServerNotificationToken successful")
            } else {
                print("registerServerNotificationToken failed")
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
            print("sendFollowNotification result \(result)")
        }
    }
    
    func getAllNotification(since : Int, completionHandler:(result : [NotificationObject]?) -> Void ){
        XAppDelegate.mobilePlatform.platformNotiff.getAllwithSince(Int32(since), andCompleteBlock: { (result) -> Void in
            let resultArray = result as AnyObject as! [NotificationObject]
            completionHandler(result: resultArray)
        })
    }
    
    func clearAllNotification(){
        var listIds = [String]()
        listIds.append("67_8")
        XAppDelegate.mobilePlatform.platformNotiff.clearWithListID(listIds, andCompleteBlock: { (result) -> Void in
            print("clearAllNotification result = \(result)")
        })
    }
    
    // MARK: Helpers
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
    
    func getOtherUserFollowProfile(uid: Int, page: Int = 0, method: String, completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject("\(uid)", forKey: "uid")
        postData.setObject("\(page)", forKey: "page")
        XAppDelegate.mobilePlatform.sc.sendRequest(method, withLoginRequired: REQUIRED, andPostData: postData) { (response, error) -> Void in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let json = Utilities.parseNSDictionaryToDictionary(response)
                let profiles: [UserProfile] = Array(Utilities.parseUsersArray(json["profiles"] as! Dictionary<String, AnyObject>).values)
                completionHandler(result: profiles, error: nil)
            }
        }
    }
    
    private func getProfile(usersId: [Int], completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        let usersIdString = usersId.map({"\($0)"})
        let separator = ","
        self.getProfile(usersIdString.joinWithSeparator(separator), completionHandler: { (result, error) -> Void in
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
    
    func retrieveFriendList(completionHandler: (result: [UserProfile]?, error: NSError?) -> Void) {
        let postData = NSMutableDictionary()
        postData.setObject(FACEBOOK_APP_ID, forKey: "app_id")
        _ = XAppDelegate.mobilePlatform.tracker.getDeviceInfo()
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
                    let userDict = Utilities.parseUsersArray(profiles)
                    for (_, user) in userDict {
                        userArray.append(user)
                    }
                }
                completionHandler(result: userArray, error: nil)
            }
        })
    }
}