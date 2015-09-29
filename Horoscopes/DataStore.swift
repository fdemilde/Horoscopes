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
    var followers: [UserProfile]?
    
    var recentSearchedProfile = [UserProfile]()
    var isLastPage = false
    var lastCookieOpenDate : NSDate!
    var currentFortuneDescription = ""
    var currentLuckyNumber = ""
    
    static let sharedInstance = DataStore()
    
    override init(){
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFollowers:", name: NOTIFICATION_FOLLOW, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateFollowers(_: NSNotification) {
        SocialManager.sharedInstance.getCurrentUserFollowersProfile { (result, error) -> Void in
            if let _ = error {
                
            } else {
                self.followers = result!
            }
        }
    }
    
    func saveSearchedProfile(profile: UserProfile) {
        if recentSearchedProfile.filter({ $0.uid == profile.uid }).isEmpty {
            recentSearchedProfile.append(profile)
        }
    }
    
    func addDataArray(data : [UserPost], type: NewsfeedTabType, isLastPage : Bool){
        newsfeedIsUpdated = false
        self.isLastPage = isLastPage
        switch type {
            case NewsfeedTabType.Following:
                if(data.count == 0){
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: nil)
                    return // no new data
                }
                newsfeedFollowing = addData(newsfeedFollowing, newDataArray: data)
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: newsfeedFollowing)
            }
            case NewsfeedTabType.Global:
                if(data.count == 0){
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: nil)
                    return // no new data
                }
                newsfeedGlobal = addData(newsfeedGlobal, newDataArray: data)
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: newsfeedGlobal)
            }
        }
        
    }
    
    func updateData(data : [UserPost], type: NewsfeedTabType){
        newsfeedIsUpdated = false // reset updated flag to false
        self.isLastPage = false // reset
        switch type {
            case NewsfeedTabType.Following:
                if(newsfeedFollowing.count == 0){
                    newsfeedIsUpdated = true
                    newsfeedFollowing = data
                } else {
                    // do compare to update current newsfeed
                    self.checkAndUpdateFeedData(data, type: NewsfeedTabType.Following)
                }
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED, object: newsfeedFollowing)
                }
            case NewsfeedTabType.Global:
                if(newsfeedGlobal.count == 0){
                    newsfeedIsUpdated = true
                    newsfeedGlobal = data
                } else {
                    // do compare to update current newsfeed
                    self.checkAndUpdateFeedData(data, type: NewsfeedTabType.Global)
                }
                if (newsfeedIsUpdated) {
                    Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object: newsfeedGlobal)
                }
        }
        
    }
    
    func checkAndUpdateFeedData(newData : [UserPost], type : NewsfeedTabType) -> Bool{
        switch type {
            case NewsfeedTabType.Following:
                newsfeedFollowing = compareAndUpdateArrayData(newsfeedFollowing, newDataArray: newData)
            case NewsfeedTabType.Global:
                newsfeedGlobal = compareAndUpdateArrayData(newsfeedGlobal, newDataArray: newData)
        }
        return false
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
    mutating func remove <U: Equatable> (object: U) {
        for i in (self.count - 1).stride(to: 0, by: -1) {
            if let element = self[i] as? U {
                if element == object {
                    self.removeAtIndex(i)
                }
            }
        }
    }
}

