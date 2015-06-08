//
//  ExternalRequest.h
//  MobilePlatform
//
//  Created by Binh Dang on 2/6/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerCommunication.h"
#import "Request.h"

@interface ExternalRequest : NSObject {
    ServerCommunication *sc;
}

-(id)initWithServerCommunocation:(ServerCommunication *)_sc;
-(void)createWithData:(NSString*)data route:(NSString*)route ref:(NSString*)ref alert:(NSString*)alert andCompleteBlock:(void (^)(NSString* responseString))completeBlock;

-(void)lookUp:(NSString*)code andCompleteBlock:(void (^)(Request * responseRequest))completeBlock;
-(Request*)jsonToRequest:(NSDictionary*)json;
@end
