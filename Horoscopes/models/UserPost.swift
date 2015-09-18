//
//  Newsfeed.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

public class UserPost : NSObject{
    var post_id : String = ""
    var uid : Int = -1
    var type : NewsfeedType
    var message : String = ""
    var truncated : Int = 0
    var hearts : Int = 0
    var shares: Int = 0
    var ts : Int = 0
    
    var user : UserProfile?
    
    init(data: NSDictionary){
        self.uid = data.objectForKey("uid") as! Int
        self.post_id = data.objectForKey("post_id") as! String
        self.type = Utilities.getNewsfeedTypeByString(data.objectForKey("type") as! String)
        self.message = data.objectForKey("message") as! String
        self.truncated = data.objectForKey("truncated") as! Int
        self.hearts = data.objectForKey("hearts") as! Int
        shares = data.objectForKey("shares") as! Int
        self.ts = data.objectForKey("ts") as! Int
    }
    
    static func postsFromResults(results: [NSDictionary]) -> [UserPost] {
        var posts = [UserPost]()
        for result in results {
            posts.append(UserPost(data: result))
        }
        return posts
    }
    
    override public var description: String {
        let string = ("id = \(post_id) || desc = \(message)")
        return string
    }
    
}

// note that this is OUTSIDE of your class impl to make it global
public func ==(lhs: UserPost, rhs: UserPost) -> Bool {
    return lhs.post_id == rhs.post_id
}