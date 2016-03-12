//
//  Horoscope.m
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Horoscope.h"
#define kSign @"Horoscope.sign"
#define kStartDate @"Horoscope.startDate"
#define kEndDate @"Horoscope.endDate"
#define kHoroscope @"Horoscope.horoscopes"
#define kPermaLinks @"Horoscope.permaLinks"

@implementation Horoscope
@synthesize sign = _sign;
@synthesize startDate = _startDate;
@synthesize endDate = _endDate;
@synthesize horoscopes = _horoscopes;
@synthesize permaLinks = _permaLinks;

- (NSMutableArray *)horoscopes{
    if(!_horoscopes){
        _horoscopes = [[NSMutableArray alloc] init];
    }
    return _horoscopes;
}

- (NSMutableArray *)permaLinks{
    if(!_permaLinks){
        _permaLinks = [[NSMutableArray alloc] init];
    }
    return _permaLinks;
}

#pragma mark - Constructor
- (id)initWithSign:(NSString*)sign startFrom:(StandardDate*)startDate to:(StandardDate*)endDate
{
    if((self = [super init]))
    {
        self.sign = sign;
        self.startDate = startDate;
        self.endDate = endDate;
    }
    return self;
}

#pragma mark - Class methods
- (UIImage*)getIcon;
{
    UIImage *img = [UIImage imageNamed:self.sign];
    return img;
}

- (UIImage*)getIconSelected;
{
    UIImage *img = [UIImage imageNamed:[self.sign stringByAppendingString:@"_selected"]];
    return img;
}

- (UIImage*)getTodayIcon
{
    UIImage *img = [UIImage imageNamed:[self.sign stringByAppendingString:@"_today.png"]];
    return img;
}

- (UIImage*)getSymbol
{
    UIImage *img = [UIImage imageNamed:[self.sign stringByAppendingString:@"_icon.png"]];
    return img;
}

- (UIImage*)getSymbolSelected
{
    UIImage *img = [UIImage imageNamed:[self.sign stringByAppendingString:@"_icon_selected.png"]];
    return img;
}

#pragma mark - encode/decode
- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        _sign = [aDecoder decodeObjectForKey:kSign];
        _startDate = [aDecoder decodeObjectForKey:kStartDate];
        _endDate = [aDecoder decodeObjectForKey:kEndDate];
        _horoscopes = [aDecoder decodeObjectForKey:kHoroscope];
        _permaLinks = [aDecoder decodeObjectForKey:kPermaLinks];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.sign forKey:kSign];
    [aCoder encodeObject:self.startDate forKey:kStartDate];
    [aCoder encodeObject:self.endDate forKey:kEndDate];
    [aCoder encodeObject:self.horoscopes forKey:kHoroscope];
    [aCoder encodeObject:self.permaLinks forKey:kPermaLinks];
}

@end
