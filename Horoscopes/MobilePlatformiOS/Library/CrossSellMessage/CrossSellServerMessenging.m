//
//  CrossSellServerMessenging.m
//  CrossSell
//
//  Created by Binh Dang on 5/14/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import "CrossSellServerMessenging.h"
#import "CrossSellMessageDialog.h"
#import "CrossSellMessage.h"
#import "MobilePlatform.h"
#import "CrossSellConfig.h"

@implementation CrossSellServerMessenging {
}

-(id)init{
    if ((self = [super init])){
        _messages = [[NSMutableArray alloc] init];
        _numberOfImages = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleCancelMessage:)
                                                     name:CROSS_SELL_CLOSE_NOTIFICATION
                                                   object:nil];
    }
    
    return self;
}

- (void)handleMessageArray:(NSArray*)array{
    for (NSDictionary* dict in array) {
        CrossSellMessage* messNew = [[CrossSellMessage alloc] initWithDictionary:dict];
        _numberOfImages++;
        [_messages addObject:messNew];
    }
}

- (void)handleCancelMessage:(NSNotification*)notif
{
    [self showMessage];
}

-(void)showMessage {
    // verify if the messages array still has any message left or NOT
    
    if ([_messages count] == 0 || _messages == nil) {
        return;
    }
    
    CrossSellMessage *message = [_messages objectAtIndex:0];
    if ([self isMessageReaded:message.message_id] == YES){
        // remove it out of the messages array
        [_messages removeObjectAtIndex:0];
        // call showMessage Again
        
        _numberOfShownImages++;
        [self showMessage];
        return;
    } else {
        [_messages removeObjectAtIndex:0];
        
        // save message ID so that we will not show it again
        if (message.message_id != 0) [self saveReadedMessageID:message];

        if(message.imageUrl!=nil){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SHOW_MESSAGE object:message];
        } else {
            NSString *otherButton = (message.okButtonInfo.text!=nil)?message.okButtonInfo.text:nil;
            NSString *cancelButton = message.okButtonInfo.text!=nil?@"Cancel":@"Ok";
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message.text delegate:self   cancelButtonTitle:cancelButton otherButtonTitles:otherButton, nil];
                [alert show];
                _numberOfShownImages++;
                
            });
        }
    }
}

// Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        //cancel Btn
        [[NSNotificationCenter defaultCenter] postNotificationName:CROSS_SELL_CLOSE_NOTIFICATION object:nil];
    } else if (buttonIndex == 1) {
        //ok btn
        [[NSNotificationCenter defaultCenter] postNotificationName:CROSS_SELL_CLOSE_NOTIFICATION object:nil];
    }
}

#pragma mark - HELPER

- (BOOL)isMessageReaded:(int)messageId {
    if(messageId == 0){
        return false; // always show message with id = 0
    }
    int highestReadId = (int)[[NSUserDefaults standardUserDefaults] integerForKey:CROSS_SELL_READ_MESSAGE_ID_KEY];
    if (highestReadId >= messageId) return true;
    else return false;
}

- (void)saveReadedMessageID:(CrossSellMessage*) mess {
    
    int highestReadId = (int)[[NSUserDefaults standardUserDefaults] integerForKey:CROSS_SELL_READ_MESSAGE_ID_KEY];
    if(mess.message_id > highestReadId){
        [[NSUserDefaults standardUserDefaults] setInteger:mess.message_id forKey:CROSS_SELL_READ_MESSAGE_ID_KEY];
    }
}

@end
