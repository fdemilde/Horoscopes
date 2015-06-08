//
//  ExternalRequest.m
//  MobilePlatform
//
//  Created by Binh Dang on 2/6/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "ExternalRequest.h"

@implementation ExternalRequest

-(id)initWithServerCommunocation:(ServerCommunication *)_sc{
    self = [super init];
    sc = _sc;
    return self;
}

-(void)createWithData:(NSString*)data route:(NSString*)route ref:(NSString*)ref alert:(NSString*)alert andCompleteBlock:(void (^)(NSString* responseString))completeBlock{
    NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
    [params setObject:ref forKey:@"ref"];
    if(data != nil) [params setObject:data forKey:@"data"];
    if(route != nil) [params setObject:route forKey:@"route"];
    if(alert != nil) [params setObject:alert forKey:@"alert"];
    
    [sc sendRequest:@"extrequest.create" andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        id errorObject = [responseDict objectForKey:@"error"];
        if(errorObject != nil){
            int error = [errorObject intValue];
            if(error == 0){ // NO Error
                NSString* codeResponse = [responseDict objectForKey:@"code"];
                if(codeResponse != nil){
                    DebugLog(@"createWithData codeResponse %@", codeResponse);
                    NSString * code = codeResponse;
                    DebugLog(@"1.a. create = : %@", code);
                    completeBlock(code);
                    return;
                }
            }
        }
        completeBlock(nil);
        return;
    }];
}

/*
 * Look up a specific code for a request link.
 * @param code Code of the request to look up. Can be entire link URL
 * @return Request object that contains information of the request
 */
-(void)lookUp:(NSString*)code andCompleteBlock:(void (^)(Request * responseRequest))completeBlock{
    NSMutableDictionary *params= [[NSMutableDictionary alloc] initWithObjectsAndKeys:code,@"code", nil];
    
    [sc sendRequest:@"extrequest.lookup" andPostData:params andCompleteBlock:^(NSDictionary *responseDict, NSError *error) {
        id errorObject = [responseDict objectForKey:@"error"];
        if(errorObject != nil){
            int error = [errorObject intValue];
            if(error == 0){ // NO Error
                NSDictionary* codeResponse = [responseDict objectForKey:@"request"];
                if(codeResponse != nil){
                    Request * request = [self jsonToRequest:codeResponse];
                    DebugLog(@"lookUp Request to String %@", [request toString]);
                    completeBlock(request);
                } else {
                    DebugLog(@"lookUp responseJson NULL");
                }
            }
        }
    }];
}

-(Request*)jsonToRequest:(NSDictionary*)alertDict{
    Request* request = [[Request alloc] init];
    NSString* alertValue = [alertDict objectForKey:@"alert"];
    if(alertValue != nil){
        request.alert = alertValue;
    }
    NSString* codeValue = [alertDict objectForKey:@"code"];
    if(codeValue != nil){
        request.code = codeValue;
    }
    NSLog(@"alertDict alertDict %@",alertDict);
    long long createdValue = [[alertDict objectForKey:@"created"] longLongValue];
    request.created = createdValue;

    NSString* dataValue = [alertDict objectForKey:@"data"];
    if(dataValue != nil){
        request.data = dataValue;
    }
    NSString* routeValue = [alertDict objectForKey:@"route"];
    if(routeValue != nil){
        request.route = routeValue;
    }
    NSString* refValue = [alertDict objectForKey:@"ref"];
    if(refValue != nil){
        request.ref = refValue;
    }
    return request;
}

@end
