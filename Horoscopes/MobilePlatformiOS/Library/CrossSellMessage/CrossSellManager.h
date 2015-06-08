//
//  CrossSellManager.h
//  CrossSell
//
//  Created by Binh Dang on 5/15/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrossSellConfig.h"
#import "CrossSellMainView.h"
#import "CrossSellServerMessenging.h"

@interface CrossSellManager : NSObject
-(id)init;
-(void)messengingHandleMessages:(NSArray *)messages;
@end
