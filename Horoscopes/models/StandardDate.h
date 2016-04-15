//
//  StandardDate.h
//  Horoscopes
//
//  Created by Binh Dang on 3/12/16.
//  Copyright © 2016 Binh Dang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StandardDate : NSObject

@property (nonatomic) int day;
@property (nonatomic) int month;
@property (nonatomic) int year;
@property (nonatomic) NSDate *nsDate;

-(id) initWithDay:(int)day month:(int)month;
-(id) initWithDay:(int)day month:(int)month year:(int)year;
-(NSString *)toString: (NSString *)dateFormat;
-(NSString *)toStringWithDaySuffix;
+ (StandardDate *) resetDateBaseOnNSDate:(StandardDate *)date;

@end
