//
//  Config.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/5/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

let XAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

// MARK: Network request
let GET_DATA_METHOD  = "app.horoscopes.checkin" //debug.logrequest for testing event.upload for actual
let REFRESH_DATA_METHOD  = "app.horoscopes.refresh"
let REGISTER_NOTIFICATION_TOKEN = "app.horoscopes.registerapns"
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

// MARK: - Post request
let CREATE_POST = "app.horoscopes.post.create"
let READ_POST = "app.horoscopes.post.get"
let DELETE_POST = "app.horoscopes.post.remove"

// MARK: Follow methods
let FOLLOW = "user.follow"
let UNFOLLOW = "user.unfollow"
let GET_FOLLOWING = "user.following"
let GET_FOLLOWERS = "user.followers"
let IS_FOLLOWING = "user.isfollowing"

// MARK: Profile methods
let GET_PROFILE = "app.horoscopes.profile.get"
let UPDATE_PROFILE = ""
let UPDATE_BIRTHDAY = "app.horoscopes.setbirthday"
let GET_FRIEND_LIST = "app.horoscopes.profile.facebookfriends"

// Notification
let NOTIFICATION_RATE_HOROSCOPE_RESULT = "NOTIFICATION_RATE_HOROSCOPE_RESULT"
let NOTIFICATION_ALL_SIGNS_LOADED = "NOTIFICATION_ALL_SIGNS_LOADED"
let NOTIFICATION_SAVE_COLLECTED_HORO_FINISHED = "NOTIFICATION_SAVE_COLLECTED_HORO_FINISHED"
let NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED = "NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED"
let NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED = "NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED"
let NOTIFICATION_ZWIGGLER_LOGGEDIN   =           "NOTIFICATION_ZWIGGLER_LOGGEDIN"
let NOTIFICATION_SEND_HEART_FINISHED = "NOTIFICATION_SEND_HEART_FINISHED"
let NOTIFICATION_CREATE_POST = "NOTIFICATION_CREATE_POST"


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
let GOOGLE_LOCATION_API = "https://maps.googleapis.com/maps/api/geocode/json?key=AIzaSyD5jrlKA2Sw6qxgtdVlIDsnuEj7AJbpRtk&latlng="

// MARK: Enum Type

enum DailyHoroscopeType {
    case TodayHoroscope
    case TomorrowHoroscope
}

enum ShareViewType {
    case ShareViewTypeDirect
    case ShareViewTypeHybrid
}

enum ShareType {
    case ShareTypeDaily
    case ShareTypeFortune
    case ShareTypeNewsfeed
}

// Newsfeed

enum NewsfeedType {
    case OnYourMind
    case Story
    case Feeling
}

enum NewsfeedTabType {
    case Global
    case Following
}

// Post cell type

enum PostCellType {
    case Newsfeed
    case Profile
}

// settings

enum SettingsType {
    case Notification
    case ChangeName
    case ChangeDOB
    case BugsReport
    case Logout
}

enum BirthdayParentViewControllerType {
    case LoginViewController
    case SettingsViewController
}

let SHARE_DIRECT_HEIGHT                     = 235.0 as CGFloat
let SHARE_HYBRID_HEIGHT                     = 400 as CGFloat

let ADMOD_HEIGHT                     = 50 as CGFloat

let TABBAR_HEIGHT                     = 49 as CGFloat

