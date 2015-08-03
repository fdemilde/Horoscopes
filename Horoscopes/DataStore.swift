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
    
    override init(){
        
    }
    
    func updateNewsfeedFollowingData(data : [UserPost]){
        
        newsfeedIsUpdated = false // reset updated flag to false
        // if no data, just replace with new data
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
        
    }
    
    func updateNewsfeedGlobalData(data : [UserPost]){
        newsfeedIsUpdated = false
        // if no data, just replace with new data
        if(newsfeedGlobal.count == 0){
            newsfeedIsUpdated = true
            newsfeedGlobal = data
        } else {
            // do compare to update current newsfeed
            self.checkAndUpdateFeedData(data, type: NewsfeedTabType.Global)
        }
        if (newsfeedIsUpdated) {
            Utilities.postNotification(NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED, object:newsfeedGlobal)
        }
        
    }
    
    func checkAndUpdateFeedData(newData : [UserPost], type : NewsfeedTabType) -> Bool{
        switch type {
            case NewsfeedTabType.Following:
                newsfeedFollowing = compareAndUpdateArrayData(newsfeedFollowing, newDataArray: newData)
            case NewsfeedTabType.Global:
                newsfeedGlobal = compareAndUpdateArrayData(newsfeedGlobal, newDataArray: newData)
            default:
                newsfeedFollowing = compareAndUpdateArrayData(newsfeedFollowing, newDataArray: newData)
        }
        return false
    }
    
    // Helpers
    func compareAndUpdateArrayData(oldDataArray : [UserPost], newDataArray : [UserPost]) -> [UserPost]{
        var removedArray = [UserPost]()
        var mutableOldArray = oldDataArray
        var oldPostIDArray = self.parseUserPostDataIntoPostIdArray(oldDataArray)
        var newPostIDArray = self.parseUserPostDataIntoPostIdArray(newDataArray)
        
        // loop through new Data array first and check with old data, if old data not exist in new data, remove it
        for (index,oldPostId) in enumerate(oldPostIDArray) {
            if(!contains(newPostIDArray, oldPostId)){
                removedArray.append(oldDataArray[index])
            }
        }
        
        for post in removedArray {
            if(!newsfeedIsUpdated) { newsfeedIsUpdated = true }
            mutableOldArray.remove(post)
        }
        
        // check if any new post, update old array with new items
        for (index,newPostId) in enumerate(newPostIDArray) {
            if(!contains(oldPostIDArray, newPostId)){
                if(!newsfeedIsUpdated) { newsfeedIsUpdated = true }
                mutableOldArray.insert(newDataArray[index], atIndex: 0)
            }
        }
        
        // sort new data with post ts
        mutableOldArray.sort { $0.ts > $1.ts }
        
        return mutableOldArray
    }
    
    func parseUserPostDataIntoPostIdArray(array:[UserPost]) ->[String] {
        var result = [String]()
        for post in array {
            result.append(post.post_id)
        }
        return result
    }
    
}

extension Array {
    mutating func remove <U: Equatable> (object: U) {
        for i in stride(from: self.count-1, through: 0, by: -1) {
            if let element = self[i] as? U {
                if element == object {
                    self.removeAtIndex(i)
                }
            }
        }
    }
}

