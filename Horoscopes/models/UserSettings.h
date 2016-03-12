//
//  UserSettings.h
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StandardDate.h"

@interface UserSettings : NSObject
@property (nonatomic) BOOL notifyOfNewHoroscope;
@property (nonatomic) int horoscopeSign;
@property (nonatomic) StandardDate *birthday;

-(void)setHoroscopeSign:(int)horoscopeSign;
-(void)setBirthday:(StandardDate *)birthday;

@end
