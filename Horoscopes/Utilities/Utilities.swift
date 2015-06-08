//
//  Utilities.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/8/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
class Utilities {
    class func parseNSDictionaryToDictionary(dict : NSDictionary) -> Dictionary<String, AnyObject>{
        var result = Dictionary<String, AnyObject>()
        var keys = dict.allKeys
        for key in keys{
            var keyString = key as! String
            println("keyString : \(keyString)")
            result[keyString] = dict.objectForKey(keyString)
        }
        return result
    }
    
    class func parseDictionaryToNSDictionary(dict : Dictionary<String, AnyObject>) -> NSDictionary{
        var result = NSMutableDictionary()
        var keys = dict.keys
        
        for key in keys{
            var keyString = key as String
            result.setObject(dict[keyString]!, forKey: keyString)
        }
        return result
    }
    
    class func parseArrayToNSArray(array : [AnyObject]) -> NSArray{
        var result = NSMutableArray()
        
        for var i = 0; i < array.count; i++ {
            result.addObject(array[i])
        }
        return result
    }
    
    class func getScreenSize() -> CGSize{
        var screenRect = UIScreen.mainScreen().bounds;
        var height = screenRect.height
        var width = screenRect.width
        return CGSizeMake(width, height)
    }
}


