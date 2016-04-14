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
    var currentCookieShareLink = ""
    var previousPostMessage = ""
    
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
    
    func updateData(data : [UserPost], type: NewsfeedTabType, scrollToTop : Bool = false){
        newsfeedIsUpdated = false // reset updated flag to false
        self.isLastPage = false // reset
        var updatedArray = [UserPost]()
        switch type {
            case NewsfeedTabType.Following:
                updatedArray = data
                updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray)
            case NewsfeedTabType.Global:
                updatedArray = data
                updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
                Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: updatedArray)
            default:
                updatedArray = data
                updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray)
        }
        if(scrollToTop){
            Utilities.postNotification(NOTIFICATION_TABLE_VIEW_SCROLL_TO_TOP, object:nil)
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
                mutableOldArray.append(newDataArray[index])
            }
        }
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
    
    func checkFollowStatus(users: [UserProfile], completionHandler: (error: NSError?, shouldReload: Bool) -> Void) {
        var shouldReload = false
        let check = {
            for user in users {
                var unfollow = true
                if user.isFollowed {
                    unfollow = false
                }
                for userFollowing in self.usersFollowing! {
                    if user.uid == userFollowing.uid {
                        if !shouldReload {
                            shouldReload = !user.isFollowed
                        }
                        unfollow = true
                        user.isFollowed = true
                        break
                    }
                }
                if !unfollow {
                    user.isFollowed = false
                    shouldReload = true
                }
            }
        }
        if usersFollowing != nil {
            check()
            completionHandler(error: nil, shouldReload: shouldReload)
        } else {
            SocialManager.sharedInstance.getProfilesOfUsersFollowing({ (result, error) -> Void in
                if let error = error {
                    completionHandler(error: error, shouldReload: shouldReload)
                } else {
                    self.usersFollowing = result!
                    check()
                    completionHandler(error: nil, shouldReload: shouldReload)
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
        do {
            try fileManager.removeItemAtPath(UserProfile.filePath)
        } catch {
            
        }
        NSUserDefaults.standardUserDefaults().removeObjectForKey(notificationKey)
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

