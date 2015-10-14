//
//  CacheEntry.swift
//  Horoscopes
//
//  Created by Binh Dang on 10/14/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class CacheEntry : NSObject {
    var expiredTimestamp = 0 as NSTimeInterval
    var key : String!
    var value : String!
    
    init(key : String, value: String, expired : NSTimeInterval){
        self.key = key
        self.value = value
        self.expiredTimestamp = expired
    }
    
    func isExpired() -> Bool{
        if (NSDate().timeIntervalSince1970 > expiredTimestamp) {
            return true
        } else {
            return false
        }
    }
}
