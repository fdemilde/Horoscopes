//
//  UserModule.m
//  MobilePlatform
//
//  Created by Binh Dang on 2/9/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "UserModule.h"
#define FRIEND_LIST @"FRIEND_LIST"

@implementation UserModule
@synthesize creds;

-(id)initWithUserCreds:(UserCreds *)_creds serverCommunication:(ServerCommunication *)_sc{
    self = [super init];
    userDefaults = [NSUserDefaults standardUserDefaults];
    self.creds = _creds;
    sc = _sc;
    [self getFriendListFromUserDefault];
    return self;
}

- (void)loginWithParams:(NSMutableDictionary *)params andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
    if(params == nil){
        params = [[NSMutableDictionary alloc] init];
    }
    [sc sendRequest:@"user.login" andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        id tokenObject = [responseDict objectForKey:@"token"];
        if(tokenObject != nil){
            NSString * tokenValue = tokenObject;
            [creds setToken:tokenValue];
            DebugLog(@"testInvalidLogin tokenValue = %@",tokenValue);
        }
        id uidObject = [responseDict objectForKey:@"uid"];
        if(uidObject != nil){
            NSNumber * uid = uidObject;
            [creds setUid:uid];
            DebugLog(@"testInvalidLogin uid = %@",uid);
        }
        [self refreshFriendsWithCompleteBlock:^(NSArray *responseArray) {
            DebugLog(@"loginWithParams refresh list = %@", responseArray);
            completeBlock(responseDict, error);
        }];
        
        return;
    }];
}

-(void)loginDebug:(NSString *) passphrase andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
    NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:passphrase, @"passphrase", @"debug", @"login_method", nil];
    
    [self loginWithParams:params andCompleteBlock:completeBlock];
}

-(void)getUIDWithCompleteBlock:(void (^)(int responseDict))completeBlock{
    [sc sendRequest:@"user.getuid" withLoginRequired:REQUIRED andPostData:nil andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        id uidObject = [responseDict objectForKey:@"uid"];
        if(uidObject != nil){
            int uid = [uidObject intValue];
            completeBlock(uid);
            return;
        }
        completeBlock(0);
    }];
}

-(void)lookupID:(NSString *)loginMethod extId:(NSString *)extId andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:loginMethod forKey:@"login_method"];
    [params setObject:extId forKey:@"extid"];
    [sc sendRequest:@"user.lookupid" withLoginRequired:REQUIRED andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        id resultObj = [responseDict objectForKey:@"found_uid"];
        if(resultObj != nil){
            NSDictionary* result = resultObj;
            completeBlock(result, error);
            return;
        }
        completeBlock(nil,error);
    }];
}

-(void)requestFriendWithUid:(NSNumber*)friendUid andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:@"%@", friendUid] forKey:@"uid"];
    
    DebugLog(@"requestFriendsWithUidList uidParam = %@", params);
    [sc sendRequest:@"user.requestfriend" withLoginRequired:REQUIRED andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        DebugLog(@"requestFriendWithUid responseDict = %@", responseDict);
        
        id friendObject = [responseDict objectForKey:@"friend"];
        DebugLog(@"testRequestFriend testRequestFriend = %@", friendObject);
        if(friendObject != nil && [friendObject isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* friendDict = friendObject;
            for (id friendUid in friendDict) {
                int value = [[friendDict objectForKey:friendUid] intValue];
                // check if is friend
                if(value == 1){
                    NSNumber *friendUidNumber = [NSNumber numberWithInt:[friendUid intValue]];
//                    DebugLog(@"testRequestFriend friendUidNumber = %@", friendUidNumber);
                    [friendList addObject:friendUidNumber];
                    
//                    DebugLog(@"serializeFriendList OUTPUT: %@", [userDefaults objectForKey:FRIEND_LIST]);
                }
            }
            [self saveFriendListToUserDefaults];
            completeBlock(friendDict, error);
            return;
        }
        
        completeBlock(nil, error);
    }];
}

-(void)requestFriendsWithUidList:(NSArray *)uidList andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
    
    NSString* uidsString = [uidList componentsJoinedByString:@","];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:@"%@", uidsString] forKey:@"uid"];
    [sc sendRequest:@"user.requestfriend" withLoginRequired:REQUIRED andPostData:params andCompleteBlock:completeBlock];
}

