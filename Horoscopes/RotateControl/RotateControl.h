//
//  RotateControl.h
//  FCSHoroscope
//
//  Created by Danh Nguyen on 3/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Horoscope.h"
#import "SMRotaryProtocol.h"

@interface RotateControl : UIControl

@property (retain) id <SMRotaryProtocol> delegate;
@property (nonatomic, strong) UIView *container;
@property int numberOfSections;
@property CGAffineTransform startTransform;
@property (nonatomic, strong) NSMutableArray *cloves;
@property int currentValue;
@property (nonatomic, strong) NSMutableArray *horoscopeSigns;

- (id) initWithFrame:(CGRect)frame andDelegate:(id)del withSections:(int)sectionsNumber andArray:(NSMutableArray*)horoscopes;
@end
