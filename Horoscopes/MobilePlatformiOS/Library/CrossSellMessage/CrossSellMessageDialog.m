//
//  MessageDialog.m
//  CrossSell
//
//  Created by Binh Dang on 5/13/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import "CrossSellMessageDialog.h"
#import "CrossSellConfig.h"

@implementation CrossSellMessageDialog {
    CrossSellMessage *message;
}

const CGRect defaultCrossSellFrameOkBtn = (CGRect){50,75,20,5};
const CGRect defaultCrossSellFrameCancelBtn = (CGRect){50,75,20,5};
const NSString   *defaultCrossSellOkText = @"OK";
const NSString   *defaultCrossSellCancleText = @"Cancel";
const CGFloat crossSellOffsetBtn = 20;

- (id)initWithMessage:(CrossSellMessage*)msgInfo andFrame:(CGRect)frame{
    
    if((self = [super init])){
        
        self.frame = frame;
        message = msgInfo;
        [self crossSellSetupBtn];
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:(CGRect){0,0,self.frame.size.width, self.frame.size.height}];
        bgImageView.image = message.loadedImage;
        [self addSubview:bgImageView];
        bgImageView.backgroundColor = [UIColor blueColor];
    }
    
    return self;
}

#pragma mark - Setup Buttons

-(void)crossSellSetupBtn{
    [self setupCancelButton];
    [self setupOkButton];
    [self setupCustomButtons];
}

