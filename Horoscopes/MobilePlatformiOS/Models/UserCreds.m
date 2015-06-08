//
//  UserCreds.m
//  MobilePlatform
//
//  Created by FCS on 2/4/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "UserCreds.h"

NSString * const LOGIN_TOKEN = @"LOGIN_TOKEN";
NSString * const LOGIN_UID = @"LOGIN_UID";
NSString * const UDID = @"UDID";

@implementation UserCreds 

- (id)init{
    if ((self = [super init])){
        NSString *userToken = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_TOKEN];
        NSNumber *userID = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_UID];
        if (userToken) token = userToken;
        if (userID) uid = userID;
    }
    
    return self;
}

- (NSString*) getUDID
{
    if (udid != nil)
        return udid;
    
    udid = [[NSUserDefaults standardUserDefaults] stringForKey:UDID];
    
    if ([udid length] != 0) {
        return udid;
    }
    
    udid = [OpenUDID value];
    [[NSUserDefaults standardUserDefaults] setObject:udid forKey:UDID];
    return udid;
}

- (NSNumber *) getUid {
    return uid;
}

- (void) setUid: (NSNumber *) _uid {
    uid = _uid;
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:LOGIN_UID];
}

- (BOOL) hasToken {
    if(token != nil && [token length] != 0){
        return true;
    }
    return false;
}

- (NSString*) getToken {
    return token;
}

- (void)setToken:(NSString *)_token{
    token = _token;
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:LOGIN_TOKEN];
}

- (void) clearToken {
    token = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_TOKEN];
}

// NOTE: following Android version, why not clear LOGIN_TOKEN?
- (void) clearCreds {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_UID];
    token = nil;
    uid = 0;
}

@end
