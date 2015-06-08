//
//  CrossSellManager.m
//  CrossSell
//
//  Created by Binh Dang on 5/15/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import "CrossSellManager.h"
#import "ServerCommunication.h"

@implementation CrossSellManager{
    CrossSellServerMessenging *serverMessenging;
    CrossSellMainView *mainView;
    int numberOfLoadedImages;
    CrossSellMessage *sheepMessage;
    NSArray *mainViewArray; // we need to store all views displaying, so we can close it properly using notification, because if the sheep is displaying there may be 2 main views at the same time, one to show the sheep message, one to show next normal message
    BOOL isSheepShowing;
}

-(id)init{
    if((self = [super init])){
        numberOfLoadedImages = 0;
        [self setupServerMessaging];
        [self setupNotification];
        isSheepShowing = NO;
        
    }
    return self;
}

-(void)setupNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkTotalLoadedMessage:) name:NOTIFICATION_FINISH_SCALING_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMessageDialog:) name:NOTIFICATION_SHOW_MESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMessageDialog:) name:CROSS_SELL_CLOSE_NOTIFICATION object:nil];
}

-(void)setupServerMessaging{
    serverMessenging = [[CrossSellServerMessenging alloc]init];
}

-(void)messengingHandleMessages:(NSArray *)messages{
    [serverMessenging handleMessageArray:messages];
}

-(void)checkTotalLoadedMessage:(NSNotification *)notif{
//    NSString *urlString = (NSString *)notif;
    numberOfLoadedImages++;
    if(numberOfLoadedImages == [serverMessenging.messages count]){ // all images loaded, now display messages;
//        [mainView startSheepAnimation];
        [serverMessenging showMessage];
    }
}

#pragma mark - Notification handling

-(void)showMessageDialog:(NSNotification *)notif{
    CrossSellMessage *message = (CrossSellMessage*)notif.object;
//    [[[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:mainView];
    [self checkAndCreateMainView];
    
    // check message type to handle differently
    switch (message.messageType) {
        case NormalMessage:
            [mainView displayMessageDialog:message shouldAnimate:NO];
            [mainView putSheepOnTop];
            break;
        case SheepMessage:
            [self checkAndShowSheep:message];
            break;
        default:
            break;
    }
}
-(void)closeMessageDialog:(NSNotification *)notif{
    DebugLog(@"closeMessageDialog closeMessageDialog");
}

#pragma mark - handle Sheep
-(void)checkAndShowSheep:(CrossSellMessage *)message{
    mainView.currentSheepMessage = message;
    
    if(!isSheepShowing){ // the sheep is not there
        isSheepShowing = YES;
        [mainView startSheepAnimation];
    }
    [serverMessenging showMessage];
}

-(void)checkAndCreateMainView{
    if(!mainView){
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        DebugLog(@"serverMessenging serverMessenging %@", serverMessenging);
        mainView = [[CrossSellMainView alloc] initWithFrame:(CGRect){0,0,screenWidth,screenHeight} serverMessenging:serverMessenging];
        [[[UIApplication sharedApplication] keyWindow] addSubview:mainView];
        
    }
    
}
@end
