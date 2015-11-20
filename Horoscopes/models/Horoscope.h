//
//  Horoscope.h
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//Horoscope model
@interface Horoscope : NSObject <NSCoding>

@property (nonatomic, strong) NSString *sign; //sign of horoscope
@property (nonatomic, strong) NSDate *startDate; //horoscope from birthday
@property (nonatomic, strong) NSDate *endDate; //to birthday
@property (nonatomic, strong) NSMutableArray *horoscopes; //description of today horoscope
@property (nonatomic, strong) NSMutableArray *permaLinks;

- (id)initWithSign:(NSString*)sign startFrom:(NSDate*)startDate to:(NSDate*)endDate; //constructor
- (UIImage*)getIcon; //get the icon for the sign
- (UIImage*)getIconSelected;
- (UIImage*)getTodayIcon;
- (UIImage*)getSymbol;
- (UIImage*)getSymbolSelected;

@end
