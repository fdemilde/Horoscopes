//
//  Newsfeed.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

open class UserPost : NSObject{
    var post_id : String = ""
    var uid : Int = -1
    var type = NewsfeedType.invalid
    var message : String = ""
    var truncated : Int = 0
    var hearts : Int = 0
    var shares: Int = 0
    var comment: Int = 0
    var ts : Int = 0
    var permalink = ""
    
    var user : UserProfile?
    
    init?(data: NSDictionary){
        super.init()
        // if data doesn't have a type or type is invalid, ignore it
        print("DATA", data)
        self.type = Utilities.getNewsfeedTypeByString(data.object(forKey: "type") as! String)
        self.uid = data.object(forKey: "uid") as! Int
        self.post_id = data.object(forKey: "post_id") as! String
        self.message = data.object(forKey: "message") as! String
        self.truncated = data.object(forKey: "truncated") as! Int
        self.hearts = data.object(forKey: "hearts") as! Int
        shares = data.object(forKey: "shares") as! Int
        self.comment = data.object(forKey: "comment") as! Int
        self.ts = data.object(forKey: "ts") as! Int
        self.permalink = data.object(forKey: "permalink") as! String
        
        if(self.type == NewsfeedType.invalid){
            return nil
        }
    }
    
    static func postsFromResults(_ results: [NSDictionary]) -> [UserPost] {
        var posts = [UserPost]()
        for result in results {
            if (UserPost(data: result) != nil) {
                posts.append(UserPost(data: result)!)
            }
        }
        return posts
    }
    
    override open var description: String {
        let string = ("id = \(post_id) || desc = \(message) || ts = \(ts) \n")
        return string
    }
    
}

// note that this is OUTSIDE of your class impl to make it global
public func ==(lhs: UserPost, rhs: UserPost) -> Bool {
    return lhs.post_id == rhs.post_id
}
