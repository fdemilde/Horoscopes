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
@synthesize birthday = _birthday;

#define KNotifyNewHoroscope @"UserSettings.notifyOfNewHoroscope"
#define KHoroscope @"UserSettings.horoscopeSign"
#define KBirthday @"UserSettings.birthday"

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

- (void)setBirthday:(NSDate*)birthday
{
    _birthday = birthday;
    [[NSUserDefaults standardUserDefaults] setObject:_birthday forKey:KBirthday];
}

- (NSDate *)birthday
{
    if(!_birthday)
    {
        NSNumber *obj = [[NSUserDefaults standardUserDefaults] objectForKey:KBirthday];
        if(!obj)
            _birthday = nil;
        else _birthday = (NSDate *)obj;
    }
    return _birthday;
}


@end
