//
//  CollectedHoroscope.m
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CollectedHoroscope.h"

#define kCollectedDate @"CollectedHoroscope.collectedDates"
#define kCollectedDescription @"CollectedHoroscope.collectedDescriptions"
#define kDateInstalledApp @"CollectedHoroscope.dateInstalledApp"
#define kLastDateOpenApp @"CollectedHoroscope.lastDateOpenApp"
#define kCollectedSign @"CollectedHoroscope.collectedSigns"
#define kCollectedData @"CollectedHoroscope.collectedData"

@implementation CollectedHoroscope
@synthesize lastDateOpenApp = _lastDateOpenApp;
@synthesize dateInstalledApp = _dateInstalledApp;
@synthesize collectedData = _collectedData;

+ (NSString *)getFilePath{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL* url = [manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    return [url URLByAppendingPathComponent:kCollectedData].path;
}

- (void)saveCollectedData{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.collectedData];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCollectedData];
}

- (NSMutableArray *)collectedData{
    if(!_collectedData){
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCollectedData];
        id obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if(!obj){
            _collectedData = [[NSMutableArray alloc] init];
            [self saveCollectedData];
        }
        else{
            _collectedData = obj;
        }
    }
    return _collectedData;

}

- (double)getScore{
    
    int totalDays = round([self.lastDateOpenApp timeIntervalSinceDate:self.dateInstalledApp] / (3600*24))+1;
    double result = [self.collectedData count] / (double)totalDays;
    if(result >= 1) return 1;
    return result;
}

- (void)reset{
    [self.collectedData removeAllObjects];
    [self saveCollectedData];
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [calendar components:NSUIntegerMax fromDate:date];
    comp.hour = comp.minute = comp.second = 1;
    [[NSUserDefaults standardUserDefaults] setObject:comp.date forKey:kDateInstalledApp];
    [[NSUserDefaults standardUserDefaults] setObject:comp.date forKey:kLastDateOpenApp];
    
}

- (NSDate *)dateInstalledApp{
    if(!_dateInstalledApp){
        NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kDateInstalledApp];
        if(!date){
            date = [NSDate date];
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *comp = [calendar components:NSUIntegerMax fromDate:date];
            comp.hour = comp.minute = comp.second = 1;
            [[NSUserDefaults standardUserDefaults] setObject:comp.date forKey:kDateInstalledApp];
        }
        _dateInstalledApp = date;
    }
    return _dateInstalledApp;
}

- (NSDate *)lastDateOpenApp{
    if(!_lastDateOpenApp){
        NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kLastDateOpenApp];
        if(!date){
            date = [NSDate date];
            NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *comp = [calendar components:NSUIntegerMax fromDate:date];
            comp.hour = comp.minute = comp.second = 1;
            [[NSUserDefaults standardUserDefaults] setObject:comp.date forKey:kLastDateOpenApp];
        }
        _lastDateOpenApp = date;
    }
    return  _lastDateOpenApp;
}

- (void)mySetLastDateOpenApp:(NSDate *)lastDateOpenApp{
    _lastDateOpenApp = lastDateOpenApp;
    [[NSUserDefaults standardUserDefaults] setObject:lastDateOpenApp forKey:kLastDateOpenApp];
    
}

@end
