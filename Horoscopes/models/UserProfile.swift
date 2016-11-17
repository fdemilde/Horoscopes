//
//  UserProfile.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

open class UserProfile: NSObject, NSCoding {
    var uid : Int = -1
    var name : String = ""
    var imgURL : String = ""
    var sign : Int = -1
    var location : String = ""
    
    var isFollowed = false
    static var filePath: String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("userProfile").path
    }
    struct Keys {
        static let uid = "uid"
        static let name = "name"
        static let imgUrl = "imgUrl"
        static let sign = "sign"
        static let location = "location"
    }
    
    init(data: NSDictionary){
        self.uid = data.object(forKey: "uid") as! Int
        self.name = data.object(forKey: "name") as! String
        self.imgURL = data.object(forKey: "img") as! String
        let sign = data.object(forKey: "sign") as! Int
        self.sign = sign - 1
        
        self.location = data.object(forKey: "location") as! String
    }

    override init(){
        
    }
    
    required public init(coder aDecoder: NSCoder) {
        uid = aDecoder.decodeInteger(forKey: Keys.uid)
        name = aDecoder.decodeObject(forKey: Keys.name) as! String
        imgURL = aDecoder.decodeObject(forKey: Keys.imgUrl) as! String
        sign = aDecoder.decodeInteger(forKey: Keys.sign)
        location = aDecoder.decodeObject(forKey: Keys.location) as! String
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: Keys.uid)
        aCoder.encode(name, forKey: Keys.name)
        aCoder.encode(imgURL, forKey: Keys.imgUrl)
        aCoder.encode(sign, forKey: Keys.sign)
        aCoder.encode(location, forKey: Keys.location)
    }
    
    override open var description: String {
        let string = ("name = \(name) || sign = \(sign)")
        return string
    }
}

// note that this is OUTSIDE of your class impl to make it global
public func ==(lhs: UserProfile, rhs: UserProfile) -> Bool {
    return lhs.uid == rhs.uid
}
