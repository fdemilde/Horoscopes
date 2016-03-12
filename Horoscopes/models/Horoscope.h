//
//  Horoscope.h
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "StandardDate.h"

//Horoscope model
@interface Horoscope : NSObject <NSCoding>

@property (nonatomic, strong) NSString *sign; //sign of horoscope
@property (nonatomic, strong) StandardDate *startDate; //horoscope from birthday
@property (nonatomic, strong) StandardDate *endDate; //to birthday
@property (nonatomic, strong) NSMutableArray *horoscopes; //description of today horoscope
@property (nonatomic, strong) NSMutableArray *permaLinks;


- (id)initWithSign:(NSString*)sign startFrom:(StandardDate*)startDate to:(StandardDate*)endDate; //constructor
- (UIImage*)getIcon; //get the icon for the sign
- (UIImage*)getIconSelected;
- (UIImage*)getTodayIcon;
- (UIImage*)getSymbol;
- (UIImage*)getSymbolSelected;

@end
