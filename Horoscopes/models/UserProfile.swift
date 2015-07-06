//
//  UserProfile.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/30/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

class UserProfile {
    var uid : Int = -1
    var name : String = ""
    var imgURL : String = ""
    var sign : Int = 0
    var location : String = ""
    
    init(data: NSDictionary){
        println("UserProfile init!!")
        self.uid = data.objectForKey("uid") as! Int
        self.name = data.objectForKey("name") as! String
        self.imgURL = data.objectForKey("img") as! String
        self.sign = data.objectForKey("sign") as! Int
        self.location = data.objectForKey("location") as! String
    }
    
    init(){
        
    }

}