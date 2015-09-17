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
    var numberOfPosts: Int = 0
    var numberOfUsersFollowing: Int = 0
    var numberOfFollowers: Int = 0
    
    var isFollowed = false
    static var filePath: String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        return url.URLByAppendingPathComponent("userProfile").path!
    }
    var horoscopeSignString: String {
        return HoroscopesManager.sharedInstance.getHoroscopesSigns()[sign].sign
    }
    var horoscopeSignImage: UIImage {
        return UIImage(named: String(format:"%@_selected", horoscopeSignString))!
    }
    struct Keys {
        static let uid = "uid"
        static let name = "name"
        static let imgUrl = "imgUrl"
        static let sign = "sign"
        static let location = "location"
        static let numberOfPosts = "numberOfPosts"
        static let numberOfUsersFollowing = "numberOfUsersFollowing"
        static let numberOfFollowers = "numberOfFollowers"
    }
    
    init(data: NSDictionary){
        self.uid = data.objectForKey("uid") as! Int
        self.name = data.objectForKey("name") as! String
        self.imgURL = data.objectForKey("img") as! String
        self.sign = data.objectForKey("sign") as! Int - 1
        self.location = data.objectForKey("location") as! String
        numberOfPosts = data.objectForKey("no_post") as! Int
        numberOfUsersFollowing = data.objectForKey("no_following") as! Int
        numberOfFollowers = data.objectForKey("no_follower") as! Int
    }

    override init(){
        
    }
    
    required init(coder aDecoder: NSCoder) {
        uid = aDecoder.decodeIntegerForKey(Keys.uid)
        name = aDecoder.decodeObjectForKey(Keys.name) as! String
        imgURL = aDecoder.decodeObjectForKey(Keys.imgUrl) as! String
        sign = aDecoder.decodeIntegerForKey(Keys.sign)
        location = aDecoder.decodeObjectForKey(Keys.location) as! String
        numberOfPosts = aDecoder.decodeIntegerForKey(Keys.numberOfPosts)
        numberOfUsersFollowing = aDecoder.decodeIntegerForKey(Keys.numberOfUsersFollowing)
        numberOfFollowers = aDecoder.decodeIntegerForKey(Keys.numberOfFollowers)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(uid, forKey: Keys.uid)
        aCoder.encodeObject(name, forKey: Keys.name)
        aCoder.encodeObject(imgURL, forKey: Keys.imgUrl)
        aCoder.encodeInteger(sign, forKey: Keys.sign)
        aCoder.encodeObject(location, forKey: Keys.location)
        aCoder.encodeInteger(numberOfPosts, forKey: Keys.numberOfPosts)
        aCoder.encodeInteger(numberOfUsersFollowing, forKey: Keys.numberOfUsersFollowing)
        aCoder.encodeInteger(numberOfFollowers, forKey: Keys.numberOfFollowers)
    }
}
