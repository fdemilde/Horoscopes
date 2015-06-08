//
//  Request.m
//  MobilePlatform
//
//  Created by Binh Dang on 2/6/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "Request.h"

@implementation Request

@synthesize code;
@synthesize created;
@synthesize ref;
@synthesize route;
@synthesize alert;
@synthesize data;

-(id)init{
    self = [super init];
    return self;
}

-(NSString *)toString{
    return [NSString stringWithFormat:@"%@ %@ %@", self.code, self.route, self.data];
}

@end
