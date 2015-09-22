//
//  UserProfileCounts.swift
//  Horoscopes
//
//  Created by Dang Doan on 9/22/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation

struct UserProfileCounts {
    var userId: Int
    var numberOfPosts: Int
    var numberOfUsersFollowing: Int
    var numberOfFollowers: Int
    
    init(dictionary: [String: AnyObject]) {
        userId = dictionary["uid"] as! Int
        numberOfPosts = dictionary["post"] as! Int
        numberOfUsersFollowing = dictionary["following"] as! Int
        numberOfFollowers = dictionary["follower"] as! Int
    }
}