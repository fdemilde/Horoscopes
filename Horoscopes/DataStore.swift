//
//  DataStore.swift
//  Horoscopes
//
//  Created by Binh Dang on 7/31/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class DataStore : NSObject{
    
    var newsfeedGlobal = [UserPost]()
    var newsfeedFollowing = [UserPost]()
    var newsfeedIsUpdated : Bool = false
    var usersFollowing: [UserProfile]?
    
    var recentSearchedProfile = [UserProfile]()
    var isLastPage = false
    var lastCookieOpenDate : NSDate!
    var currentFortuneDescription = ""
    var currentLuckyNumber = ""
    
    static let sharedInstance = DataStore()
    
    override init(){
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUsersFollowing:", name: NOTIFICATION_FOLLOW, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUsersUnfollowing:", name: NOTIFICATION_UNFOLLOW, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateUsersFollowing(notification: NSNotification) {
        let user = notification.object as! UserProfile
        if var _ = usersFollowing {
            usersFollowing!.append(user)
        } else {
            usersFollowing = [UserProfile]()
            usersFollowing!.append(user)
        }
        updateFollowingStatus(.Both)
    }
    
    func updateUsersUnfollowing(notification: NSNotification) {
        let user = notification.object as! UserProfile
        if var _ = usersFollowing {
            for var index = 0; index < usersFollowing!.count; ++index {
                if (usersFollowing![index].uid == user.uid){
                    usersFollowing!.removeAtIndex(index)
                    break
                }
            }
        }
        updateFollowingStatus(.Both)
    }
    
    func saveSearchedProfile(profile: UserProfile) {
        if recentSearchedProfile.filter({ $0.uid == profile.uid }).isEmpty {
            recentSearchedProfile.append(profile)
        }
    }
    
    func addDataArray(var data : [UserPost], type: NewsfeedTabType, isLastPage : Bool){
        newsfeedIsUpdated = false
        self.isLastPage = isLastPage
        var updatedArray = [UserPost]()
        switch type {
            case NewsfeedTabType.Following:
                if(data.count == 0){
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                    return // no new data
                }
                data = updateFollowingStatusForNewAddingData(data) // check with following users and update new adding post
                updatedArray = addData(newsfeedFollowing, newDataArray: data)
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray)
                }
            case NewsfeedTabType.Global:
                if(data.count == 0){
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
                    return // no new data
                }
                data = updateFollowingStatusForNewAddingData(data)
                updatedArray = addData(newsfeedGlobal, newDataArray: data)
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: updatedArray)
            
                }
            default:
                if(data.count == 0){
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                    return // no new data
                }
                data = updateFollowingStatusForNewAddingData(data)
                updatedArray = addData(newsfeedFollowing, newDataArray: data)
                if (newsfeedIsUpdated) {
                    
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray)
            }
            
        }
        
    }
    
    func updateData(data : [UserPost], type: NewsfeedTabType){
        newsfeedIsUpdated = false // reset updated flag to false
        self.isLastPage = false // reset
        var updatedArray = [UserPost]()
        switch type {
            case NewsfeedTabType.Following:
                if(newsfeedFollowing.count == 0){
                    newsfeedIsUpdated = true
                    updatedArray = data
                } else {
                    // do compare to update current newsfeed
                    updatedArray = self.checkAndUpdateFeedData(data, type: NewsfeedTabType.Following)
                }
//                updateFollowingStatus(type)
                updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray)
                }
            case NewsfeedTabType.Global:
                if(newsfeedGlobal.count == 0){
                    newsfeedIsUpdated = true
                    updatedArray = data
                } else {
                    // do compare to update current newsfeed
                    updatedArray = self.checkAndUpdateFeedData(data, type: NewsfeedTabType.Global)
                }
                updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: updatedArray)
                }
            default:
                if(newsfeedFollowing.count == 0){
                    newsfeedIsUpdated = true
                    updatedArray = data
                } else {
                    // do compare to update current newsfeed
                    updateFollowingStatus(NewsfeedTabType.Following)
                    updatedArray = self.checkAndUpdateFeedData(data, type: NewsfeedTabType.Following)
                }
                updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray)
                }
        }
        
    }
    
    func checkAndUpdateFeedData(newData : [UserPost], type : NewsfeedTabType) -> [UserPost]{
        var updatedArray = [UserPost]()
        switch type {
            case NewsfeedTabType.Following:
                updatedArray = compareAndUpdateArrayData(newsfeedFollowing, newDataArray: newData)
            case NewsfeedTabType.Global:
                updatedArray = compareAndUpdateArrayData(newsfeedGlobal, newDataArray: newData)
            default:
                updatedArray = compareAndUpdateArrayData(newsfeedFollowing, newDataArray: newData)
        }
        return updatedArray
    }
    
    // this function is for supporting paging, when table reaches the end we will add more contents to it
    func addData(oldDataArray : [UserPost], newDataArray : [UserPost])  -> [UserPost]{
        
        var mutableOldArray = oldDataArray
        let oldPostIDArray = self.parseUserPostDataIntoPostIdArray(oldDataArray)
        let newPostIDArray = self.parseUserPostDataIntoPostIdArray(newDataArray)
        // check if any new post, update old array with new items
        for (index,newPostId) in newPostIDArray.enumerate() {
            if !oldPostIDArray.contains(newPostId) {
                if(!newsfeedIsUpdated) { newsfeedIsUpdated = true }
                mutableOldArray.insert(newDataArray[index], atIndex: 0)
            }
        }
        
        // sort new data with post ts
        mutableOldArray.sortInPlace { $0.ts > $1.ts }
        return mutableOldArray
    }
    
    func resetPage(){
        isLastPage = false
    }
    
    // MARK: - Helpers
    
    func compareAndUpdateArrayData(oldDataArray : [UserPost], newDataArray : [UserPost]) -> [UserPost]{
        var removedArray = [UserPost]()
        var mutableOldArray = oldDataArray
        let oldPostIDArray = self.parseUserPostDataIntoPostIdArray(oldDataArray)
        let newPostIDArray = self.parseUserPostDataIntoPostIdArray(newDataArray)
        
        // loop through new Data array first and check with old data, if old data not exist in new data, remove it
        for (index,oldPostId) in oldPostIDArray.enumerate() {
            if !newPostIDArray.contains(oldPostId) {
                removedArray.append(oldDataArray[index])
            }
        }
        
        for post in removedArray {
            if(!newsfeedIsUpdated) { newsfeedIsUpdated = true }
            mutableOldArray.remove(post)
        }
        mutableOldArray = self.addData(mutableOldArray, newDataArray: newDataArray)
        return mutableOldArray
    }
    
    func parseUserPostDataIntoPostIdArray(array:[UserPost]) ->[String] {
        var result = [String]()
        for post in array {
            result.append(post.post_id)
        }
        return result
    }
    
    func updateFollowingStatus(type : NewsfeedTabType){
        if let _ = usersFollowing {
                if (type == .Following) {
                    updateFollowingForFollowingFeeds()
                } else if (type == .Global) {
                    updateFollowingForGlobalFeeds()
                } else {
                    updateFollowingForFollowingFeeds()
                    updateFollowingForGlobalFeeds()
                }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(NOTIFICATION_UPDATE_FOLLOWING_STATUS_FINISHED, object: nil)
        
    }
    
    func checkFollowStatus(users: [UserProfile], completionHandler: (error: NSError?) -> Void) {
        let check = {
            for user in users {
                for userFollowing in self.usersFollowing! {
                    if user.uid == userFollowing.uid {
                        user.isFollowed = true
                        break
                    }
                }
            }
        }
        if usersFollowing != nil {
            check()
            completionHandler(error: nil)
        } else {
            SocialManager.sharedInstance.getProfilesOfUsersFollowing({ (result, error) -> Void in
                if let error = error {
                    completionHandler(error: error)
                } else {
                    self.usersFollowing = result!
                    check()
                    completionHandler(error: nil)
                }
            })
        }
    }
    
    func updateFollowingForFollowingFeeds() {
        let users = newsfeedFollowing.map({$0.user!})
        checkFollowStatus(users) { (error) -> Void in
            
        }
    }
    
    func updateFollowingForGlobalFeeds() {
        let users = newsfeedGlobal.map({$0.user!})
        checkFollowStatus(users) { (error) -> Void in
            
        }
    }
    
    func updateFollowingStatusForNewAddingData(data : [UserPost]) -> [UserPost]{
        if let usersFollowing = usersFollowing {
            for user in usersFollowing{
                for feed in data{
                    if(user == feed.user!) {
                        feed.user!.isFollowed = true
                    }
                }
            }
        }
        return data
    }
    
    func clearData(){
        newsfeedFollowing = [UserPost]()
        recentSearchedProfile = [UserProfile]()
        XAppDelegate.currentUser = UserProfile()
        let fileManager = NSFileManager.defaultManager()
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        do {
            try fileManager.removeItemAtPath(UserProfile.filePath)
        } catch {
            
        }
    }
    
}

extension Array {
    mutating func remove<U: Equatable>(object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerate() {
            if let to = objectToCompare as? U {
                if object == to {
                    self.removeAtIndex(idx)
                    return true
                }
            }
        }
        return false
    }
}

