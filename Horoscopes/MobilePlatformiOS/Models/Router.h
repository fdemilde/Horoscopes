//
//  Router.h
//  MobilePlatform
//
//  Created by Binh Dang on 2/11/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegExCategories.h"

@interface Router : NSObject {
    NSMutableArray* routes;
    NSMutableDictionary* originals;
    NSMutableDictionary* handlers;
}
@property (copy)void (^doStuff)(void);
-(NSString *)toRegex:(NSString*)route;
-(int) routeCount;
-(void)addRoute:(NSString *)route blockCode:(void(^)(NSDictionary* param))block;
-(void)handleRoute:(NSString*) url;
@end
