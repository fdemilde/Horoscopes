//
//  EventConfig.swift
//  Horoscopes
//
//  Created by Binh Dang on 12/30/15.
//  Copyright © 2015 Binh Dang. All rights reserved.
//

import Foundation
class EventConfig {
    
    static let defaultLogValue = 3
    
    enum Event: String {
        case extLaunch              = "ext-launch"
        case shareDialog            = "share:dialog"
        case shareSelect            = "share:select"
        case shareCancel            = "share:cancel"
        case shareComplete          = "share:complete"
        case like                   = "like"
        case fbLoginAsk             = "fb:login-ask"
        case fbLoginResult          = "fb:login-result"
        case permNotification       = "perm:notification"
        case permLocation           = "perm:location"
        case firstLoadDailyAsk      = "first-load:daily-ask"
        case firstLoadDailyReply    = "first-load:daily-reply"
        case dailyCommunity         = "daily:community"
        case dailyChooser           = "daily:chooser"
        case dailyOpen           = "daily:open"
        case archiveOpen            = "archive:open"
        case archiveReading         = "archive:reading"
        case fortuneOpen            = "fortune:open"
        case fortuneRead            = "fortune:read"
        case commOpen               = "comm:open"
        case commSwipe              = "comm:swipe"
        case commLoadmore           = "comm:loadmore"
        case commReload             = "comm:reload"
        case notifOpen              = "notif:open"
        case notifRetrieved         = "notif:retrieved"
        case notifSelect            = "notif:select"
        case profileOwn             = "profile:own"
        case profileOther           = "profile:other"
        case profileSwipe           = "profile:swipe"
        case profileLoadmore        = "profile:loadmore"
        case profileReload          = "profile:reload"
        case singlePostOpen         = "single-post:open"
        case settingsNotify         = "settings:notify"
        case fbFriendsOpen          = "fb-friends:open"
        case fbFriendsResult        = "fb-friends:result"
        case dobOpen                = "dob:open"
        case dobSignChange          = "dob:sign-change"
        case dobDobChange           = "dob:dob-change"
        case dobSaveSign            = "dob:save-sign"
        case dobStart               = "dob:start"
        case settingsBug            = "settings:bug"
        case settingsLogout         = "settings:logout"
        case postOpen               = "post:open"
        case postSelect             = "post:select"
        case postSend               = "post:send"
        case postClose              = "post:close"
    }
    
    static let LogLevel1 : Set<Event> = [
        .extLaunch,
        .shareComplete,
        .postSend,
    ]
    
    static let LogLevel2 : Set<Event> = [
        .shareSelect,
        .like,
        .fbLoginResult,
        .permNotification,
        .permLocation,
        .firstLoadDailyReply,
        .settingsNotify
    ]
    
    static let LogLevel3 : Set<Event> = [
        .shareDialog,
        .fbLoginAsk,
        .dailyCommunity,
        .dailyChooser,
        .fortuneRead,
        .commReload,
        .notifSelect,
        .profileOther,
        .profileReload,
        .singlePostOpen,
        .fbFriendsResult,
        .dobSaveSign,
        .dobStart,
        .settingsLogout,
        .postSelect
    ]
    
    static let LogLevel4 : Set<Event> = [
        .shareCancel,
        .dailyOpen,
        .archiveOpen,
        .archiveReading,
        .fortuneOpen,
        .commOpen,
        .commLoadmore,
        .notifOpen,
        .notifRetrieved,
        .profileOwn,
        .profileLoadmore,
        .fbFriendsOpen,
        .dobOpen,
        .settingsBug,
        .postOpen,
        .postClose,
        
    ]
    
    static let LogLevel5 : Set<Event> = [
        .firstLoadDailyAsk,
        .commSwipe,
        .profileSwipe,
        .dobSignChange,
        .dobDobChange,
    ]
    
    class func getLogLevel(eventName : Event) -> Int{
        if LogLevel1.contains(eventName) {
            return 1
        }
        
        
        return defaultLogValue
    }
}