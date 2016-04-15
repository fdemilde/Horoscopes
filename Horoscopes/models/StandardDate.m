//
//  StandardDate.m
//  Horoscopes
//
//  Created by Binh Dang on 3/12/16.
//  Copyright © 2016 Binh Dang. All rights reserved.
//
#define kNSDate @"StandardDate.NSDate"
#define kDay @"StandardDate.day"
#define kMonth @"StandardDate.month"
#define kYear @"StandardDate.year"
#define defaultYear 1900

#import "StandardDate.h"

@implementation StandardDate
@synthesize nsDate;
@synthesize day = _day;
@synthesize month = _month;
@synthesize year = _year;

-(id) initWithDay:(int)day month:(int)month {
    if(self = [super init]){
        NSString *dateString = [NSString stringWithFormat:@"%d/%d/1900", day, month];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        nsDate = [dateFormatter dateFromString:dateString];
        _day = day;
        _month = month;
        _year = defaultYear;
        
    }
    return self;
}

-(id) initWithDay:(int)day month:(int)month year:(int)year {
    if(self = [super init]){
        nsDate = [[NSDate alloc] init];
        NSString *dateString = [NSString stringWithFormat:@"%d/%d/%d", day, month, year];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        nsDate = [dateFormatter dateFromString:dateString];
        _day = day;
        _month = month;
        _year = year;
    }
    return self;
}

-(NSString *)toString: (NSString *)dateFormat{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    if(nsDate != nil){
        return [dateFormatter stringFromDate:nsDate];
    } else {
        return @"";
    }
}

-(NSString *)toStringWithDaySuffix {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMMM d";
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSString *dateString = [dateFormatter stringFromDate:nsDate];
    
    NSDateFormatter *dayOfMonthFormatter = [[NSDateFormatter alloc] init];
    dayOfMonthFormatter.dateFormat = @"d";
    dayOfMonthFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dayOfMonthFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    NSString *dayOfMonthFormatterString = [dayOfMonthFormatter stringFromDate:nsDate];
    int date_day = [dayOfMonthFormatterString intValue];
    NSString *suffix_string = @"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st";
    NSArray *suffixes = [suffix_string componentsSeparatedByString:@"|"];
    NSString *suffix = suffixes[date_day];
    dateString = [dateString stringByAppendingString:suffix];
    if (_year != defaultYear && _year != 0) {
        dateString = [dateString stringByAppendingString:[NSString stringWithFormat:@" %d",_year]];
    }
    return dateString;
}

+ (StandardDate *) resetDateBaseOnNSDate: (StandardDate *)date { // using nsDate to populate Day, month, year
    
    NSDate* nsdate = (NSDate *)date.nsDate;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:nsdate];
    date.day = (int)components.day;
    date.month = (int)components.month;
    date.year = (int)components.year;
    return date;
}

#pragma mark - encode/decode
- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        nsDate = [aDecoder decodeObjectForKey:kNSDate];
        _day = [aDecoder decodeIntForKey:kDay];
        _month = [aDecoder decodeIntForKey:kMonth];
        _year = [aDecoder decodeIntForKey:kYear];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.nsDate forKey:kNSDate];
    [aCoder encodeInteger:self.day forKey:kDay];
    [aCoder encodeInteger:self.month forKey:kMonth];
    [aCoder encodeInteger:self.year forKey:kYear];
}
@end
