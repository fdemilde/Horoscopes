//
//  ServerCommunicationConfig.h
//  MobilePlatform
//
//  Created by FCS on 2/4/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#ifndef MobilePlatform_ServerCommunicationConfig_h
#define MobilePlatform_ServerCommunicationConfig_h

#define VERSION @"1.0"
#define NO_ERROR                    0
#define HAS_ERROR                   1

#define kEvents @"events"

#define EVENT_GET_CONFIG @"event.getconfig"
#define EVENT_UPLOAD @"event.upload"

#define FLUSHING_TIME 3L

#define EVENT_TRACKER_LOG_LEVEL_SAVE_KEY @"EventTrackerLogLevel"
#define EVENT_TRACKER_LOG_DEFAULT_LEVEL 5
#define EVENT_TRACKER_TIME_STAMP_SAVE_KEY @"EventTrackerTTL"
#define EVENT_TRACKER_LAST_UPDATE_TIME_SAVE_KEY @"EventTrackerLastConfig"

#define TS_INVALID

#endif
