//
//   UserPostComment.swift
//  Horoscopes
//
//  Created by AndAnotherOne on 11/24/16.
//  Copyright © 2016 Binh Dang. All rights reserved.
//

import Foundation

struct  UserPostComment {
    var comment_id: String
    var uid: Int
    var comment: String
    var truncated : Int
    var hearts: Int
    var ts: Int
    var permalink: String
    
    init(data: NSDictionary) {
        print("DATA", data)
        self.comment_id = data.object(forKey: "user_id") as! String
        self.uid = data.object(forKey: "uid") as! Int
        self.comment = data.object(forKey: "comment") as! String
        self.truncated = data.object(forKey: "truncated") as! Int
        self.hearts = data.object(forKey: "hearts") as! Int
        self.ts = data.object(forKey: "ts") as! Int
        self.permalink = data.object(forKey: "permalink") as! String
    }
}
