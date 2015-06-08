//
//  UserSettings.m
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserSettings.h"

@implementation UserSettings
@synthesize notifyOfNewHoroscope = _notifyOfNewHoroscope;
@synthesize horoscopeSign = _horoscopeSign;


#define KNotifyNewHoroscope @"UserSettings.notifyOfNewHoroscope"
#define KHoroscope @"UserSettings.horoscopeSign"


- (BOOL)notifyOfNewHoroscope
{
    if(!_notifyOfNewHoroscope)
    {
        NSNumber *obj = [[NSUserDefaults standardUserDefaults] objectForKey:KNotifyNewHoroscope];
        if(!obj) //load for the first time
            _notifyOfNewHoroscope = NO;
        else _notifyOfNewHoroscope = [obj boolValue];
    }
    return _notifyOfNewHoroscope;
}

- (void)setNotifyOfNewHoroscope:(BOOL)notifyOfNewHoroscope
{
    _notifyOfNewHoroscope = notifyOfNewHoroscope;
    NSNumber *obj = [NSNumber numberWithBool:_notifyOfNewHoroscope];
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:KNotifyNewHoroscope];
}

- (int)horoscopeSign
{
    if(!_horoscopeSign)
    {
        NSNumber *obj = [[NSUserDefaults standardUserDefaults] objectForKey:KHoroscope];
        if(!obj)
            _horoscopeSign = -1;
        else _horoscopeSign = [obj intValue];
    }
    return _horoscopeSign;
}

- (void)setHoroscopeSign:(int)horoscopeSign
{
    _horoscopeSign = horoscopeSign;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_horoscopeSign] forKey:KHoroscope];
}


@end
