//
//  CrossSell.h
//  CrossSell
//
//  Created by Binh Dang on 5/12/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrossSellServerMessenging.h"
#import "CrossSellMessage.h"
#import "CrossSellMessageDialog.h"
#import "CrossSellConfig.h"

@interface CrossSellMainView : UIView


@property (strong, nonatomic)CrossSellMessage *currentSheepMessage; // store current Sheep message, when a sheep is in display and user has not tap it but a nother sheep message comes, current sheep message will be update
@property BOOL isAnimating;

-(id)initWithFrame:(CGRect)frame  serverMessenging:(CrossSellServerMessenging *)serverMessenging;

-(void)startSheepAnimation;
-(void)putSheepOnTop;
-(void)displayMessageDialog:(CrossSellMessage*)message shouldAnimate:(BOOL)shouldAnimate;

@end
