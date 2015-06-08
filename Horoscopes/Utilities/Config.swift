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