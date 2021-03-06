//
//  Config.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/5/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

let XAppDelegate = UIApplication.shared.delegate as! AppDelegate


var defaultCalendar : Calendar {
    let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    return calendar
}

var calendarWithTimeOffset : Calendar {
    var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: TIMEZONE_OFFSET)!
    return calendar
}

let defaultYear = 1900
var yearArray : [Int] {
    var result = [Int]()
    let calendar = defaultCalendar
    var nineteenYearsToNow = 1925
    var thirteenYearsToNow = 2002
    if #available(iOS 8.0, *) {
        nineteenYearsToNow = (calendar as NSCalendar).component(.year, from: (calendar as NSCalendar).date(byAdding: .year, value: -90, to: Date(), options: .matchStrictly)!)
    } else {
        // Fallback on earlier versions
    }
    if #available(iOS 8.0, *) {
        thirteenYearsToNow = (calendar as NSCalendar).component(.year, from: (calendar as NSCalendar).date(byAdding: .year, value: -13, to: Date(), options: .matchStrictly)!)
    } else {
        // Fallback on earlier versions
    }
    
    var year = thirteenYearsToNow
    repeat {
        result.append(year)
        year -= 1
    } while(year >= nineteenYearsToNow)
    
    return result
}

// MARK: - NSUserDefaults Key
let notificationKey = "notification"
let isNotLoggedInFacebookFirstTimeKey = "isNotLoggedInFacebookFirstTimeKey"
let V2_NOTIF_CHECK = "V2_NOTIF_CHECK"
let HAVE_SHOWN_WELCOME_SCREEN = "HAVE_SHOWN_WELCOME_SCREEN"

// MARK: - Post Date Format

let postDateFormat = "h:mm a, MMM dd, yyyy"

// MARK: Network request
let GET_DATA_METHOD  = "app.horoscopes.checkin" //debug.logrequest for testing event.upload for actual
let REFRESH_DATA_METHOD  = "app.horoscopes.refresh"
let REGISTER_SERVER_NOTIFICATION_TOKEN = "notification.registerpush"
let RATE_HOROSCOPE = "app.horoscopes.ratehoroscope"

let GET_FORTUNE_METHOD = "app.horoscopes.getfortune"
let REPORT_ISSUE_METHOD = "app.horoscopes.reportissue"
let SEND_USER_UPDATE = "app.horoscopes.profile.update"

// MARK: Network - Social
let GET_USER_FEED = "app.horoscopes.feed.user"
let GET_GLOBAL_FEED = "app.horoscopes.feed.global"
let GET_FOLLOWING_FEED = "app.horoscopes.feed.following"
let SEND_HEART = "app.horoscopes.heart.send"

let SEND_HEART_USER_POST_TYPE = "userpost"
let REGISTER_SHARE = "app.horoscopes.share.register"

// MARK: - Post request
let CREATE_POST = "app.horoscopes.post.create"
let GET_POST = "app.horoscopes.post.get"
let DELETE_POST = "app.horoscopes.post.remove"
let POST_REPORT = "app.horoscopes.post.report"
let POST_GETCOMMENTS = "app.horoscopes.post.getcomments"

// MARK: Comment Methods
let POST_COMMENT_CREATE = "app.horoscopes.post.comment.create"
let POST_COMMENTS_GET = "app.horoscopes.post.comment.get"
let POST_COMMENT_REMOVE = "app.horoscopes.post.comment.remove"


// MARK: Follow methods
let FOLLOW = "user.follow"
let UNFOLLOW = "user.unfollow"
let GET_CURRENT_USER_FOLLOWING = "user.following"
let GET_CURRENT_USER_FOLLOWERS = "user.followers"
let IS_FOLLOWING = "user.isfollowing"

// MARK: Profile methods
let GET_PROFILE = "app.horoscopes.profile.get"
let UPDATE_PROFILE = ""
let UPDATE_BIRTHDAY = "app.horoscopes.setbirthday"
let GET_FRIEND_LIST = "app.horoscopes.profile.facebookfriends"
let GET_OTHER_USER_FOLLOWING = "app.horoscopes.profile.following"
let GET_OTHER_USER_FOLLOWERS = "app.horoscopes.profile.followers"
let GET_PROFILE_COUNTS = "app.horoscopes.profile.counts"
let GET_LIKED_USERS = "app.horoscopes.post.hearts"

// MARK: Notification method

