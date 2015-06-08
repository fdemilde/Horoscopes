//
//  PlatformNotification.h
//  MobilePlatform
//
//  Created by FCS on 2/9/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServerCommunication.h"
#import "Alert.h"
#import "NotificationObject.h"

@interface PlatformNotification : NSObject {
    ServerCommunication* sc;
}
-(void) registerGCM:(BOOL) force;

-(id)initWithServerCommunication:(ServerCommunication*)sc;

-(void) sendTo:(NSString*)to withRoute:(NSString*) route withAlert:(Alert*) alert withRef:(NSString*) ref withPush:(int) push withData:(NSString*) data andCompleteBlock:(void (^)(int responseDict))completeBlock;

-(void) getWithIDString:(NSString*)idString withClear:(BOOL)clear andCompleteBlock:(void (^)(NotificationObject* responseDict))completeBlock;

-(void) getAllwithSince:(int) since andCompleteBlock:(void (^)(NSArray* responseDict))completeBlock;

-(void) clearWithID:(NSString*) idString andCompleteBlock:(void (^)(NSDictionary* responseDict))completeBlock;

-(void) clearWithListID:(NSArray*) listID andCompleteBlock:(void (^)(NSDictionary* responseDict))completeBlock;




@end
