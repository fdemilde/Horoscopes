//
//  NotificationObject.m
//  MobilePlatform
//
//  Created by FCS on 2/9/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "NotificationObject.h"

@implementation NotificationObject


- (id) initWithNotificationID:(NSString*) notifId withSender:(NSString*) sender withTimeCreated:(long) created withAlert:(NSString*) alert withRoute:(NSString*)route withData:(NSString*) data withRef:(NSString*)ref{
    self = [super init];
    
    _notification_id = notifId;
    _sender = sender;
    _created = created;
    _alert = alert;
    _route = route;
    _data = data;
    _ref = ref;
    
    return self;
}


- (NSInteger) getIDInt {
    if (_notification_id == nil) {
        return 0;
    }
    NSArray* items = [_notification_id componentsSeparatedByString:@"_"];
    NSString* idIntString = [items objectAtIndex:0];
    DebugLog(@"idIntString = %@" , idIntString);
    return [idIntString integerValue];
}

-(NSString* ) toString {
    NSString* result = [NSString stringWithFormat:@" _notification_id = %@ _sender = %@  _data = %@" , _notification_id , _sender , _data];
    return result;
}


@end
