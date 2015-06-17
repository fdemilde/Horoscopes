//
//  Config.swift
//  Horoscopes
//
//  Created by Binh Dang on 6/5/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

import Foundation

let XAppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

// Network request
let GET_DATA_METHOD  = "app.horoscopes.checkin" //debug.logrequest for testing event.upload for actual
let REFRESH_DATA_METHOD  = "app.horoscopes.refresh"
let REGISTER_NOTIFICATION_TOKEN = "app.horoscopes.registerapns"
let RATE_HOROSCOPE = "app.horoscopes.ratehoroscope"

// Notification
let NOTIFICATION_RATE_HOROSCOPE_RESULT = "NOTIFICATION_RATE_HOROSCOPE_RESULT"
let NOTIFICATION_ALL_SIGNS_LOADED = "NOTIFICATION_ALL_SIGNS_LOADED"

// event tracker constances
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