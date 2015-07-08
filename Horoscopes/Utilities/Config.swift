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

// Notification
let NOTIFICATION_RATE_HOROSCOPE_RESULT = "NOTIFICATION_RATE_HOROSCOPE_RESULT"
let NOTIFICATION_ALL_SIGNS_LOADED = "NOTIFICATION_ALL_SIGNS_LOADED"
let NOTIFICATION_SAVE_COLLECTED_HORO_FINISHED = "NOTIFICATION_SAVE_COLLECTED_HORO_FINISHED"
let NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED = "NOTIFICATION_GET_GLOBAL_FEEDS_FINISHED"
let NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED = "NOTIFICATION_GET_FOLLOWING_FEEDS_FINISHED"
let NOTIFICATION_ZWIGGLER_LOGGEDIN   =           "NOTIFICATION_ZWIGGLER_LOGGEDIN"
let NOTIFICATION_SEND_HEART_FINISHED = "NOTIFICATION_SEND_HEART_FINISHED"
let NOTIFICATION_CREATE_POST_FINISHED = "NOTIFICATION_CREATE_POST_FINISHED"


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

let kAnalyticsAccountId = "UA-27398873-10"
let FACEBOOK_APP_ID = "333713683461"

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
}

// Newsfeed

enum NewsfeedType {
    case OnYourMind
    case Story
    case Feeling
}

enum NewsfeedTabType {
    case SignTag
    case Following
}

let SHARE_DIRECT_HEIGHT                     = 235.0 as CGFloat
let SHARE_HYBRID_HEIGHT                     = 400 as CGFloat

