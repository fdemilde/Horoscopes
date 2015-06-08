//
//  MobilePlatform.h
//  MobilePlatform
//
//  Created by Binh Dang on 2/5/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerCommunication.h"
#import "EventsTracker.h"
#import "ExternalRequest.h"
#import "UserModule.h"
#import "PlatformNotification.h"
#import "Router.h"
#import "CrossSellManager.h"

@interface MobilePlatform : NSObject

@property (nonatomic, strong) ServerCommunication* sc;
@property (nonatomic, strong) EventsTracker* tracker;

@property (nonatomic, strong) ExternalRequest* externalRequest;
@property (nonatomic, strong) UserModule* userModule;
@property (nonatomic, strong) PlatformNotification* platformNotiff;
@property (nonatomic, strong) Router* router;
@property (nonatomic, strong) CrossSellManager* crossSellManager;

@end