// Notification
let NOTIFICATION_RATE_HOROSCOPE_RESULT = "NOTIFICATION_RATE_HOROSCOPE_RESULT"
let NOTIFICATION_ALL_SIGNS_LOADED = "NOTIFICATION_ALL_SIGNS_LOADED"
let NOTIFICATION_SAVE_COLLECTED_HORO_FINISHED = "NOTIFICATION_SAVE_COLLECTED_HORO_FINISHED"
let NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED = "NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED"
let NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED = "NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED"
let NOTIFICATION_ZWIGGLER_LOGGEDIN   =           "NOTIFICATION_ZWIGGLER_LOGGEDIN"
let NOTIFICATION_SEND_HEART_FINISHED = "NOTIFICATION_SEND_HEART_FINISHED"
let NOTIFICATION_CREATE_POST = "NOTIFICATION_CREATE_POST"
let NOTIFICATION_UPDATE_POST = "NOTIFICATION_UPDATE_POST"
let NOTIFICATION_FOLLOW = "NOTIFICATION_FOLLOW"
let NOTIFICATION_UNFOLLOW = "NOTIFICATION_UNFOLLOW"
let NOTIFICATION_UPDATE_FOLLOWING_STATUS_FINISHED = "NOTIFICATION_UPDATE_FOLLOWING_STATUS_FINISHED"
let NOTIFICATION_TABLE_VIEW_SCROLL_TO_TOP = "NOTIFICATION_TABLE_VIEW_SCROLL_TO_TOP"

// MARK: event tracker constances
let defaultAppOpenAction            = "OpenApp"
let defaultNotificationQuestion     = "notif_qn"
let defaultHoroscopeChooser         = "chooser"
let defaultViewHoroscope            = "view"
let defaultViewArchive              = "archive_view"
let defaultChangeSetting            = "setting_change"
let defaultFacebook                 = "facebook"
let defaultNotification             = "notification"
let defaultRefreshClick             = "refresh"
let defaultIDFAEventKey             = "IDFA"

// MARK: ID
let kAnalyticsAccountId = "UA-27398873-10"
let FACEBOOK_APP_ID = "333713683461"
let ADMOD_ID = "ca-app-pub-3099085126740540/3213172514"

// MARK: Settings
let NOTIFICATION_SETTING_DATE_FORMAT = "hh:mm a"
let NOTIFICATION_SETTING_DEFAULT_TIME = "08:00 AM"

// MARK: Location
let LOCATION_IOS_KEY = "AIzaSyBFMxh4ame-g9U93NBKSF1pgIsi2UkinpY"
let GOOGLE_LOCATION_API = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyBFMxh4ame-g9U93NBKSF1pgIsi2UkinpY&latlng="
let LAST_LOCATION_DICT_KEY = "LAST_LOCATION_DICT_KEY"
let LAST_LOCATION_EXPIRE_TIME_KEY = "LAST_LOCATION_EXPIRE_TIME_KEY"

// Timezone offset = -8
let TIMEZONE_OFFSET = -28800

// MARK: post type
// postType: image name, label, server type
let postTypes = [
    NewsfeedType.howHoroscope: ("post_type_horoscope", "How’s your horoscope?","howhoroscope"),
    NewsfeedType.shareAdvice: ("post_type_advice", "Share some daily advice","shareadvice"),
    NewsfeedType.onYourMind: ("post_type_mind", "What's on your mind today?","onyourmind"),
    NewsfeedType.fortune: ("post_type_fortune", "Write a fortune","fortune")
]

// MARK: Enum Type

enum DailyHoroscopeType {
    case todayHoroscope
    case tomorrowHoroscope
    case collectedHoroscope
}

enum ShareViewType {
    case shareViewTypeDirect
    case shareViewTypeHybrid
}

enum ShareType {
    case shareTypeDaily
    case shareTypeFortune
    case shareTypeNewsfeed
}

// Newsfeed

enum NewsfeedType {
    case onYourMind
    case shareAdvice
    case howHoroscope
    case fortune
    case invalid
}

enum NewsfeedTabType {
    case global
    case following
    case both
}

// Post cell type

enum PostCellType {
    case newsfeed
    case profile
}

// settings

enum SettingsType {
    case notification
    case changeDOB
    case changeSign
    case bugsReport
    case logout
}

enum BirthdayParentViewControllerType {
    case loginViewController
    case settingsViewController
}

// server notification
enum ServerNotificationType {
    case sendHeart
    case follow
    case `default`
}

// Archive View
enum ArchiveViewType {
    case calendar
    case horoscopeDetail
}

// MARK: height
let SHARE_DIRECT_HEIGHT                     = 235.0 as CGFloat
let SHARE_HYBRID_HEIGHT                     = 400 as CGFloat
let ADMOD_HEIGHT                     = 50 as CGFloat
let TABBAR_HEIGHT                     = 49 as CGFloat
let NAVIGATION_BAR_HEIGHT = 50 as CGFloat

// MARK: Error code
let ERROR_CODE_NO_INTERNET = 8008135

struct ScreenSize
{
    static let SCREEN_WIDTH = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS =  UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6 = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
}

// MARK: MAX NO LINES
let MAX_LINES_IP4 = 4 as CGFloat
let MAX_LINES_IP5 = 8 as CGFloat
let MAX_LINES_IP6 = 13 as CGFloat
let MAX_LINES_IP6P = 15 as CGFloat



