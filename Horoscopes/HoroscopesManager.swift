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
    var hasNoData = false
    
    override init(){
        
    }
    
    func getHoroscopesSigns() -> [Horoscope] {
        
        if horoscopesSigns.isEmpty {
            horoscopesSigns.append(Horoscope(sign:"Aries",
                                             startFrom: StandardDate(day: 21, month: 3),
                                             to: StandardDate(day: 19, month: 4)))
            horoscopesSigns.append(Horoscope(sign:"Taurus",
                                             startFrom: StandardDate(day: 20, month: 4),
                                             to:StandardDate(day: 20, month: 5)))
            horoscopesSigns.append(Horoscope(sign:"Gemini",
                                             startFrom: StandardDate(day: 21, month: 5),
                                             to:StandardDate(day: 21, month: 6)))
            
            horoscopesSigns.append(Horoscope(sign:"Cancer",
                                             startFrom: StandardDate(day: 22, month: 6),
                                             to:StandardDate(day: 22, month: 7)))
            
            horoscopesSigns.append(Horoscope(sign:"Leo",
                                             startFrom: StandardDate(day: 23, month: 7),
                                             to:StandardDate(day: 22, month: 8)))
            
            horoscopesSigns.append(Horoscope(sign:"Virgo",
                                             startFrom: StandardDate(day: 23, month: 8),
                                             to:StandardDate(day: 22, month: 9)))
            
            horoscopesSigns.append(Horoscope(sign:"Libra",
                                             startFrom: StandardDate(day: 23, month: 9),
                                             to:StandardDate(day: 22, month: 10)))
            
            horoscopesSigns.append(Horoscope(sign:"Scorpio",
                                             startFrom: StandardDate(day: 23, month: 10),
                                             to:StandardDate(day: 21, month: 11)))
            
            horoscopesSigns.append(Horoscope(sign:"Sagittarius",
                                             startFrom: StandardDate(day: 22, month: 11),
                                             to:StandardDate(day: 21, month: 12)))
            
            horoscopesSigns.append(Horoscope(sign:"Capricorn",
                                             startFrom: StandardDate(day: 22, month: 12),
                                             to:StandardDate(day: 19, month: 1)))
            
            horoscopesSigns.append(Horoscope(sign:"Aquarius",
                                             startFrom: StandardDate(day: 20, month: 1),
                                             to:StandardDate(day: 18, month: 2)))
            
            horoscopesSigns.append(Horoscope(sign:"Pisces",
                                             startFrom: StandardDate(day: 19, month: 2),
                                             to:StandardDate(day: 20, month: 3)))
        } else {
        }
        return horoscopesSigns
    }
    
    // MARK: Network - Horoscope
    
    func getAllHoroscopes(_ refreshOnly : Bool) {
        Utilities.showHUD()
        let offset = NSTimeZone.system.secondsFromGMT()/3600;
        let offsetString = String(format: "%d",offset)
        let postData = NSMutableDictionary()
        if(refreshOnly == false){
            var mccString = "123"
            var mncString = "12"
            let netInfo = CTTelephonyNetworkInfo()
            if let carrier = netInfo.subscriberCellularProvider {
                if(carrier.mobileCountryCode != nil){
                    mccString = carrier.mobileCountryCode!
                }
                
                if(carrier.mobileNetworkCode != nil){
                    mncString = carrier.mobileNetworkCode!
                }
                
            }
            
            let iOSVersion = UIDevice.current.systemVersion;
            let devideType = UIDevice.current.model;
            
            //get collected data
            let col = CollectedHoroscope();
            let score = col.getScore()*100
            let strScore = String(format: "%f",score)
            
            let loadCount = XAppDelegate.mobilePlatform.tracker.loadAppOpenCountervalue()
            let loadCountString = String(format: "%d",loadCount)
            
            let version = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
            
            let sign = XAppDelegate.userSettings.horoscopeSign + 1
            let signString = String(format: "%d",sign)
            
            // sc.sendRequest need an NSMutableDictionary to process
            
            postData.setObject(mccString, forKey: "mcc" as NSCopying)
            postData.setObject(mncString, forKey: "mnc" as NSCopying)
            postData.setObject(strScore, forKey: "score" as NSCopying)
            postData.setObject(loadCountString, forKey: "load_count" as NSCopying)
            postData.setObject(version, forKey: "version" as NSCopying)
            postData.setObject(signString, forKey: "sign" as NSCopying)
            postData.setObject(offsetString, forKey: "tz" as NSCopying)
            postData.setObject(iOSVersion, forKey: "device_systemVersion" as NSCopying)
            postData.setObject(devideType, forKey: "device_model" as NSCopying)
            let expiredTime = Date().timeIntervalSince1970 + 600
            CacheManager.cacheGet(GET_DATA_METHOD, postData: postData, loginRequired: NOT_REQUIRED, expiredTime: expiredTime, forceExpiredKey: nil, ignoreCache: true, completionHandler: { (result, error) -> Void in
                Utilities.hideHUD()
                if(error != nil){
                    self.setupNodata()
                } else {
                    if let result = result {
                        if let dataError = result["error"] {
                            let dataErrorAsInt = dataError as! Int
                            if(dataErrorAsInt != 0){ // data error occured
                                self.setupNodata()
                            } else {
                                self.data = Utilities.parseNSDictionaryToDictionary(result)
                                if(self.data.count != 0){ self.saveData() }
                                Utilities.postNotification(NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
                                return
                            }
                        } else {
                            self.setupNodata()
                        }
                    } else {
                        self.setupNodata()
                    }
                }
                Utilities.postNotification(NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
            })
        } else {
            let expiredTime = Date().timeIntervalSince1970 + 600
            postData.setObject(offsetString, forKey: "tz" as NSCopying)
            CacheManager.cacheGet(REFRESH_DATA_METHOD, postData: postData, loginRequired: NOT_REQUIRED, expiredTime: expiredTime, forceExpiredKey: nil, ignoreCache: true, completionHandler: { (response, error) -> Void in
                Utilities.hideHUD()
                if(error != nil){
                    print("error == \(error)")
                    self.setupNodata()
                } else {
                    if let result = response {
                        if let dataError = result["error"] {
                            let dataErrorAsInt = dataError as! Int
                            if(dataErrorAsInt != 0){ // data error occured
                                self.setupNodata()
                            } else {
                                self.data = Utilities.parseNSDictionaryToDictionary(result)
                                self.saveData()
                                Utilities.postNotification(NOTIFICATION_ALL_SIGNS_LOADED, object:nil)
                                return
                            }
                        } else {
                            self.setupNodata()
                        }
                    } else {
                        self.setupNodata()
                    }
                    Utilities.postNotification(NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
                }
            })
        }
        
    }
    
    func sendRateRequestWithTimeTag(_ timeTag: Int, signIndex: Int, rating: Int, viewcontroller : UIViewController){
        Utilities.showHUD()
        // our sign index is base 0-11 --> we should convert it to base 1-12
        let base1SignIndex = signIndex + 1
        //prepare post data
        let postData = NSMutableDictionary()
        let timeTagString = String(format:"%d",timeTag)
        let base1SignIndexString = String(format:"%d",base1SignIndex)
        let ratingString = String(format: "%d",rating)
        postData.setObject(timeTagString, forKey: "time_tag" as NSCopying)
        postData.setObject(base1SignIndexString, forKey: "sign" as NSCopying)
        postData.setObject(ratingString, forKey: "rating" as NSCopying)
        DispatchQueue.main.async(execute: {
            XAppDelegate.mobilePlatform.sc.sendRequest(RATE_HOROSCOPE, andPostData: postData, andComplete: { (response,error) -> Void in
                //            print(response)
                Utilities.hideHUD()
                if error != nil {
                    Utilities.showError(error as! NSError)
                } else {
                    if let errorCode = response?["error_code"]{
                        if(errorCode as? String == "error.invalidtoken"){
                            XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                            return
                        }
                    }
                    let result = Utilities.parseNSDictionaryToDictionary(response! as NSDictionary )
                    Utilities.postNotification(NOTIFICATION_RATE_HOROSCOPE_RESULT, object: result as AnyObject?)
                }
            })
        })
    }
    
    func sendUpdateBirthdayRequest(_ birthdayString : String,completionHandler: @escaping ( _ responseDict : Dictionary<String, AnyObject>?, _ error : NSError?) -> Void){
        
        let postData = NSMutableDictionary()
        let birthday = String(format:"%@",birthdayString)
        postData.setObject(birthday, forKey: "birthday" as NSCopying)
        XAppDelegate.mobilePlatform.sc.sendRequest(UPDATE_BIRTHDAY, andPostData: postData, andComplete: { (response,error) -> Void in
            if(error != nil){
                
            } else {
                if let response = response {
                    if let errorCode = response["error_code"]{
                        if(errorCode as? String == "error.invalidtoken"){
                            XAppDelegate.socialManager.logoutWhenRetrieveInvalidToken()
                            return
                        }
                    }
                    let result = Utilities.parseNSDictionaryToDictionary(response as NSDictionary)
                    completionHandler(result,error as NSError?)
                } else {
                    completionHandler(nil,error as NSError?)
                }
            }
        })
    }
    
    // MARK: Helpers
    
    func saveData(){
        hasNoData = false;
        var todayReadings = Dictionary<String, String>()
        var tomorrowReadings = Dictionary<String, String>()
        var horoSigns = self.horoscopesSigns
        todayReadings = self.data["today"]!["readings"]! as! Dictionary<String,String>
        tomorrowReadings = self.data["tomorrow"]!["readings"]! as! Dictionary<String,String>
        
        var index = 1
        repeat {
            let indexString: String = "\(index)"
            
            print("SOMETHING:", self.data)
            let today = self.data["today"] as! [String: Any]
            print("TODAY", today)
            let todayPermaLinkNoIndex = today["permalinks"] as! [String: Any]
            let todayPermaLink = todayPermaLinkNoIndex[indexString] as! String
            
            let tomorrow = self.data["tomorrow"] as! [String: Any]
            let tomorrowPermaLinkNoIndex = tomorrow["permalinks"] as! [String: Any]
            let tomorrowPermaLink = tomorrowPermaLinkNoIndex[indexString] as! String
            
            horoSigns[index-1].horoscopes.removeAllObjects()
            horoSigns[index-1].permaLinks.removeAllObjects()
            
            horoSigns[index-1].horoscopes.add(todayReadings[String(format: "%d", index)]!)
            horoSigns[index-1].horoscopes.add(tomorrowReadings[String(format: "%d", index)]!)
            horoSigns[index-1].permaLinks.add(String(format: "%@", todayPermaLink))
            horoSigns[index-1].permaLinks.add(String(format: "%@", tomorrowPermaLink))
            
            index += 1
            
        } while(index <= 12)
    }
    
    func setupNodata(){
        var horoSigns = self.horoscopesSigns
        hasNoData = true
        var todayTimeTagDict = Dictionary<String, String>()
        todayTimeTagDict["time_tag"] = String(format:"%f", Date().timeIntervalSince1970)
        self.data["today"] = todayTimeTagDict as AnyObject?
        
        var tomorrowTimeTagDict = Dictionary<String, String>()
        tomorrowTimeTagDict["time_tag"] = String(format:"%f", Date().timeIntervalSince1970 + 60*60*24)
        self.data["tomorrow"] = tomorrowTimeTagDict as AnyObject?
        
        var index = 1
        repeat {
            horoSigns[index-1].horoscopes.removeAllObjects()
            horoSigns[index-1].permaLinks.removeAllObjects()
            
            horoSigns[index-1].horoscopes.add("Network Error, please check your internet and pull down to refresh.")
            horoSigns[index-1].horoscopes.add("")
            horoSigns[index-1].permaLinks.add("")
            horoSigns[index-1].permaLinks.add("")
            index += 1
        } while(index <= 12)
    }
    
    func getSignIndexOfDate(_ date : Date) -> Int{
        for index in 0...11 {
            if(index == 9) { continue } // we ignore Capricorn since its start date is 22/12 and end date is 19/1, this case will return as the last sign
            let horoscope = self.horoscopesSigns[index]
            if((date.compare(horoscope.startDate.nsDate) == ComparisonResult.orderedDescending ||   date.compare(horoscope.startDate.nsDate) == ComparisonResult.orderedSame)
                && (date.compare(horoscope.endDate.nsDate) == ComparisonResult.orderedAscending || date.compare(horoscope.endDate.nsDate) == ComparisonResult.orderedSame)){
                return index
            }
        }
        return 9
    }
    
    func getSignIndexOfSignName(_ name : String) -> Int{
        
        for index in 0...11 {
            if(name == self.horoscopesSigns[index].sign){
                return index
            }
        }
        return -1
    }
    
    func getSignNameOfDate(_ date : StandardDate) -> String{
        
        var sign = ""
        switch date.month {
        case 1:
            if date.day >= 20 {
                sign = "Aquarius"
            } else {
                sign = "Capricorn"
            }
        case 2:
            if date.day >= 19 {
                sign = "Pisces"
            } else {
                sign = "Aquarius"
            }
        case 3:
            if date.day >= 21 {
                sign = "Aries"
            } else {
                sign = "Pisces"
            }
        case 4:
            if date.day >= 20 {
                sign = "Taurus"
            } else {
                sign = "Aries"
            }
        case 5:
            if date.day >= 21 {
                sign = "Gemini"
            } else {
                sign = "Taurus"
            }
        case 6:
            if date.day >= 22 {
                sign = "Cancer"
            } else {
                sign = "Gemini"
            }
        case 7:
            if date.day >= 23 {
                sign = "Leo"
            } else {
                sign = "Cancer"
            }
        case 8:
            if date.day >= 23 {
                sign = "Virgo"
            } else {
                sign = "Leo"
            }
        case 9:
            if date.day >= 23 {
                sign = "Libra"
            } else {
                sign = "Virgo"
            }
        case 10:
            if date.day >= 23 {
                sign = "Scorpio"
            } else {
                sign = "Libra"
            }
        case 11:
            if date.day >= 22 {
                sign = "Sagittarius"
            } else {
                sign = "Scorpio"
            }
        case 12:
            if date.day >= 22 {
                sign = "Capricorn"
            } else {
                sign = "Sagittarius"
            }
        default:
            return ""
        }
        return sign
    }
    
    // show Error alert
    
    func showErrorDialog(){
        Utilities.showAlertView(nil, title: "Error", message: "An error has occured, please try again later")
    }
}
