//
//  Request.h
//  MobilePlatform
//
//  Created by Binh Dang on 2/6/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Request : NSObject
@property (nonatomic, strong) NSString* code;
@property (nonatomic) long long created;
@property (nonatomic, strong) NSString* ref;
@property (nonatomic, strong) NSString* route;
@property (nonatomic, strong) NSString* alert;
@property (nonatomic, strong) NSString* data;

-(NSString *)toString;
-(id)init;
@end
