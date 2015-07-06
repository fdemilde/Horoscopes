//
//  ServerConfig.h
//  EventsTracker
//
//  Created by Floating Cube Test Account on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef EventsTracker_ServerConfig_h
#define EventsTracker_ServerConfig_h

#define BASE_URL @"http://dv7.zwigglers.com/mrest/rest/"
#define UPLOAD_BASE_URL @"http://upload.dv7.zwigglers.com/mrest/rest/"
#define TAG @"EventsTracker"

/*
 Hieu
 
 testing ID --> need to update with the right one
 */
#define DATA_CLIENT_ID 202
#define EVENT_CLIENT_ID 200

/*
 END
 */

#define DATA_KEY @"events"

#define KEY_ROWID @"id"
#define KEY_EVENT @"event"
#define KEY_INFO @"info"
#define KEY_TS @"ts"
#define KEY_PRIORITYLEVEL @"level"

#define EVENT_TRACKER_LOG_LEVEL_SAVE_KEY @"EventTrackerLogLevel"
#define EVENT_TRACKER_LOG_DEFAULT_LEVEL 5
#define EVENT_TRACKER_TIME_STAMP_SAVE_KEY @"EventTrackerTTL"
#define EVENT_TRACKER_LAST_UPDATE_TIME_SAVE_KEY @"EventTrackerLastConfig"

#define minimumTimeBetweenSendingDataFlush 15L
#define getConfigMethod @"event.getconfig"

#define REPORT_ISSUE_METHOD @"app.horoscopes.reportissue"
#define REFRESH_DATA_METHOD @"app.horoscopes.refresh"
#define EVENT_UPLOAD @"event.upload"
#define GET_FORTUNE_METHOD @"app.horoscopes.getfortune"
#define REGISTER_NOTIFICATION_TOKEN @"app.horoscopes.registerapns"
#define RATE_HOROSCOPE @"app.horoscopes.ratehoroscope"

#endif
