//
//  Message.h
//  CrossSell
//
//  Created by Binh Dang on 5/13/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CrossSellButtonInfo.h"

@interface CrossSellMessage : NSObject

typedef enum {
    NormalMessage,
    SheepMessage
} MessageType;

@property int message_id;
@property NSString* text;
@property NSString* imageUrl;
@property MessageType messageType;
@property (strong, nonatomic) CrossSellButtonInfo *okButtonInfo;
@property (strong, nonatomic) CrossSellButtonInfo *cancelButtonInfo;
@property (strong, nonatomic) NSMutableArray *customButtonsInfoArray;
@property (strong, nonatomic) UIImage *loadedImage;
@property BOOL finishedScalingImage;

-(id)initWithDictionary:(NSDictionary*)messageDataDict;
-(CGRect)calculateMessageDialogFrame;
@end
