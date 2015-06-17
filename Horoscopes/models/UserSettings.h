//
//  UserSettings.h
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserSettings : NSObject
@property (nonatomic) BOOL notifyOfNewHoroscope;
@property (nonatomic) int horoscopeSign;

-(void)setHoroscopeSign:(int)horoscopeSign;

@end
