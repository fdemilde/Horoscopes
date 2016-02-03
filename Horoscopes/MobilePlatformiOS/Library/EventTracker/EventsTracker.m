//
//  EventTracker.m
//  Testing
//
//  Created by Binh Dang on 2/5/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import "EventsTracker.h"
#import <UIKit/UIKit.h>
#import "Reachability.h"

#import "ServerCommunicationConfig.h"

#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

@implementation EventsTracker{
}

@synthesize udid;
@synthesize appOpenCounter;
@synthesize timeInApp;

#pragma mark - CHECK INTERNET CONNECTION

- (void)checkInternetConnection:(NSNotification *)notif {
    Reachability* curReach = [notif object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    if (curReach == hostReach) {
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        hasInternet = !(netStatus == NotReachable);
    }
}

#pragma mark - HELPERS

- (NSString *)toBase64String:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString *ret = [data base64EncodedStringWithOptions:0];
    return ret;
}

/*
 This method will try to load back the appOpenCounter variable from NSUserDefaults
 1. the variable existed --> increase it and save back
 2. the variable NOT existed --> create it, set to 1 and save back
 */
- (void)saveAppOpenCounter {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //NSString *appOpenCounter= [NSString stringWithFormat:@"%d", value];
    //NSLog(@"appOpenCounter = %d", appOpenCounter);
    [defaults setObject:[NSString stringWithFormat:@"%d", appOpenCounter + 1]
                 forKey:defaultNumberOfTimesAppOpenSaveKey];
    [defaults synchronize];
}

- (NSString*)getDeviceInfo{
    NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
    NSString *devideType = [UIDevice currentDevice].model;
    NSString *displayType = @"nonretina";
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        displayType = @"retina";
    }
    
    return [NSString stringWithFormat:@"%@ | %@ | %@", devideType, iOSVersion, displayType];
}

- (int)loadAppOpenCountervalue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *openCounter = [defaults objectForKey:defaultNumberOfTimesAppOpenSaveKey];
    if (openCounter) {
        return [openCounter intValue];
    } else {
        return 0;
    }
}

- (void)saveEvents {
    userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:events forKey:kEvents];
    [userDefaults synchronize];
}

- (NSMutableArray *)getEvents {
    userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:kEvents]) {
        //NSUserDefaults always returns an immutable object. we have to do mutableCopy
        NSMutableArray *savedEvents = [[userDefaults objectForKey:kEvents] mutableCopy];
        [userDefaults removeObjectForKey:kEvents];
        
        // upload remain events
        [self startTimer];
        
        return savedEvents;
    }
    
    return [NSMutableArray array];
}

- (void)deleteUploadedEvents:(NSMutableArray *)uploadedEvents {
    for (NSDictionary *event in uploadedEvents) {
        [events removeObject:event];
    }
}

- (void)addEventWithAction:(NSString *)action label:(NSString *)label priority:(int)priority {
    
    long ts = (long)([[NSDate date] timeIntervalSince1970]);
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                           action, @"event",
                           label, @"info",
                           [NSString stringWithFormat:@"%ld", ts], @"ts",
                           [NSString stringWithFormat:@"%d", priority], @"level", nil];
    //    DebugLog(@"addEventWithAction addEventWithAction %@", event);
    [events addObject:event];
}

- (void)flush {
    // if no internet connection, don't do anything
    if (!hasInternet) {
        DebugLog(@"No internet connection. Stop uploading.");
        return;
    }
    
    // clear ellapse time
    [self clearTimer];
    
    // prepare flush in a new thread
    dispatch_async(dispatch_queue_create("com.floatingcube.queue", 0), ^{
        [self sendEvents];
    });
}

- (void)sendEvents {
    //DebugLog(@"Start uploading events...");
    
    // if there's no event, stop
    if (!events.count) {
        DebugLog(@"No new events. Stop uploading");
        return;
    }
    
    // keep current events size
    NSMutableArray *eventsToUpload = [NSMutableArray array];
    for (NSDictionary *event in events) {
        [eventsToUpload addObject:event];
    }
    
    [self doSend:eventsToUpload];
}