-(void)removeFriendWithUid:(NSNumber*)friendUid andCompleteBlock:(void (^)(int removedUid))completeBlock{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:@"%@", friendUid] forKey:@"uid"];
//    DebugLog(@"friend list BEFORE remove = %@ - friend uid = %@", friendList, friendUid);
     [self removeFriendFromFriendList:friendUid];
    [self saveFriendListToUserDefaults];
//    DebugLog(@"friend list AFTER remove = %@", friendList);
    [sc sendRequest:@"user.removefriend" withLoginRequired:REQUIRED andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        id removedObject = [responseDict objectForKey:@"removed"];
        if(removedObject != nil){
            int removedUid = [removedObject intValue];
            completeBlock(removedUid);
            return;
        }
        completeBlock(0);
    }];
}

-(void)removeFriendsWithUidList:(NSArray *)uidList andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
    
    NSString* uidsString = [uidList componentsJoinedByString:@","];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:[NSString stringWithFormat:@"%@", uidsString] forKey:@"uid"];
    DebugLog(@"friend list BEFORE remove = %@", friendList);
    [self removeFriendsFromFriendList:uidList];
    [self saveFriendListToUserDefaults];
    DebugLog(@"friend list AFTER remove = %@", friendList);
    [sc sendRequest:@"user.removefriend" withLoginRequired:REQUIRED andPostData:params andCompleteBlock:completeBlock];
}

-(BOOL)isFriend:(NSNumber*)uid{
    return [friendList containsObject:uid];
}

/**
 * Will query the server for the friend list and update the cached list.
 * @return The list of friend IDs
 */
-(void)refreshFriendsWithCompleteBlock:(void (^)(NSArray* responseFriendUidList))completeBlock{
    [sc sendRequest:@"user.listfriends" withLoginRequired:REQUIRED andPostData:nil andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        
        id friendsObject = [responseDict objectForKey:@"friends"];
        DebugLog(@"testListFriend testListFriend = %@", friendsObject);
        if(friendsObject != nil){
            NSMutableArray * friends = [[NSMutableArray alloc]initWithArray:friendsObject];
            [self setFriendList:friends];
            [self saveFriendListToUserDefaults];
            completeBlock(friends);
            return;
        }
        completeBlock(nil);
    }];
}

/**
 * Will return the friend List if it is cached. If not cached, does a server lookup but should never happen since
 * login will refresh the friend list.
 * @return list of friend IDs
 */
-(NSMutableArray*)getFriendList{
    return friendList;
}

-(void)setFriendList:(NSMutableArray *)_friendList{
    friendList = _friendList;
}

-(void)saveFriendListToUserDefaults{
    [userDefaults setObject:friendList forKey:FRIEND_LIST];
//    DebugLog(@"serializeFriendList OUTPUT: %@", [userDefaults objectForKey:FRIEND_LIST]);
}

-(void)getFriendListFromUserDefault{
    friendList = [userDefaults objectForKey:FRIEND_LIST];
//    DebugLog(@"serializeFriendList OUTPUT: %@", [userDefaults objectForKey:FRIEND_LIST]);
    if(friendList == nil){
        friendList = [[NSMutableArray alloc] init];
        return;
    }
}

-(void)logoutWithCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
    [sc sendRequest:@"user.logout" withLoginRequired:REQUIRED andPostData:nil andCompleteBlock:completeBlock];
    [self clearCreds];
}
-(void)clearCreds{
    [creds clearCreds];
    friendList = [[NSMutableArray alloc] init];
    [userDefaults removeObjectForKey:FRIEND_LIST];
}

-(void)addFriendToFriendList:(NSNumber*)friendId{
    [friendList addObject:friendId];
}

-(void)removeFriendFromFriendList:(NSNumber *)uid{
    NSMutableArray* removeList = [[NSMutableArray alloc] init];
    for (NSNumber* friendId in friendList) {
        if([friendId intValue] == [uid intValue]){
            [removeList addObject:friendId];
        }
    }
    
    for (NSNumber* removeId in removeList) {
        [friendList removeObject:removeId];
    }
}

-(void)removeFriendsFromFriendList:(NSArray *)uidList{
    NSMutableArray* removeList = [[NSMutableArray alloc] init];
    for (NSNumber* removedUid in uidList) {
        for (NSNumber* friendId in friendList) {
            if([friendId intValue] == [removedUid intValue]){
                [removeList addObject:friendId];
            }
        }
    }
    
    for (NSNumber* removeId in removeList) {
        [friendList removeObject:removeId];
    }
}
@end
