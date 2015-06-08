//
//  Button.m
//  CrossSell
//
//  Created by Binh Dang on 5/13/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import "CrossSellButtonInfo.h"

@implementation CrossSellButtonInfo

-(id)initWithPositionString:(NSString *)positionString url:(NSString*)url text:(NSString *)text{
    if((self = [super init])){
        [self setupPosition:positionString];
        self.text = text;
        self.url = url;
    }
    return self;
}

-(void)setupPosition:(NSString *)positionString{
    if(positionString == nil || [positionString isEqualToString:@""]){
        return;
    }
    NSArray *stringsComponent = [positionString componentsSeparatedByString:@","];
    
    self.percentageX = [[stringsComponent objectAtIndex:0] floatValue];
    self.percentageY = [[stringsComponent objectAtIndex:1] floatValue];
    self.percentageWidth = [[stringsComponent objectAtIndex:2] floatValue];
    self.percentageHeight = [[stringsComponent objectAtIndex:3] floatValue];
}


@end
