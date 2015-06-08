//
//  MobilePlatform.m
//  MobilePlatform
//
//  Created by Binh Dang on 2/5/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "MobilePlatform.h"
#import "ServerConfig.h"

@implementation MobilePlatform
@synthesize sc;
@synthesize tracker;
@synthesize externalRequest;
@synthesize userModule;
@synthesize platformNotiff;

-(id)init {
    self = [super init];
    UserCreds* userCred = [[UserCreds alloc] init];
    self.sc = [[ServerCommunication alloc] initWithBaseURL:BASE_URL andUploadBaseUrl:UPLOAD_BASE_URL andClientId:DATA_CLIENT_ID andUserCreds:userCred];
    self.tracker = [[EventsTracker alloc] initWithServerCommunication:self.sc];
    self.externalRequest = [[ExternalRequest alloc] initWithServerCommunocation:self.sc];
    self.userModule = [[UserModule alloc] initWithUserCreds:userCred serverCommunication:self.sc];
    self.platformNotiff = [[PlatformNotification alloc] initWithServerCommunication:self.sc];
    self.router = [[Router alloc] init];
//    self.serverMessage = [[ServerMessaging alloc] init];
    self.crossSellManager = [[CrossSellManager alloc] init];
    
    return self;
}

@end
