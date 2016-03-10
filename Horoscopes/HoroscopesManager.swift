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
        let offset = NSTimeZone.systemTimeZone().secondsFromGMT/3600;
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
            
            let iOSVersion = UIDevice.currentDevice().systemVersion;
            let devideType = UIDevice.currentDevice().model;
            
            //get collected data
            let col = CollectedHoroscope();
            let score = col.getScore()*100
            let strScore = String(format: "%f",score)
            
            let loadCount = XAppDelegate.mobilePlatform.tracker.loadAppOpenCountervalue()
            let loadCountString = String(format: "%d",loadCount)
            
            let version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as! String
            
            let sign = XAppDelegate.userSettings.horoscopeSign
            let signString = String(format: "%d",sign)
            
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
            let expiredTime = NSDate().timeIntervalSince1970 + 600
            CacheManager.cacheGet(GET_DATA_METHOD, postData: postData, loginRequired: NOT_REQUIRED, expiredTime: expiredTime, forceExpiredKey: nil, completionHandler: { (result, error) -> Void in
                Utilities.hideHUD()
                if(error != nil){
                    self.showErrorDialog()
                } else {
                    if let result = result {
//                        print("result == \(result)")
                        if let dataError = result["error"] {
                            let dataErrorAsInt = dataError as! Int
                            if(dataErrorAsInt != 0){ // data error occured
                                self.showErrorDialog()
                            } else {
                                self.data = Utilities.parseNSDictionaryToDictionary(result)
                                if(self.data.count != 0){ self.saveData() }
                                
                                Utilities.postNotification(NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
                            }
                        } else {
                            self.showErrorDialog()
                        }
                    } else {
                        self.showErrorDialog()
                    }
                }
            })
        } else {
            postData.setObject(offsetString, forKey: "tz")
            XAppDelegate.mobilePlatform.sc.sendRequest(REFRESH_DATA_METHOD, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
                if(error != nil){
                    Utilities.hideHUD()
                    self.showErrorDialog()
                } else {
                    if(error != nil){
                        self.showErrorDialog()
                    } else {
                        if let result = response {
                            //                        print("result == \(result)")
                            if let dataError = result["error"] {
                                let dataErrorAsInt = dataError as! Int
                                if(dataErrorAsInt != 0){ // data error occured
                                    self.showErrorDialog()
                                } else {
                                    self.data = Utilities.parseNSDictionaryToDictionary(result)
                                    self.saveData()
                                    Utilities.postNotification(NOTIFICATION_ALL_SIGNS_LOADED, object: nil)
                                }
                            } else {
                                self.showErrorDialog()
                            }
                        } else {
                            self.showErrorDialog()
                        }
                    }
                    Utilities.hideHUD()
                }
            })
        }
        
    }
    
    func sendRateRequestWithTimeTag(timeTag: Int, signIndex: Int, rating: Int, viewcontroller : UIViewController){
        Utilities.showHUD()
        // our sign index is base 0-11 --> we should convert it to base 1-12
        let base1SignIndex = signIndex + 1
        //prepare post data
        let postData = NSMutableDictionary()
        let timeTagString = String(format:"%d",timeTag)
        let base1SignIndexString = String(format:"%d",base1SignIndex)
        let ratingString = String(format: "%d",rating)
        postData.setObject(timeTagString, forKey: "time_tag")
        postData.setObject(base1SignIndexString, forKey: "sign")
        postData.setObject(ratingString, forKey: "rating")
        dispatch_async(dispatch_get_main_queue(),{
            XAppDelegate.mobilePlatform.sc.sendRequest(RATE_HOROSCOPE, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
    //            print(response)
                Utilities.hideHUD()
                if error != nil {
                    Utilities.showError(error)
                } else {
                    let result = Utilities.parseNSDictionaryToDictionary(response)
                    Utilities.postNotification(NOTIFICATION_RATE_HOROSCOPE_RESULT, object: result)
                }
            })
        })
    }
    
    func sendUpdateBirthdayRequest(birthdayString : String,completionHandler: ( responseDict : Dictionary<String, AnyObject>?, error : NSError?) -> Void){
        
        let postData = NSMutableDictionary()
        let birthday = String(format:"%@",birthdayString)
        postData.setObject(birthday, forKey: "birthday")
        XAppDelegate.mobilePlatform.sc.sendRequest(UPDATE_BIRTHDAY, andPostData: postData, andCompleteBlock: { (response,error) -> Void in
            if(error != nil){
                
            } else {
                if let response = response {
                    let result = Utilities.parseNSDictionaryToDictionary(response)
                    completionHandler(responseDict: result,error: error)
                } else {
                    completionHandler(responseDict: nil,error: error)
                }
            }
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
            let indexString = "\(index)"
            let todayPermaLink = self.data["today"]!["permalinks"]![indexString] as! String
            let tomorrowPermaLink = self.data["tomorrow"]!["permalinks"]![indexString] as! String
            //
            horoSigns[index-1].horoscopes.removeAllObjects()
            horoSigns[index-1].permaLinks.removeAllObjects()
            
            horoSigns[index-1].horoscopes.addObject(todayReadings[String(format: "%d", index)]!)
            horoSigns[index-1].horoscopes.addObject(tomorrowReadings[String(format: "%d", index)]!)
            horoSigns[index-1].permaLinks.addObject(String(format: "%@", todayPermaLink))
            horoSigns[index-1].permaLinks.addObject(String(format: "%@", tomorrowPermaLink))
        }
    }
    
    func getSignIndexOfDate(date : NSDate) -> Int{
        for index in 0...11 {
            if(index == 9) { continue } // we ignore Capricorn since its start date is 22/12 and end date is 19/1, this case will return as the last sign
            let horoscope = self.horoscopesSigns[index]
            if((date.compare(horoscope.startDate) == NSComparisonResult.OrderedDescending ||   date.compare(horoscope.startDate) == NSComparisonResult.OrderedSame)
                && (date.compare(horoscope.endDate) == NSComparisonResult.OrderedAscending || date.compare(horoscope.endDate) == NSComparisonResult.OrderedSame)){
                    let dateformatter = NSDateFormatter()
                    dateformatter.dateFormat = "MMM - dd"
                    dateformatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                    _ = dateformatter.stringFromDate(horoscope.startDate)
                    _ = dateformatter.stringFromDate(horoscope.endDate)
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
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let flags = NSCalendarUnit(rawValue: UInt.max)
        let components = gregorian.components(flags, fromDate: date)
        let month = components.month
        let day = components.day
        var sign = ""
        switch month {
        case 1:
            if day >= 20 {
                sign = "Aquarius"
            } else {
                sign = "Capricorn"
            }
        case 2:
            if day >= 19 {
                sign = "Pisces"
            } else {
                sign = "Aquarius"
            }
        case 3:
            if day >= 21 {
                sign = "Aries"
            } else {
                sign = "Pisces"
            }
        case 4:
            if day >= 20 {
                sign = "Taurus"
            } else {
                sign = "Aries"
            }
        case 5:
            if day >= 21 {
                sign = "Gemini"
            } else {
                sign = "Taurus"
            }
        case 6:
            if day >= 22 {
                sign = "Cancer"
            } else {
                sign = "Gemini"
            }
        case 7:
            if day >= 23 {
                sign = "Leo"
            } else {
                sign = "Cancer"
            }
        case 8:
            if day >= 23 {
                sign = "Virgo"
            } else {
                sign = "Leo"
            }
        case 9:
            if day >= 23 {
                sign = "Libra"
            } else {
                sign = "Virgo"
            }
        case 10:
            if day >= 23 {
                sign = "Scorpio"
            } else {
                sign = "Libra"
            }
        case 11:
            if day >= 22 {
                sign = "Sagittarius"
            } else {
                sign = "Scorpio"
            }
        case 12:
            if day >= 22 {
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


 