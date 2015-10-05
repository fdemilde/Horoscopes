//
//  UserProfile.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

public class UserProfile: NSObject, NSCoding {
    var uid : Int = -1
    var name : String = ""
    var imgURL : String = ""
    var sign : Int = -1
    var location : String = ""
    
    var isFollowed = false
    static var filePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("userProfile").path!
    }
    struct Keys {
        static let uid = "uid"
        static let name = "name"
        static let imgUrl = "imgUrl"
        static let sign = "sign"
        static let location = "location"
    }
    
    init(data: NSDictionary){
        self.uid = data.objectForKey("uid") as! Int
        self.name = data.objectForKey("name") as! String
        self.imgURL = data.objectForKey("img") as! String
        let sign = data.objectForKey("sign") as! Int
        self.sign = sign - 1
        
        self.location = data.objectForKey("location") as! String
    }

    override init(){
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        uid = aDecoder.decodeIntegerForKey(Keys.uid)
        name = aDecoder.decodeObjectForKey(Keys.name) as! String
        imgURL = aDecoder.decodeObjectForKey(Keys.imgUrl) as! String
        sign = aDecoder.decodeIntegerForKey(Keys.sign)
        location = aDecoder.decodeObjectForKey(Keys.location) as! String
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(uid, forKey: Keys.uid)
        aCoder.encodeObject(name, forKey: Keys.name)
        aCoder.encodeObject(imgURL, forKey: Keys.imgUrl)
        aCoder.encodeInteger(sign, forKey: Keys.sign)
        aCoder.encodeObject(location, forKey: Keys.location)
    }
    
    override public var description: String {
        let string = ("name = \(name)")
        return string
    }
}

// note that this is OUTSIDE of your class impl to make it global
public func ==(lhs: UserProfile, rhs: UserProfile) -> Bool {
    return lhs.uid == rhs.uid
}
