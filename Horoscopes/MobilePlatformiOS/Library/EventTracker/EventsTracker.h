//
//  EventTracker.h
//  Testing
//
//  Created by Binh Dang on 2/5/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerCommunication.h"

#define defaultNumberOfTimesAppOpenSaveKey      @"App_Open_Couter_Save_key"
#define defaultLogPriorityLevel 3
#define logPriorityLevel2 2
#define logPriorityLevel3 3
#define logPriorityLevel4 4
#define logPriorityLevel5 5
#define logPriorityLevel1 1

@class Reachability;

@interface EventsTracker : NSObject {
    int loglevel;
    int ttl;
    long configup;
    BOOL timerrunning;
    BOOL hasInternet;
    BOOL timerIsRunning;
    
    NSMutableArray *events;
    Reachability* hostReach;
    NSTimer *timer;
    ServerCommunication *sc;
    NSUserDefaults *userDefaults;
    
}

@property (nonatomic, retain) NSString *udid;
@property (nonatomic, retain) NSDate *timeInApp;
@property (nonatomic) int appOpenCounter;

- (NSString*)getDeviceInfo;
- (void)saveAppOpenCounter;
- (int)loadAppOpenCountervalue;

- (void)logWithAction:(NSString *)action
                label:(NSString *)label
             priority:(int)priority;

- (id)initWithServerCommunication:(ServerCommunication *)_sc;

@end
