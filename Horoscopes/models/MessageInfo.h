//
//  MessageInfo.h
//  GiftApp
//
//  Created by Tung Ha on 10/25/13.
//  Copyright (c) 2013 Tung Ha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MessageInfo : NSObject
@property (nonatomic) int                   messageId;
@property (nonatomic, strong) NSString      *text;
@property (nonatomic, strong) NSString      *okText;
@property (nonatomic, strong) NSString      *okURL;
@property (nonatomic, strong) NSString      *imageURL;
@property (nonatomic)         CGRect        okButton;
@property (nonatomic)         CGRect        cancelButton;

- (id)initWithDictionary:(NSDictionary*)dict;
@end