- (void)doSend:(NSMutableArray *)eventsToUpload {
    
    NSMutableDictionary *postData = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self convertNSArrayToJSONString:eventsToUpload], @"events", nil];
    
    [sc sendRequest:EVENT_UPLOAD andPostData:postData andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        //        DebugLog(@"eventsToUpload responseDict %@", responseDict);
        id errorObj = [responseDict objectForKey:@"error"];
        if(errorObj != nil){
            int errorValue = [errorObj intValue];
            if (errorValue == 0) {
//                DebugLog(@"%d event(s) uploaded.", [responseDict[@"uploaded"] intValue]);
                [self deleteUploadedEvents:eventsToUpload];
            } else {
                DebugLog(@"Event upload error: %@", responseDict[@"error_message"]);
            }
        } else {
            DebugLog(@"Event upload error: %@", responseDict);
        }
    }];
}

- (void)startTimer {
    if (timerIsRunning) return;
    timerIsRunning = YES;
    // run flush events in a period of time
    timer = [NSTimer scheduledTimerWithTimeInterval:FLUSHING_TIME
                                             target:self
                                           selector:@selector(flush)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)clearTimer {
    timerIsRunning = NO;
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}

- (NSString*)convertNSArrayToJSONString:(NSArray*)array{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"JSON error: %@", error);
        return @"Error convert Array to JSON string";
    } else {
        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        //NSLog(@"JSON OUTPUT: %@",JSONString);
        return JSONString;
    }
}

/* Get the config for the request */
- (void)getConfig {
    NSLog(@"getConfig getConfig");
    [sc sendRequest:EVENT_GET_CONFIG andPostData:nil andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        if ([[responseDict valueForKey:@"error"] intValue] == 1) {
            DebugLog(@"======= Event Tracker: GetConfig failed");
        } else {
            loglevel = [[responseDict valueForKey:@"logLevel"] intValue];
            ttl = [[responseDict valueForKey:@"TTL"] intValue];
            configup = [[NSDate date] timeIntervalSince1970];
            // save config to user defaults
            [userDefaults setObject:[NSString stringWithFormat:@"%d", loglevel] forKey:EVENT_TRACKER_LOG_LEVEL_SAVE_KEY];
            [userDefaults setObject:[NSString stringWithFormat:@"%d", ttl] forKey:EVENT_TRACKER_TIME_STAMP_SAVE_KEY];
            [userDefaults setInteger:configup forKey:EVENT_TRACKER_LAST_UPDATE_TIME_SAVE_KEY_V2];
            
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
}

#pragma mark - INTERFACES

- (void)logWithAction:(NSString *)action label:(NSString *)label priority:(int)priority {
    if (priority > loglevel) { return; }
    
    [self addEventWithAction:action label:label priority:priority];
    [self startTimer];
}

#pragma mark - INIT

- (id)initWithServerCommunication:(ServerCommunication *)_sc{
    self = [super init];
    if (self) {
        sc = _sc;
        appOpenCounter = [self loadAppOpenCountervalue];
        
        // events
        events = [self getEvents];
        
        // save events when the app is inactive
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(saveEvents)
         name:UIApplicationWillResignActiveNotification
         object:nil];
        
        // register for checking internet connection
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(checkInternetConnection:)
         name:kReachabilityChangedNotification
         object:nil];
        
        hostReach = [Reachability reachabilityWithHostname:@"www.google.com"];
        [hostReach startNotifier];
        
        userDefaults = [NSUserDefaults standardUserDefaults];
        
        // get the log level, ttl and configup that save in user defaults, if not set to the default value
        loglevel = ([userDefaults objectForKey:EVENT_TRACKER_LOG_LEVEL_SAVE_KEY] ? [[userDefaults objectForKey:EVENT_TRACKER_LOG_LEVEL_SAVE_KEY]intValue] : EVENT_TRACKER_LOG_DEFAULT_LEVEL);
        ttl = ([userDefaults objectForKey:EVENT_TRACKER_TIME_STAMP_SAVE_KEY] ? [[userDefaults objectForKey:EVENT_TRACKER_TIME_STAMP_SAVE_KEY] intValue] : 3600 );
        configup = ([userDefaults integerForKey:EVENT_TRACKER_LAST_UPDATE_TIME_SAVE_KEY_V2] ? [userDefaults integerForKey:EVENT_TRACKER_LAST_UPDATE_TIME_SAVE_KEY_V2] : 0);
        
        // get config for first time
        if (((long)[[NSDate date] timeIntervalSince1970] - configup) > ttl) {
            
            dispatch_async(dispatch_queue_create("com.floatingcube.queue", 0), ^{
                [self getConfig];
                [self sendEvents];
            });
            
        } else {
            [self flush];
        }
    }
    return self;
}

@end

