//
//  Button.h
//  CrossSell
//
//  Created by Binh Dang on 5/13/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CrossSellButtonInfo : NSObject

@property float percentageX;
@property float percentageY;
@property float percentageWidth;
@property float percentageHeight;
@property NSString *url;
@property NSString *text;

-(id)initWithPositionString:(NSString *)positionString url:(NSString*)url text:(NSString *)text;
@end
