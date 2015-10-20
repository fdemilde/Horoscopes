//
//  NotificationObject.m
//  MobilePlatform
//
//  Created by FCS on 2/9/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "NotificationObject.h"
#define kNotificationId     @"kNotificationId"
#define kSender             @"kSender"
#define kCreated            @"kCreated"
#define kAlert              @"kAlert"
#define kRoute              @"kRoute"
#define kData               @"kData"
#define kRef                @"kRef"

@implementation NotificationObject


- (id) initWithNotificationID:(NSString*) notifId withSender:(NSString*) sender withTimeCreated:(long) created withAlert:(NSString*) alert withRoute:(NSString*)route withData:(NSString*) data withRef:(NSString*)ref withType:(NSString*)type{
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
    NSString* result = [NSString stringWithFormat:@" _notification_id = %@ || _sender = %@ || route = %@" , _notification_id , _sender , _route];
    return result;
}

#pragma mark - encode/decode
- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        _notification_id = [aDecoder decodeObjectForKey:kNotificationId];
        _sender = [aDecoder decodeObjectForKey:kSender];
        _created = [aDecoder decodeInt64ForKey:kCreated];
        _alert = [aDecoder decodeObjectForKey:kAlert];
        _route = [aDecoder decodeObjectForKey:kRoute];
        _data = [aDecoder decodeObjectForKey:kData];
        _ref = [aDecoder decodeObjectForKey:kRef];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.notification_id forKey:kNotificationId];
    [aCoder encodeObject:self.sender forKey:kSender];
    [aCoder encodeInt64:self.created forKey:kCreated];
    [aCoder encodeObject:self.alert forKey:kAlert];
    [aCoder encodeObject:self.route forKey:kRoute];
    [aCoder encodeObject:self.data forKey:kData];
    [aCoder encodeObject:self.ref forKey:kRef];
}

+ (NSString *)getFilePath{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL* url = [manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return [url URLByAppendingPathComponent:@"NotificationObject"].path;
}


@end
