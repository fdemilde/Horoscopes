//
//  MessageDialog.h
//  CrossSell
//
//  Created by Binh Dang on 5/13/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrossSellMessage.h"

@interface CrossSellMessageDialog : UIView

@property (strong, nonatomic) UIImageView *backgroundImage;
@property (strong, nonatomic) UIButton *okButton;
@property (strong, nonatomic) UIButton *cancelButton;

- (id)initWithMessage:(CrossSellMessage*)msgInfo andFrame:(CGRect)frame;
@end
