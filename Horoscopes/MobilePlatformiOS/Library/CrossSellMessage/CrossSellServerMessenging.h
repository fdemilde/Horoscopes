//
//  CrossSellServerMessenging.h
//  CrossSell
//
//  Created by Binh Dang on 5/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ServerCommunication.h"

@interface CrossSellServerMessenging : NSObject

@property (strong, nonatomic) NSMutableArray* messages;
@property int numberOfImages;
@property int numberOfShownImages;

-(id)init;
-(void)showMessage;
- (void)handleMessageArray:(NSArray*)array;

@end
