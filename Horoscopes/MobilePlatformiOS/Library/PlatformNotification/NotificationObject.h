//
//  NotificationObject.h
//  MobilePlatform
//
//  Created by FCS on 2/9/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationObject : NSObject


@property NSString* notification_id;
@property NSString* sender;
@property long created;
@property NSString* alert;
@property NSString* route;
@property NSString* data;
@property NSString* ref;

-(NSString* ) toString;
+(NSString* ) getFilePath;

@end
