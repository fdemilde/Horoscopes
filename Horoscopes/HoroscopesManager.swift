//
//  HoroscopesManager.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/4/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation
import CoreTelephony

class HoroscopesManager : NSObject {
    var horoscopesSigns = [Horoscope]()
    var data = Dictionary<String,AnyObject>()
    static let sharedInstance = HoroscopesManager()
    
    override init(){
        
    }
    
    func getHoroscopesSigns() -> [Horoscope] {
        
        if horoscopesSigns.isEmpty {
//            println("getHoroscopesSigns getHoroscopesSigns empty")
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "dd-MM";
            horoscopesSigns.append(Horoscope(sign:"Aries",
                                        startFrom: dateFormatter.dateFromString("21-03"),
                                               to:dateFormatter.dateFromString("19-04")))
            horoscopesSigns.append(Horoscope(sign:"Taurus",
                startFrom: dateFormatter.dateFromString("20-04"),
                to:dateFormatter.dateFromString("20-05")))
            horoscopesSigns.append(Horoscope(sign:"Gemini",
                startFrom: dateFormatter.dateFromString("21-05"),
                to:dateFormatter.dateFromString("21-06")))
            
            horoscopesSigns.append(Horoscope(sign:"Cancer",
                startFrom: dateFormatter.dateFromString("22-06"),
                to:dateFormatter.dateFromString("22-07")))
            
            horoscopesSigns.append(Horoscope(sign:"Leo",
                startFrom: dateFormatter.dateFromString("23-07"),
                to:dateFormatter.dateFromString("22-08")))
            
            horoscopesSigns.append(Horoscope(sign:"Virgo",
                startFrom: dateFormatter.dateFromString("23-08"),
                to:dateFormatter.dateFromString("22-09")))
            
            horoscopesSigns.append(Horoscope(sign:"Libra",
                startFrom: dateFormatter.dateFromString("23-09"),
                to:dateFormatter.dateFromString("22-10")))
            
            horoscopesSigns.append(Horoscope(sign:"Scorpio",
                startFrom: dateFormatter.dateFromString("23-10"),
                to:dateFormatter.dateFromString("21-11")))
            
            horoscopesSigns.append(Horoscope(sign:"Sagittarius",
                startFrom: dateFormatter.dateFromString("22-11"),
                to:dateFormatter.dateFromString("21-12")))
            
            horoscopesSigns.append(Horoscope(sign:"Capricorn",
                startFrom: dateFormatter.dateFromString("22-12"),
                to:dateFormatter.dateFromString("19-01")))
            
            horoscopesSigns.append(Horoscope(sign:"Aquarius",
                startFrom: dateFormatter.dateFromString("20-01"),
                to:dateFormatter.dateFromString("18-02")))
            
            horoscopesSigns.append(Horoscope(sign:"Pisces",
                startFrom: dateFormatter.dateFromString("19-02"),
                to:dateFormatter.dateFromString("20-03")))
        } else {
//            println("getHoroscopesSigns getHoroscopesSigns not empty!!!")
        }
        return horoscopesSigns
    }
    
    // MARK: Network - Horoscope
    
    func getAllHoroscopes(refreshOnly : Bool) {
        Utilities.showHUD()
        
        var offset = NSTimeZone.systemTimeZone().secondsFromGMT/3600;
        var offsetString = String(format: "%d",offset)
        var postData = NSMutableDictionary()
        if(refreshOnly == false){
            
            var mccString = "123"
            var mncString = "12"
            var netInfo = CTTelephonyNetworkInfo()
            if let carrier = netInfo.subscriberCellularProvider {
                if(carrier.mobileCountryCode != nil){
                    mccString = carrier.mobileCountryCode
                }
                
                if(carrier.mobileNetworkCode != nil){
                    mncString = carrier.mobileNetworkCode
                }

            }
            
            var iOSVersion = UIDevice.currentDevice().systemVersion;
            var devideType = UIDevice.currentDevice().model;
            
            //get collected data
            var col = CollectedHoroscope();
            var score = col.getScore()*100
            var strScore = String(format: "%f",score)
            
            var loadCount = XAppDelegate.mobilePlatform.tracker.loadAppOpenCountervalue()
            var loadCountString = String(format: "%d",loadCount)
            
            var version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as! String
            
            var sign = XAppDelegate.userSettings.horoscopeSign
            var signString = String(format: "%d",sign)
            
            // sc.sendRequest need an NSMutableDictionary to process
            
            postData.setObject(mccString, forKey: "mcc")
            postData.setObject(mncString, forKey: "mnc")
            postData.setObject(strScore, forKey: "score")
            postData.setObject(loadCountString, forKey: "load_count")
            postData.setObject(version, forKey: "version")
            postData.setObject(signString, forKey: "sign")
            postData.setObject(offsetString, forKey: "tz")
            postData.setObject(iOSVersion, forKey: "device_systemVersion")
            postData.setObject(devideType, forKey: "device_model")
            
            XAppDelegate.mobilePlatform.sc.sendRequest(GET_DATA_METHOD, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
                if(error != nil){
                    Utilities.hideHUD()
                } else {
                    self.data = Utilities.parseNSDictionaryToDictionary(response)
//                    print(self.data)
                    self.saveData()
                    Utilities.postNotification(NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
                    Utilities.hideHUD()
                }
                
            })
        } else {
            postData.setObject(offsetString, forKey: "tz")
            XAppDelegate.mobilePlatform.sc.sendRequest(REFRESH_DATA_METHOD, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
                if(error != nil){
                    Utilities.hideHUD()
                } else {
                    self.data = Utilities.parseNSDictionaryToDictionary(response)
    //                print(self.data)
                    self.saveData()
                    Utilities.postNotification(NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
                    Utilities.hideHUD()
                }
            })
        }
        
    }
    
