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
        var screenRect = UIScreen.mainScreen().bounds
        var height = screenRect.height
        var width = screenRect.width
        return CGSizeMake(width, height)
    }
    
    class func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
    class func loadNIB(file:String) -> AnyObject{
        var arr = NSBundle.mainBundle().loadNibNamed(file, owner: nil, options: nil)
            
        var ret: AnyObject = arr[0];
        return ret;
    }
    
    class func getPositionBaseOn568hScreenSize(positionX : Float, positionY: Float) -> CGPoint{
        var screenSize = Utilities.getScreenSize()
        
        var percentageX = positionX / 320
        var percentageY = positionY / 568
        
        var result =  CGPointMake(screenSize.width * CGFloat(percentageX), screenSize.height * CGFloat(percentageY))
        
        return result
    }
    
    class func getRatio() -> CGFloat {
        var screenSize = Utilities.getScreenSize()
        var customScreenSize = screenSize.height - 211
        
        var ratio = Float(customScreenSize/(800-211))
        return CGFloat(ratio)
    }
    
    class func getSignDateString(startDate : NSDate, endDate:NSDate) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        return String(format: "%@ - %@", dateFormatter.stringFromDate(startDate),dateFormatter.stringFromDate(endDate))
    }
    
    class func showHUD(){
        
        dispatch_async(dispatch_get_main_queue(),{
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let viewController = appDelegate.window!.rootViewController
            
            let loadingNotification = MBProgressHUD.showHUDAddedTo(viewController!.view, animated: true)
            loadingNotification.mode = MBProgressHUDMode.Indeterminate
            loadingNotification.labelText = "Loading"
            
        })
    }
    
    class func hideHUD(){
        dispatch_async(dispatch_get_main_queue(),{
            let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
            let viewController = appDelegate.window!.rootViewController
            MBProgressHUD.hideAllHUDsForView(viewController!.view, animated: true)
        })
    }
    
    class func getDateStringFromTimestamp(ts : NSTimeInterval, dateFormat : String) -> String{
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        var date = NSDate(timeIntervalSince1970:ts)
        var dateString = String(format: "%@", dateFormatter.stringFromDate(date))
        return dateString
    }
}


