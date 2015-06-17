//
//  CrossSell.m
//  CrossSell
//
//  Created by Binh Dang on 5/12/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import "CrossSellMainView.h"
#import "CrossSellConfig.h"

@interface CrossSellMainView()<UIGestureRecognizerDelegate>{
    UIImageView *sheepImageView;
    NSArray *images;
    CGSize imageSize;
    CrossSellMessageDialog *dialog;
    CrossSellServerMessenging *messenging;
    int numberOfShownImages;
    CGRect messageFrame;
}

@end

@implementation CrossSellMainView
const float movingAnimationDuration = 1.0f;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame serverMessenging:(CrossSellServerMessenging *)serverMessenging{
    if (self = [super init]){
        self.frame = frame;
//        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.4];
        self.backgroundColor = [UIColor clearColor];
        numberOfShownImages = 0;
        messenging = serverMessenging;
        messageFrame = [self calculateMessageDialogFrame];
        [self setupNotification];
        [self setupImagesArray];
        [self setupSheepImageView];
//        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

#pragma mark - Setup

-(void)setupNotification{
}

-(void)setupImagesArray{
    images = [NSArray arrayWithObjects:
              [UIImage imageNamed:@"sheep_waving_1.png"],
              [UIImage imageNamed:@"sheep_waving_2.png"],nil];
    imageSize = ((UIImage*)[images objectAtIndex:0]).size;
}

-(void)setupSheepImageView{
    
    sheepImageView = [[UIImageView alloc] init];
    sheepImageView.frame = (CGRect){self.frame.size.width, self.frame.size.height/2 - imageSize.height/2, imageSize.width, imageSize.height};
    sheepImageView.animationImages = images;
    sheepImageView.animationDuration = 0.5;
    sheepImageView.userInteractionEnabled = YES;
    sheepImageView.hidden = YES;
    UITapGestureRecognizer *pgr = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleTap:)];
    pgr.delegate = self;
    [sheepImageView addGestureRecognizer:pgr];
    [self addSubview:sheepImageView];
}

#pragma mark - animation

-(void)startSheepAnimation{
    if(!_isAnimating){
        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.4];
        sheepImageView.hidden = NO;
        [sheepImageView startAnimating];
        [self sheepMovesIntoScreen];
        sheepImageView.userInteractionEnabled = YES;
    }
}

-(void)stopSheepAnimation{
    sheepImageView.userInteractionEnabled = NO;
    [self sheepMovesOutOfScreen];
    
}

-(void)sheepMovesIntoScreen{
    _isAnimating = YES;
    [UIView animateWithDuration:movingAnimationDuration animations:^{
        //Move the image view to 100, 100 over 10 seconds.
        CGRect destination = (CGRect){self.frame.size.width-imageSize.width, self.frame.size.height/2 - imageSize.height/2, imageSize.width, imageSize.height};
        sheepImageView.frame = destination;
        NSLog(@"destination destination destination = %@", NSStringFromCGRect(destination));
    }completion:^(BOOL finished){
        _isAnimating = NO;
    }];
}

-(void)sheepMovesOutOfScreen{
    _isAnimating = YES;
    [UIView animateWithDuration:movingAnimationDuration animations:^{
        //Move the image view to 100, 100 over 10 seconds.
        CGRect destination = (CGRect){self.frame.size.width, self.frame.size.height/2 - imageSize.height/2, imageSize.width, imageSize.height};
        
        sheepImageView.frame = destination;
    } completion:^(BOOL finished){
        self.backgroundColor = [UIColor clearColor];
        [sheepImageView stopAnimating];
        sheepImageView.hidden = YES;
        _isAnimating = NO;
        [self displayMessageDialog:_currentSheepMessage shouldAnimate:YES];
    }];
}

-(void)displayMessageDialog:(CrossSellMessage*)message shouldAnimate:(BOOL)shouldAnimate{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    // only animate when show image from the sheep
    if(shouldAnimate){
        CGRect startFrame = (CGRect){messageFrame.origin.x, screenHeight, messageFrame.size.width, messageFrame.size.height};
        CrossSellMessageDialog *messDialog = [[CrossSellMessageDialog alloc] initWithMessage:message andFrame:startFrame];
        [self addSubview:messDialog];
        [UIView animateWithDuration:movingAnimationDuration animations:^{
            CGRect destination = messageFrame;
            messDialog.frame = destination;
            
        } completion:^(BOOL finished){
            
        }];
    } else {
        CrossSellMessageDialog *messDialog = [[CrossSellMessageDialog alloc] initWithMessage:message andFrame:messageFrame];
        [self addSubview:messDialog];
    }
    
}

// this method is to make sure that the sheep is always on top
-(void)putSheepOnTop{
    [self bringSubviewToFront:sheepImageView];
}

#pragma mark - Handlers

-(void)handleTap:(UITapGestureRecognizer *)UITapGestureRecognizer{
    if(!_isAnimating){
        [self stopSheepAnimation];
        
    }
}

#pragma mark - Helpers

// TODO: should be somewhere else such as utility
-(CGRect)calculateMessageDialogFrame{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    float desireWidth;
    float desireHeight;
    float n;
    float screenHeightToWidthRatio = screenHeight / screenWidth;
    
    if(screenHeightToWidthRatio == DefaultServerImageRatio){
        n = screenWidth / 18;
        desireWidth = screenWidth - n *2;
        desireHeight = screenWidth * DefaultServerImageRatio;
    } else if(screenHeightToWidthRatio > DefaultServerImageRatio){ // dealing with longer screen
        n = screenWidth / 18;
        desireWidth = screenWidth - n *2;
        desireHeight = screenWidth * DefaultServerImageRatio;
    } else {  // wider screen
        n = screenHeight / 32;
        desireHeight = screenHeight - n *2;
        desireWidth = screenHeight / DefaultServerImageRatio;
    }
    return (CGRect){(screenWidth - desireWidth)/2,(screenHeight - desireHeight)/2,desireWidth,desireHeight};
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    // If the hitView is THIS view, return nil and allow hitTest:withEvent: to
    // continue traversing the hierarchy to find the underlying view.
//    if (hitView == self) {
//        return nil;
//    }
    // Else return the hitView (as it could be one of this view's buttons):
    return hitView;
}
@end
