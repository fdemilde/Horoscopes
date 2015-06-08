//
//  Message.m
//  CrossSell
//
//  Created by Binh Dang on 5/13/15.
//  Copyright (c) 2015 Binh Dang. All rights reserved.
//

#import "CrossSellMessage.h"
#import "CrossSellConfig.h"

@implementation CrossSellMessage

-(id)initWithDictionary:(NSDictionary*)messageDataDict{
    if((self = [super init])){
        self.finishedScalingImage = NO;
        self.message_id = [[messageDataDict objectForKey:@"message_id"] intValue];
        self.text = [messageDataDict objectForKey:@"text"];
        self.imageUrl = [messageDataDict objectForKey:@"image_url"];
        int promt = [[messageDataDict objectForKey:@"prompt"] intValue];
        [self setupMessageType:promt];
        [self createOKButton:messageDataDict];
        [self createCancelButton:messageDataDict];
        [self createCustomButtons:messageDataDict];
        [self downloadMessageImage];
    }
    return self;
}

-(void)setupMessageType:(int)typeInt{
    switch (typeInt) {
        case 0:
            self.messageType = NormalMessage;
            break;
        case 1:
            self.messageType = SheepMessage;
            break;
        default:
            break;
    }
}

-(void)createOKButton:(NSDictionary *)dataDict{
    NSString* okButtonData = [dataDict objectForKey:@"ok_button"];
    NSString* okButtonUrl = [dataDict objectForKey:@"ok_url"];
    NSString* okText = [dataDict objectForKey:@"ok_text"];
    _okButtonInfo = [[CrossSellButtonInfo alloc] initWithPositionString:okButtonData url:okButtonUrl text:okText];
}

-(void)createCancelButton:(NSDictionary *)dataDict{
    NSString* cancelButtonData = [dataDict objectForKey:@"cancel_button"];
    _cancelButtonInfo = [[CrossSellButtonInfo alloc] initWithPositionString:cancelButtonData url:nil text:@"cancel"];
}

-(void)createCustomButtons:(NSDictionary *)dataDict{
    _customButtonsInfoArray = [[NSMutableArray alloc] init];
    NSDictionary* customButtonsArrayData = [dataDict objectForKey:@"custom_buttons"];
    for (NSDictionary *dict in customButtonsArrayData) {
        NSString *position = [dict objectForKey:@"position"];
        NSString *url = [dict objectForKey:@"url"];
        NSString *text = [dict objectForKey:@"text"];
        CrossSellButtonInfo *btn = [[CrossSellButtonInfo alloc] initWithPositionString:position url:url text:text];
        [_customButtonsInfoArray addObject:btn];
    }
}

#pragma mark - Download Image

- (void)downloadMessageImage{
    NSURL *imageUrl = [NSURL URLWithString:self.imageUrl];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                          delegate:nil
                                                     delegateQueue:nil];
    NSURLSessionDownloadTask *getImageTask =
    [session downloadTaskWithURL:imageUrl
               completionHandler:^(NSURL *location,
                                   NSURLResponse *response,
                                   NSError *error) {
                   UIImage *downloadedImage =
                   [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                   //3
                   dispatch_async(dispatch_get_main_queue(), ^{
                       self.loadedImage = downloadedImage;
                       [self scaleImage];
                   });
               }];
    [getImageTask resume];
}

-(void)scaleImage{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect dialogFrame = [self calculateMessageDialogFrame];
        CGSize desireSize = (CGSize){dialogFrame.size.width, dialogFrame.size.height};
        self.loadedImage = [self imageWithImage:self.loadedImage scaledToSize:desireSize];
        dispatch_async( dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:
             NOTIFICATION_FINISH_SCALING_MESSAGE object:self.imageUrl];
            self.finishedScalingImage = YES;
        });
    });
}

// scale image to specific size
- (UIImage*)imageWithImage:(UIImage *)image
              scaledToSize:(CGSize)newSize
{
    // get current image ratio
    float heightToWidthRatio = image.size.height / image.size.width;
    float scaleFactor = 1;
    if(heightToWidthRatio > 0) {
        scaleFactor = newSize.height / image.size.height;
    } else {
        scaleFactor = newSize.width / image.size.width;
    }
    
    CGSize newSize2 = newSize;
    newSize2.width = (int)(image.size.width * scaleFactor);
    newSize2.height = (int)(image.size.height * scaleFactor);
    
    UIGraphicsBeginImageContext(newSize2);
    [image drawInRect:CGRectMake(0,0,newSize2.width,newSize2.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

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

@end
