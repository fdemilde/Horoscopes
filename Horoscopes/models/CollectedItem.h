//
//  CollectedItem.h
//  FCSHoroscope
//
//  Created by Danh Nguyen on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Horoscope.h"

@interface CollectedItem : NSObject <NSCoding>
@property (nonatomic, strong) NSDate *collectedDate;
@property (nonatomic, strong) Horoscope *horoscope;
@end
