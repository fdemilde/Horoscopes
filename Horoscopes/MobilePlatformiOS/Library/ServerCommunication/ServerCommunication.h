//
//  ServerCommunication.h
//  MobilePlatform
//
//  Created by FCS on 2/4/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserCreds.h"


typedef void (^CompleteRequest)(NSString* responseStr);

@interface ServerCommunication : NSObject {
    long tsoffset;
    int clientId;
    NSString* udid;
    NSString* baseUrl;
    NSString* uploadBaseUrl;
    UserCreds *creds;
}


@property (copy, nonatomic) CompleteRequest completeRequest;

- (id)initWithBaseURL: (NSString*)_baseUrl andClientId:(int)_clientId andUserCreds:(UserCreds*)_creds;
- (id)initWithBaseURL:(NSString*)_baseUrl
     andUploadBaseUrl:(NSString*)_uploadBaseUrl
          andClientId:(int)_clientId andUserCreds:(UserCreds*)_creds;

- (void)sendRequestWithFilePath:(NSString*)rpcName
       andUserCredsLoginRequired: (LoginReq)loginRequired
                     andPostData:(NSMutableDictionary*)postData
                     andFilePath:(NSString*)filePath
                andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;

- (void)sendRequest:(NSString *)rpcName
        andPostData:(NSMutableDictionary*)postData
   andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;

- (void)sendRequest:(NSString *)rpcName
  withLoginRequired:(LoginReq)loginRequired
        andPostData:(NSMutableDictionary*)postData
   andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock;

- (BOOL)hasError : (NSDictionary *) responseDict;

@end
