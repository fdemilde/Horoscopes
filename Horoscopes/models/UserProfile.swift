//
//  UserProfile.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class UserProfile: NSObject, NSCoding {
    var uid : Int = -1
    var name : String = ""
    var imgURL : String = ""
    var sign : Int = 0
    var location : String = ""
    static var filePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
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
        self.sign = data.objectForKey("sign") as! Int
        self.location = data.objectForKey("location") as! String
    }
    
    override init(){
        
    }
    
    required init(coder aDecoder: NSCoder) {
        aDecoder.decodeIntegerForKey(Keys.uid)
        aDecoder.decodeObjectForKey(Keys.name)
        aDecoder.decodeObjectForKey(Keys.imgUrl)
        aDecoder.decodeIntegerForKey(Keys.sign)
        aDecoder.decodeObjectForKey(Keys.location)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(uid, forKey: Keys.uid)
        aCoder.encodeObject(name, forKey: Keys.name)
        aCoder.encodeObject(imgURL, forKey: Keys.imgUrl)
        aCoder.encodeInteger(sign, forKey: Keys.sign)
        aCoder.encodeObject(location, forKey: Keys.location)
    }
    
//    static func profilesFromResults(results: [NSDictionary]) -> [UserProfile] {
//        var profiles = [UserProfile]()
//        for result in results {
//            profiles.append(UserProfile(data: result))
//        }
//        return profiles
//    }

}