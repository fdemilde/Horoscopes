//
//  UserModule.h
//  MobilePlatform
//
//  Created by Binh Dang on 2/9/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCreds.h"
#import "ServerCommunication.h"

@interface UserModule : NSObject {
    ServerCommunication * sc;
    NSMutableArray* friendList;
    NSUserDefaults *userDefaults;
}

@property (nonatomic, strong) UserCreds *creds;

-(id)initWithUserCreds:(UserCreds *)_creds serverCommunication:(ServerCommunication *)_sc;
- (void)loginWithParams:(NSMutableDictionary *)params andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;
- (void)loginDebug:(NSString *) passphrase andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;
-(void)getUIDWithCompleteBlock:(void (^)(int responseDict))completeBlock;
-(void)lookupID:(NSString *)loginMethod extId:(NSString *)extId andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;
-(void)requestFriendWithUid:(NSNumber*)friendUid andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;
-(void)requestFriendsWithUidList:(NSArray *)uidList andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;
-(void)removeFriendWithUid:(NSNumber*)friendUid andCompleteBlock:(void (^)(int removedUid))completeBlock;
-(void)refreshFriendsWithCompleteBlock:(void (^)(NSArray* responseFriendUidList))completeBlock;
-(void)saveFriendListToUserDefaults;
-(void)getFriendListFromUserDefault;
-(void)logoutWithCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;
-(void)addFriendToFriendList:(NSNumber*)friendId;
-(NSMutableArray*)getFriendList;
-(void)setFriendList:(NSMutableArray *)_friendList;
@end
