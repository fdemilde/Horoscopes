//
//  PlatformNotification.m
//  MobilePlatform
//
//  Created by FCS on 2/9/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "PlatformNotification.h"
#import <UIKit/UIKit.h>

@implementation PlatformNotification

-(id)initWithServerCommunication:(ServerCommunication*)_sc{
    self = [super init];
    sc = _sc;
    return self;
}

//TODO: using new register for iOS 8  and old one for older
-(void) registerGCM:(BOOL) force {
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
//     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

-(void) sendTo:(NSString*)to withRoute:(NSString*) route withAlert:(Alert*) alert withRef:(NSString*) ref withPush:(int) push withData:(NSString*) data andCompleteBlock:(void (^)(NSDictionary* responseDict))completeBlock{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:to forKey:@"to"];
    if (route != nil)
        [params setObject:route forKey:@"route"];
    if (data != nil)
        [params setObject:data forKey:@"data"];
    if (alert != nil)
        [params setObject:[alert toJson] forKey:@"alert"];
    if (ref != nil)
        [params setObject:ref forKey:@"ref"];
    
    if (push == 0) {
        [params setObject:@"0" forKey:@"push"];
    } else if (push == 1) {
        [params setObject:@"1" forKey:@"push"];
        [params setObject:@"1" forKey:@"get_nopush"];
    }
//    NSLog(@"notification.send params = %@", params);
    [sc sendRequest:@"notification.send" withLoginRequired:REQUIRED andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        completeBlock(responseDict);
    }];

}


-(void) getWithIDString:(NSString*)idString withClear:(BOOL)clear andCompleteBlock:(void (^)(NotificationObject* responseDict))completeBlock{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:idString forKey:@"id"];
    if (clear == YES) {
        [params setObject:@"1" forKey:@"clear"];
    } else {
        [params setObject:@"0" forKey:@"clear"];
    }
    
    [sc sendRequest:@"notification.get" withLoginRequired:OPTIONAL andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        NSDictionary* uidObject = [responseDict objectForKey:@"notif"];
//        DebugLog(@"getWithIDString return = %@" , responseDict);
        NotificationObject* no  = [[NotificationObject alloc] init];
        
        for (NSString* key in uidObject) {
            id notifObject = [uidObject objectForKey:key];
            if (notifObject && [notifObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *notif = (NSDictionary*)notifObject;
                no.data = [notif objectForKey:@"data"];
                no.alert = [notif objectForKey:@"alert"];
                no.created = [[notif objectForKey:@"created"] longValue];
                no.ref = [notif objectForKey:@"ref"];
                no.sender = [notif objectForKey:@"sender"];
                no.route = [notif objectForKey:@"route"];
                no.notification_id = [notif objectForKey:@"notification_id"];
                [self fireLocalNotiffication:no];

            }
        }
        
        completeBlock(no);
    }];

}

-(void) getAllwithSince:(int) since andCompleteBlock:(void (^)(NSArray* responseDict))completeBlock{
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    if (since != 0) {
        [params setObject:[NSString stringWithFormat:@"%d" , since] forKey:@"since"];
    }
    
    [sc sendRequest:@"notification.getall" withLoginRequired:OPTIONAL andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        NSMutableArray* uidObject = [responseDict objectForKey:@"notifs"];
        
        NSArray* notifArray = [[NSArray alloc] initWithArray:[self convertNSArrayToNotificationObjectAndFireLocalNotiff:uidObject]];
        
//        DebugLog(@"getall return = %@" , responseDict);
        
        completeBlock(notifArray);
    }];

}


-(NSArray*)convertNSArrayToNotificationObjectAndFireLocalNotiff:(NSMutableArray*) uidObject {
    NSMutableArray* arrayNotiffs = [[NSMutableArray alloc] init];
    
    for (NSDictionary* notif in uidObject) {
        NotificationObject* no = [[NotificationObject alloc] init];
        no.data = [notif objectForKey:@"data"];
        no.alert = [notif objectForKey:@"alert"];
        no.created = [[notif objectForKey:@"created"] longValue];
        no.ref = [notif objectForKey:@"ref"];
        no.sender = [[notif objectForKey:@"sender"] stringValue];
        no.route = [notif objectForKey:@"route"];
        no.notification_id = [notif objectForKey:@"notification_id"];
        
        [arrayNotiffs addObject:no];
//        NSLog(@"data = %@" , [no toString]);
    }
    
    
//    BINH BINH
//    for (NotificationObject* no in arrayNotiffs) {
//        [self fireLocalNotiffication:no];
//    }

    return arrayNotiffs;
    
}

-(void) clearWithID:(NSString*) idString andCompleteBlock:(void (^)(NSDictionary* responseDict))completeBlock{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:idString forKey:@"id"];
   
    [sc sendRequest:@"notification.clear" withLoginRequired:OPTIONAL andPostData:params  andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        id uidObject = [responseDict objectForKey:@"cleared"];
        
        DebugLog(@"clearWithID return = %@" , responseDict);
        completeBlock(uidObject);
    }];

}

-(void) clearWithListID:(NSArray*) listID andCompleteBlock:(void (^)(NSDictionary* responseDict))completeBlock{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    NSString* allID = @"";
    for (NSString* item in listID) {
        allID = [NSString stringWithFormat:@"%@,%@", allID , item];
    }
    if (allID.length > 0) {
         allID = [allID substringFromIndex:1];
    }
   
    [params setObject:allID forKey:@"id"];
    
    [sc sendRequest:@"notification.clear" withLoginRequired:OPTIONAL andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        id uidObject = [responseDict objectForKey:@"cleared"];
        
        DebugLog(@"clearWithListID return = %@" , responseDict);
   
        completeBlock(uidObject);
    }];

}


- (void)fireLocalNotiffication:(NotificationObject*) notiff {
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.repeatInterval = NSCalendarUnitDay;
    [notification setAlertBody:notiff.data];
//    DebugLog(@"data notiff = %@" , notiff.data);
    NSDate* date = [[NSDate date] dateByAddingTimeInterval:1];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    
    [notification setFireDate:date];
//    DebugLog(@"hour = %ld , minute = %ld" ,(long)hour , (long)minute );
    
    [notification setTimeZone:[NSTimeZone  defaultTimeZone]];
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}



@end
