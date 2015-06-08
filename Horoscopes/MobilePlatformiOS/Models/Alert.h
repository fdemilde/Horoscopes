//
//  Alert.h
//  MobilePlatform
//
//  Created by Binh Dang on 2/6/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Alert : NSObject {
    NSString* alertjson;
}

@property (nonatomic, strong) NSString* body;
@property (nonatomic, strong) NSString* body_loc_key;
@property (nonatomic, strong) NSString* body_loc_args;
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* title_loc_key;
@property (nonatomic, strong) NSString* title_loc_args;
@property (nonatomic, strong) NSString* view;
@property (nonatomic, strong) NSString* view_loc_key;
@property (nonatomic, strong) NSString* cancel;
@property (nonatomic, strong) NSString* cancel_loc_key;
@property (nonatomic, strong) NSString* type;
@property (nonatomic)  int priority;

-(id)init;
-(NSString *)toJson;
-(NSString *)toString;

@end