    func registerNotificationToken(token : String, completionHandler:(response : Dictionary<String,AnyObject>?, error : NSError?) -> Void ){
        var postData = NSMutableDictionary()
        postData.setObject(token, forKey: "device_token")
        XAppDelegate.mobilePlatform.sc.sendRequest(REGISTER_NOTIFICATION_TOKEN, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            var result = Utilities.parseNSDictionaryToDictionary(response)
            completionHandler(response: result, error: error)
        })
    }
    
    func sendRateRequestWithTimeTag(timeTag: Int, signIndex: Int, rating: Int){
        // our sign index is base 0-11 --> we should convert it to base 1-12
        var base1SignIndex = signIndex + 1
        //prepare post data
        var postData = NSMutableDictionary()
        var timeTagString = String(format:"%d",timeTag)
        var base1SignIndexString = String(format:"%d",base1SignIndex)
        var ratingString = String(format: "%d",rating)
        postData.setObject(timeTagString, forKey: "time_tag")
        postData.setObject(base1SignIndexString, forKey: "sign")
        postData.setObject(ratingString, forKey: "rating")
        XAppDelegate.mobilePlatform.sc.sendRequest(RATE_HOROSCOPE, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
//            print(response)
            
            var result = Utilities.parseNSDictionaryToDictionary(response)
            Utilities.postNotification(NOTIFICATION_RATE_HOROSCOPE_RESULT, object: result)
        })
    }
    
    func sendUpdateBirthdayRequest(birthdayString : String,completionHandler: ( responseDict : Dictionary<String, AnyObject>?, error : NSError?) -> Void){
        
        var postData = NSMutableDictionary()
        var birthday = String(format:"%@",birthdayString)
        postData.setObject(birthday, forKey: "birthday")
        XAppDelegate.mobilePlatform.sc.sendRequest(UPDATE_BIRTHDAY, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
//            println(response)
            var result = Utilities.parseNSDictionaryToDictionary(response)
            completionHandler(responseDict: result,error: error)
        })
    }
    
    // MARK: Helpers
    
    func saveData(){
        
        var todayReadings = Dictionary<String, String>()
        var tomorrowReadings = Dictionary<String, String>()
        var horoSigns = self.horoscopesSigns
        todayReadings = self.data["today"]!["readings"]! as! Dictionary<String,String>
        tomorrowReadings = self.data["tomorrow"]!["readings"]! as! Dictionary<String,String>
        
        for var index = 1; index <= 12; index++ {
            horoSigns[index-1].horoscopes.removeAllObjects()
            horoSigns[index-1].horoscopes.addObject(todayReadings[String(format: "%d", index)]!)
            horoSigns[index-1].horoscopes.addObject(tomorrowReadings[String(format: "%d", index)]!)
        }
    }
    
    func getSignIndexOfDate(date : NSDate) -> Int{
        for index in 0...11 {
            if(index == 9) { continue } // we ignore Capricorn since its start date is 22/12 and end date is 19/1, this case will return as the last sign
            var horoscope = self.horoscopesSigns[index]
            if((date.compare(horoscope.startDate) == NSComparisonResult.OrderedDescending ||   date.compare(horoscope.startDate) == NSComparisonResult.OrderedSame)
                && (date.compare(horoscope.endDate) == NSComparisonResult.OrderedAscending || date.compare(horoscope.endDate) == NSComparisonResult.OrderedSame)){
                    return index
            }
        }
        return 9
    }
    
    func getSignIndexOfSignName(name : String) -> Int{
        for index in 0...11 {
            if(name == self.horoscopesSigns[index].sign){
                return index
            }
        }
        return -1
    }
    
    func getSignNameOfDate(date : NSDate) -> String{
        for index in 0...11 {
            if(index == 9) { continue } // we ignore Capricorn since its start date is 22/12 and end date is 19/1, this case will return as the last sign
            var horoscope = self.horoscopesSigns[index]
            if((date.compare(horoscope.startDate) == NSComparisonResult.OrderedDescending ||   date.compare(horoscope.startDate) == NSComparisonResult.OrderedSame)
                && (date.compare(horoscope.endDate) == NSComparisonResult.OrderedAscending || date.compare(horoscope.endDate) == NSComparisonResult.OrderedSame)){
                    return horoscope.sign
            }
        }
        var horoscope = horoscopesSigns[9]
        return horoscope.sign
    }
    
}


 