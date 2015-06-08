//
//  MessageInfo.m
//  GiftApp
//
//  Created by Tung Ha on 10/25/13.
//  Copyright (c) 2013 Tung Ha. All rights reserved.
//

#import "MessageInfo.h"

@implementation MessageInfo
@synthesize messageId, okText, okURL, text;
@synthesize cancelButton, imageURL, okButton;

- (id)initWithDictionary:(NSDictionary*)dict{
    if(self = [super init]){
        self.messageId      = [dict[@"message_id"] intValue];
        self.text           = dict[@"text"];
        self.okText         = dict[@"ok_text"];
        self.okURL          = dict[@"ok_url"];
        self.imageURL       = dict[@"image_url"];
        
        self.okButton       = [self getCGRectFromString:dict[@"ok_button"]];
        self.cancelButton   = [self getCGRectFromString:dict[@"cancel_button"]];
    }
    return self;
}

- (CGRect)getCGRectFromString:(NSString*)rectString{
    CGRect result;
    if(rectString!=nil){
        NSArray *parts = [rectString componentsSeparatedByString:@","];
        result.origin.x     = [[parts objectAtIndex:0] floatValue];
        result.origin.y     = [[parts objectAtIndex:1] floatValue];
        result.size.width   = [[parts objectAtIndex:2] floatValue];
        result.size.height  = [[parts objectAtIndex:3] floatValue];
    }
    return result;
}

@end
