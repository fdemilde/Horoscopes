//
//  SMRotaryProtocol.h
//  RotaryWheelProject
//
//  Created by cesarerocchi on 2/10/12.
//  Copyright (c) 2012 studiomagnolia.com. All rights reserved.


#import <Foundation/Foundation.h>
#import "Horoscope.h"

@protocol SMRotaryProtocol <NSObject>

- (void) wheelDidChangeValue:(Horoscope*)newValue becauseOf:(BOOL)autoRoll;
- (void) doneSelectedSign;

@end
