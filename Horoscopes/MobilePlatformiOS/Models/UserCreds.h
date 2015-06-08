//
//  UserCreds.h
//  MobilePlatform
//
//  Created by FCS on 2/4/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenUDID.h"

typedef enum LoginReq
{
    REQUIRED,
    OPTIONAL,
    NOT_REQUIRED
} LoginReq;

@interface UserCreds : NSObject {
    NSNumber* uid;
    NSString* token;
    NSString* udid;
}

- (NSString*) getUDID;
- (NSNumber *) getUid;
- (void) setUid:(NSNumber *) _uid;
- (BOOL) hasToken;
- (NSString*) getToken;
- (void)setToken:(NSString *)_token;
- (void) clearToken;
- (void) clearCreds;

@end
