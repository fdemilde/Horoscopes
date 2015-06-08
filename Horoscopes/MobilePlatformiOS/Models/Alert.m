//
//  Alert.m
//  MobilePlatform
//
//  Created by Binh Dang on 2/6/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "Alert.h"

@implementation Alert

@synthesize body;
@synthesize body_loc_key;
@synthesize body_loc_args;
@synthesize title;
@synthesize title_loc_key;
@synthesize title_loc_args;
@synthesize view;
@synthesize view_loc_key;
@synthesize cancel;
@synthesize cancel_loc_key;
@synthesize type;
@synthesize priority;

-(id)init{
    self = [super init];
    self.priority = 1;
    return self;
}

-(NSString *)toString{
    return [NSString stringWithFormat:@"%@ %@ %@", type, title, body];
}

-(NSString *)toJson{
    NSMutableDictionary* alertDict = [self convertAlertToDict];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:alertDict
                                                       options:0
                                                         error:&error];
    
    if (!jsonData) {
        DebugLog(@"JSON error: %@", error);
        return @"[]";
    } else {
        NSString *JSONString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        //NSLog(@"JSON OUTPUT: %@",JSONString);
        return JSONString;
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@", type, title, body];
}

-(NSMutableDictionary *)convertAlertToDict{
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc]init];
    if(self.body != nil && ![self.body  isEqual: @""]){
        [returnDict setValue:self.body forKey:@"body"];
    }
    if(self.body_loc_key != nil && ![self.body_loc_key  isEqual: @""]){
        [returnDict setValue:self.body_loc_key forKey:@"body_loc_key"];
    }
    if(self.body_loc_args != nil && ![self.body_loc_args  isEqual: @""]){
        [returnDict setValue:self.body_loc_args forKey:@"body_loc_args"];
    }
    if(self.title != nil && ![self.title  isEqual: @""]){
        [returnDict setValue:self.title forKey:@"title"];
    }
    if(self.title_loc_key != nil && ![self.title_loc_key  isEqual: @""]){
        [returnDict setValue:self.title_loc_key forKey:@"title_loc_key"];
    }
    if(self.title_loc_args != nil && ![self.title_loc_args  isEqual: @""]){
        [returnDict setValue:self.title_loc_args forKey:@"title_loc_args"];
    }
    if(self.view != nil && ![self.view  isEqual: @""]){
        [returnDict setValue:self.view forKey:@"view"];
    }
    if(self.view_loc_key != nil && ![self.view_loc_key  isEqual: @""]){
        [returnDict setValue:self.view_loc_key forKey:@"view_loc_key"];
    }
    if(self.cancel != nil && ![self.cancel  isEqual: @""]){
        [returnDict setValue:self.cancel forKey:@"cancel"];
    }
    if(self.cancel_loc_key != nil && ![self.cancel_loc_key  isEqual: @""]){
        [returnDict setValue:self.cancel_loc_key forKey:@"cancel_loc_key"];
    }
    if(self.type != nil && ![self.type  isEqual: @""]){
        [returnDict setValue:self.type forKey:@"cancel"];
    }
    [returnDict setValue:[NSString stringWithFormat:@"%d", self.priority] forKey:@"priority"];
    
    return returnDict;
}

-(Alert *)fromJson:(NSString *)json{
    Alert* alert = [[Alert alloc] init];
    NSError *jsonError;
    NSData *objectData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *alertDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    NSString* bodyValue = [alertDict objectForKey:@"body"];
    if(bodyValue != nil){
        alert.body = bodyValue;
    }
    NSString* bodyLocKeyValue = [alertDict objectForKey:@"body_loc_key"];
    if(bodyLocKeyValue != nil){
        alert.body_loc_key = bodyLocKeyValue;
    }
    NSString* bodyLocArgsValue = [alertDict objectForKey:@"body_loc_args"];
    if(bodyLocArgsValue != nil){
        alert.body_loc_args = bodyLocArgsValue;
    }
    NSString* titleValue = [alertDict objectForKey:@"title"];
    if(titleValue != nil){
        alert.title = titleValue;
    }
    NSString* titleLocKeyValue = [alertDict objectForKey:@"title_loc_key"];
    if(titleLocKeyValue != nil){
        alert.title_loc_key = titleLocKeyValue;
    }
    NSString* titleLocArgsValue = [alertDict objectForKey:@"title_loc_args"];
    if(titleLocArgsValue != nil){
        alert.title_loc_args = titleLocArgsValue;
    }
    NSString* viewValue = [alertDict objectForKey:@"view"];
    if(viewValue != nil){
        alert.view = view;
    }
    NSString* viewLocKeyValue = [alertDict objectForKey:@"view_loc_key"];
    if(viewLocKeyValue != nil){
        alert.view_loc_key = bodyValue;
    }
    NSString* cancelValue = [alertDict objectForKey:@"cancel"];
    if(cancelValue != nil){
        alert.cancel = cancelValue;
    }
    NSString* cancelLocKeyValue = [alertDict objectForKey:@"cancel_loc_key"];
    if(cancelLocKeyValue != nil){
        alert.cancel_loc_key = cancelLocKeyValue;
    }
    NSString* typeValue = [alertDict objectForKey:@"type"];
    if(typeValue != nil){
        alert.type = typeValue;
    }
    
    int priorityValue = [[alertDict objectForKey:@"priority"] intValue];
    alert.priority = priorityValue;
    
    return alert;
}

@end
