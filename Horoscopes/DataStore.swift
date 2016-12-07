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
    var userPostComments = [UserPostComment]()
    
    var recentSearchedProfile = [UserProfile]()
    var isLastPage = false
    var lastCookieOpenDate : Date!
    var currentFortuneDescription = ""
    var currentLuckyNumber = ""
    var currentCookieShareLink = ""
    var previousPostMessage = ""
    
    static let sharedInstance = DataStore()
    
    override init(){
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(DataStore.updateUsersFollowing(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_FOLLOW), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DataStore.updateUsersUnfollowing(_:)), name: NSNotification.Name(rawValue: NOTIFICATION_UNFOLLOW), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateUsersFollowing(_ notification: Notification) {
        let user = notification.object as! UserProfile
        if var _ = usersFollowing {
            usersFollowing!.append(user)
        } else {
            usersFollowing = [UserProfile]()
            usersFollowing!.append(user)
        }
        updateFollowingStatus(.both)
    }
    
    func updateUsersUnfollowing(_ notification: Notification) {
        let user = notification.object as! UserProfile
        if var _ = usersFollowing {
            for index in 0 ..< usersFollowing!.count {
                if (usersFollowing![index].uid == user.uid){
                    usersFollowing!.remove(at: index)
                    break
                }
            }
        }
        updateFollowingStatus(.both)
    }
    
    func saveSearchedProfile(_ profile: UserProfile) {
        if recentSearchedProfile.filter({ $0.uid == profile.uid }).isEmpty {
            recentSearchedProfile.append(profile)
        }
    }
    
    func addDataArray(_ data : [UserPost], type: NewsfeedTabType, isLastPage : Bool){
        var data = data
        newsfeedIsUpdated = false
        self.isLastPage = isLastPage
        var updatedArray = [UserPost]()
        switch type {
        case NewsfeedTabType.following:
            if(data.count == 0){
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                return // no new data
            }
            data = updateFollowingStatusForNewAddingData(data) // check with following users and update new adding post
            updatedArray = addData(newsfeedFollowing, newDataArray: data)
            if (newsfeedIsUpdated) {
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray as AnyObject?)
            }
        case NewsfeedTabType.global:
            if(data.count == 0){
                Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
                return // no new data
            }
            data = updateFollowingStatusForNewAddingData(data)
            updatedArray = addData(newsfeedGlobal, newDataArray: data)
            if (newsfeedIsUpdated) {
                Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: updatedArray as AnyObject?)
                
            }
        default:
            if(data.count == 0){
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                return // no new data
            }
            data = updateFollowingStatusForNewAddingData(data)
            updatedArray = addData(newsfeedFollowing, newDataArray: data)
            if (newsfeedIsUpdated) {
                
                Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray as AnyObject?)
            }
            
        }
        
    }
    
    func updateData(_ data : [UserPost], type: NewsfeedTabType, scrollToTop : Bool = false){
        newsfeedIsUpdated = false // reset updated flag to false
        self.isLastPage = false // reset
        var updatedArray = [UserPost]()
        switch type {
        case NewsfeedTabType.following:
            updatedArray = data
            updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
            Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray as AnyObject?)
        case NewsfeedTabType.global:
            updatedArray = data
            updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
            Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: updatedArray as AnyObject?)
        default:
            updatedArray = data
            updatedArray = updateFollowingStatusForNewAddingData(updatedArray)
            Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: updatedArray as AnyObject?)
        }
        if(scrollToTop){
            Utilities.postNotification(NOTIFICATION_TABLE_VIEW_SCROLL_TO_TOP, object:nil)
        }
    }
    
    func checkAndUpdateFeedData(_ newData : [UserPost], type : NewsfeedTabType) -> [UserPost]{
        var updatedArray = [UserPost]()
        switch type {
        case NewsfeedTabType.following:
            updatedArray = compareAndUpdateArrayData(newsfeedFollowing, newDataArray: newData)
        case NewsfeedTabType.global:
            updatedArray = compareAndUpdateArrayData(newsfeedGlobal, newDataArray: newData)
        default:
            updatedArray = compareAndUpdateArrayData(newsfeedFollowing, newDataArray: newData)
        }
        return updatedArray
    }
    
    // this function is for supporting paging, when table reaches the end we will add more contents to it
    func addData(_ oldDataArray : [UserPost], newDataArray : [UserPost])  -> [UserPost]{
        var mutableOldArray = oldDataArray
        let oldPostIDArray = self.parseUserPostDataIntoPostIdArray(oldDataArray)
        let newPostIDArray = self.parseUserPostDataIntoPostIdArray(newDataArray)
        // check if any new post, update old array with new items
        for (index,newPostId) in newPostIDArray.enumerated() {
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
    
    func compareAndUpdateArrayData(_ oldDataArray : [UserPost], newDataArray : [UserPost]) -> [UserPost]{
        var removedArray = [UserPost]()
        var mutableOldArray = oldDataArray
        let oldPostIDArray = self.parseUserPostDataIntoPostIdArray(oldDataArray)
        let newPostIDArray = self.parseUserPostDataIntoPostIdArray(newDataArray)
        
        // loop through new Data array first and check with old data, if old data not exist in new data, remove it
        for (index,oldPostId) in oldPostIDArray.enumerated() {
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
    
    func parseUserPostDataIntoPostIdArray(_ array:[UserPost]) ->[String] {
        var result = [String]()
        for post in array {
            result.append(post.post_id)
        }
        return result
    }
    
    func updateFollowingStatus(_ type : NewsfeedTabType){
        if let _ = usersFollowing {
            if (type == .following) {
                updateFollowingForFollowingFeeds()
            } else if (type == .global) {
                updateFollowingForGlobalFeeds()
            } else {
                updateFollowingForFollowingFeeds()
                updateFollowingForGlobalFeeds()
            }
        }
        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_UPDATE_FOLLOWING_STATUS_FINISHED), object: nil)
        
    }
    
    func checkFollowStatus(_ users: [UserProfile], completionHandler: @escaping (_ error: NSError?, _ shouldReload: Bool) -> Void) {
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
            completionHandler(nil, shouldReload)
        } else {
            SocialManager.sharedInstance.getProfilesOfUsersFollowing({ (result, error) -> Void in
                if let error = error {
                    completionHandler(error, shouldReload)
                } else {
                    self.usersFollowing = result!
                    check()
                    completionHandler(nil, shouldReload)
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
    
    func updateFollowingStatusForNewAddingData(_ data : [UserPost]) -> [UserPost]{
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
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: UserProfile.filePath)
        } catch {
            
        }
        UserDefaults.standard.removeObject(forKey: notificationKey)
    }
    
}

extension Array {
    mutating func remove<U: Equatable>(_ object: U) -> Bool {
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if object == to {
                    self.remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
}

