//
//  CollectedItem.m
//  FCSHoroscope
//
//  Created by Danh Nguyen on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CollectedItem.h"
#define kCollectedDate @"CollectedItem.collectedDate"
#define kHoroscope @"CollectedItem.horoscope"

@implementation CollectedItem
@synthesize collectedDate = _collectedDate;
@synthesize horoscope = _horoscope;

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_collectedDate forKey:kCollectedDate];
    [aCoder encodeObject:_horoscope forKey:kHoroscope];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        _collectedDate = [aDecoder decodeObjectForKey:kCollectedDate];
        _horoscope = [aDecoder decodeObjectForKey:kHoroscope];
    }
    return self;
}
@end