-(void)setupCancelButton{
    _cancelButton = [[UIButton alloc] init];
    _cancelButton.backgroundColor = [UIColor redColor];
    int mainViewWidth = self.frame.size.width;
    int mainViewHeight = self.frame.size.height;
    // If ok_text or ok_url is not defined, just display one button “Ok” that dismisses the dialog
    if (message.okButtonInfo.text && message.okButtonInfo.text.length > 0 &&
        message.okButtonInfo.url && message.okButtonInfo.url.length > 0 ){
        // check default location
        if (message.cancelButtonInfo.percentageHeight == 0 || message.cancelButtonInfo.percentageWidth == 0) {
            
            [_cancelButton setFrame:CGRectMake(defaultCrossSellFrameCancelBtn.origin.x / 100 * mainViewWidth + crossSellOffsetBtn, defaultCrossSellFrameCancelBtn.origin.y / 100 * mainViewHeight, defaultCrossSellFrameCancelBtn.size.width / 100 * mainViewWidth, defaultCrossSellFrameCancelBtn.size.height / 100 * mainViewHeight)];
        } else {
            [_cancelButton setFrame:CGRectMake(message.cancelButtonInfo.percentageX / 100 * mainViewWidth, message.cancelButtonInfo.percentageY / 100 * mainViewHeight, message.cancelButtonInfo.percentageWidth / 100 * mainViewWidth, message.cancelButtonInfo.percentageHeight / 100 * mainViewHeight)];
        }
    }
    [self addSubview:_cancelButton];
    [_cancelButton setBackgroundColor:[UIColor greenColor]];
    [_cancelButton addTarget:self
                  action:@selector(cancelTapped:)
        forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupOkButton{
    _okButton = [[UIButton alloc] init];
    _okButton.backgroundColor = [UIColor redColor];
    int mainViewWidth = self.frame.size.width;
    int mainViewHeight = self.frame.size.height;
    //setup the play button
    
    if (message.okButtonInfo.text == nil || [message.okButtonInfo.text isEqualToString:@""] == YES) {
        [_okButton setTitle:defaultCrossSellOkText forState:UIControlStateNormal];
    } else {
        [_okButton setTitle:message.okButtonInfo.text forState:UIControlStateNormal];
    }
    
    // default location for play btn
    if (message.okButtonInfo.percentageHeight == 0 || message.okButtonInfo.percentageWidth == 0 ) {
        
        if (message.okButtonInfo.text == nil || [message.okButtonInfo.text isEqualToString:@""] == YES ||message.okButtonInfo.url == nil || [message.okButtonInfo.url isEqualToString:@""] == YES) {
            [_okButton setFrame:CGRectMake(defaultCrossSellFrameOkBtn.origin.x * mainViewWidth - defaultCrossSellFrameOkBtn.size.width / 100 * mainViewWidth /2 ,defaultCrossSellFrameOkBtn.origin.y / 100 * mainViewHeight,defaultCrossSellFrameOkBtn.size.width / 100 * mainViewWidth,defaultCrossSellFrameOkBtn.size.height / 100 * mainViewHeight)];
        } else {
            [_okButton setFrame:CGRectMake(defaultCrossSellFrameOkBtn.origin.x * mainViewWidth - defaultCrossSellFrameOkBtn.size.width / 100 * mainViewWidth - crossSellOffsetBtn,defaultCrossSellFrameOkBtn.origin.y / 100 * mainViewHeight,defaultCrossSellFrameOkBtn.size.width / 100 * mainViewWidth,defaultCrossSellFrameOkBtn.size.height / 100 * mainViewHeight)];
        }
    } else {
        [_okButton setFrame:CGRectMake(message.okButtonInfo.percentageX / 100 * mainViewWidth,message.okButtonInfo.percentageY / 100 * mainViewHeight,message.okButtonInfo.percentageWidth / 100 * mainViewWidth,message.okButtonInfo.percentageHeight / 100 * mainViewHeight)];
    }
    [self addSubview:_okButton];
    [_okButton addTarget:self
                 action:@selector(okTapped:)
       forControlEvents:UIControlEventTouchUpInside];
    
    [_okButton setBackgroundColor:[UIColor redColor]];
}

-(void)setupCustomButtons{
    int mainViewWidth = self.frame.size.width;
    int mainViewHeight = self.frame.size.height;
    NSArray *customButtonsInfo = message.customButtonsInfoArray;
    for(int i = 0; i < [customButtonsInfo count]; i++){
        CrossSellButtonInfo* buttonInfo = customButtonsInfo[i];
        UIButton *customButton = [[UIButton alloc] init];
        [customButton setFrame:CGRectMake(buttonInfo.percentageX / 100 * mainViewWidth,buttonInfo.percentageY / 100 * mainViewHeight,buttonInfo.percentageWidth / 100 * mainViewWidth,buttonInfo.percentageHeight / 100 * mainViewHeight)];
        
        [customButton addTarget:self
                         action:@selector(customButtonsTapped:)
                        forControlEvents:UIControlEventTouchUpInside];
        customButton.tag = i;
        customButton.backgroundColor = [UIColor blueColor];
        [self addSubview:customButton];
    }
}

#pragma mark - Helpers

- (void)saveReadedMessageID {
    [[NSUserDefaults standardUserDefaults] setInteger:message.message_id forKey:CROSS_SELL_READ_MESSAGE_ID_KEY];
}

#pragma mark - button handling

-(void)okTapped:(id)sender {
    
    NSURL *url = [NSURL URLWithString:message.okButtonInfo.url];
    [[UIApplication sharedApplication] openURL:url];
    [[NSNotificationCenter defaultCenter] postNotificationName:CROSS_SELL_CLOSE_NOTIFICATION object:nil];
    [self removeFromSuperview];
}

-(void)cancelTapped:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:CROSS_SELL_CLOSE_NOTIFICATION object:nil];
    
    [self removeFromSuperview];
}

-(void)customButtonsTapped:(id)sender {
    UIButton *customButton = (UIButton *)sender;
    int i = customButton.tag;
    NSString *urlString = @"";
    if(i < [message.customButtonsInfoArray count]){ // prevent index out of bound
        urlString = ((CrossSellButtonInfo *)message.customButtonsInfoArray[i]).url;
        NSURL *url = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:url];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:CROSS_SELL_CLOSE_NOTIFICATION object:nil];
    
    [self removeFromSuperview];
}

#pragma mark - Show/ Hide 

-(void)show{
    
}

-(BOOL)isRoute:(NSString *)url{
    if([message.okButtonInfo.url hasPrefix:@"/"]){ // check if it's a route
        return YES;
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
