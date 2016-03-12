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
#define KNewBirthday @"UserSettings.KNewBirthday"

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

- (void)setBirthday:(StandardDate*)birthday
{
    _birthday = birthday;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_birthday];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:KNewBirthday];
}

- (StandardDate *)birthday
{
    if(!_birthday)
    {
        NSNumber *obj = [[NSUserDefaults standardUserDefaults] objectForKey:KBirthday];
        if(obj){
            // check if object is NSDate class, convert it into StandardDate and return
            if ([obj isKindOfClass:[NSDate class]]){
                NSDate* nsdate = (NSDate *)obj;
                NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:nsdate];
                int day = (int)components.day;
                int month = (int)components.month;
                int year = (int)components.year;
                _birthday = [[StandardDate alloc] initWithDay:day month:month year:year];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:KBirthday];
            }
        }
        else {
            NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:KNewBirthday];
            NSObject *newObj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if(!newObj) {
                _birthday = nil;
            } else {
                _birthday = (StandardDate *) newObj;
            }
        }
    }
    return _birthday;
}


@end
