//
//  CollectedHoroscope.h
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Horoscope.h"
#import "CollectedItem.h"
#import <UIKit/UIKit.h>

@interface CollectedHoroscope : NSObject <UIAlertViewDelegate>
@property (nonatomic, strong) NSDate *dateInstalledApp;
@property (nonatomic, strong) NSDate *lastDateOpenApp;
@property (nonatomic, strong) NSMutableArray *collectedData;

- (double)getScore; //calculate the %
- (void)reset; //reset collected horoscopes 
- (void)saveCollectedData;
- (void)mySetLastDateOpenApp:(NSDate *)lastDateOpenApp;
+ (NSString *)getFilePath;
@end
