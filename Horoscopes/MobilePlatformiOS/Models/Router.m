//
//  Router.m
//  MobilePlatform
//
//  Created by Binh Dang on 2/11/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "Router.h"

@implementation Router

-(id)init{
    self = [super init];
    routes = [[NSMutableArray alloc] init];
    handlers = [[NSMutableDictionary alloc] init];
    originals = [[NSMutableDictionary alloc] init];
    return self;
}

-(int) routeCount{
    return (int)[routes count];
}

#pragma mark - HELPERS
-(NSString *)toRegex:(NSString*)route{
//    NSString* original = route;
//    DebugLog(@"ORIGINAL ROUTE = %@", route);
    NSString* namePattern = @"(\\(\\?)?:\\w+";
    route = [RX(@"([\\-{}\\[\\]+?.,\\\\^$|#\\s])") replace:route with:@"\\$1"];
    route = [RX(@"\\((.*?)\\)") replace:route with:@"\\(\\?:$1\\)\\?"];
//    DebugLog(@"toRegex AFTER replace all = %@", route);
    
    NSArray* matches = [route matches:RX(namePattern)];
//    DebugLog(@"matches array = %@", matches);
    for (NSString* match in matches) {
        route = [route stringByReplacingOccurrencesOfString:match withString:@"([^/?]+)"];
    }
    route = [RX(@"\\*\\w+") replace:route with:@"([^?]*?)"];
    route = [NSString stringWithFormat:@"%@%@%@",@"^", route, @"(?:\\?([\\s\\S]*))?$"];
//    DebugLog(@"String = %@ - route = %@", original, route);
    return route;
}

-(void)addRoute:(NSString *)route blockCode:(void(^)(NSDictionary* param))block{
    NSString * regex = [self toRegex:route];
    [routes addObject:regex];
    [handlers setObject:block forKey:regex];
    [originals setObject:route forKey:regex];
}

-(void)handleRoute:(NSString*)url{
    url = [url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    for (NSString* route in routes) {
        BOOL isMatch = [RX(route) isMatch:url];
        
        if(isMatch){
            NSDictionary *params = [self extractParamaters:url route:route];
            
            void (^ myblock)(NSDictionary*) = [handlers objectForKey:route];
            myblock(params);
            break;
        }
    }
}

- (NSDictionary*)extractParamaters:(NSString*)url route:(NSString*)route{
    // extract route data
    RxMatch* match = [url firstMatchWithDetails:RX(route)];
    
    NSMutableDictionary *mainParams = [NSMutableDictionary dictionary];
    NSString *originRoute = [originals objectForKey:route];
    RxMatch* originMatch = [originRoute firstMatchWithDetails:RX(route)];
    
    
    for(int i= 1; i < originMatch.groups.count ; i++){
        RxMatchGroup *keyGroup = [originMatch.groups objectAtIndex:i];
        if(keyGroup.value){
            //DebugLog(@"ORIGINAL matches group %@", keyGroup.value);
            NSString *key = [self cleanRouteParam:keyGroup.value];
            RxMatchGroup *valueGroup = [match.groups objectAtIndex:i];
            NSString *value = [self cleanRouteParam:valueGroup.value];
            // priority
            [mainParams setObject:value forKey:key];
        }
    }
    
    NSMutableDictionary *GETparams = [NSMutableDictionary dictionary];
    // ok now go to GET parameters
    NSArray *urlRouteParts = [url componentsSeparatedByString:@"?"];
    // all string previous the first "?" is route date
    NSString *urlRouteDataString = urlRouteParts[0];
    // ensure the length not out of bound
    if (url.length > urlRouteDataString.length+1){
        NSString *getParamString = [url substringFromIndex:urlRouteDataString.length+1];
        // separate the GET param with "&" -> "key1=value1&key2=value2"
        NSArray *paramParts = [getParamString componentsSeparatedByString:@"&"];
        for(NSString *part in paramParts){
            // for each paramPart, we extract the key and value "key1=value1"
            NSArray *keyValueParts = [part componentsSeparatedByString:@"="];
            if(keyValueParts.count == 2)
            {
                NSString *key = [self cleanRouteParam:keyValueParts[0]];
                NSString *value = [self cleanRouteParam:keyValueParts[1]];
                [GETparams setObject:value forKey:key];
            }
        }
    }
    
    // combine 2 param dict together
    // Only add new key and value when the key is not existed
    for (NSString *key in GETparams.allKeys){
        if (![mainParams objectForKey:key]){
            NSString *value = [GETparams objectForKey:key];
            [mainParams setObject:value forKey:key];
        }
    }
    
    return mainParams;
}

#pragma mark - HELPER

- (NSString*)cleanRouteParam:(NSString*)param{
    // clean all special character *,:,()
    param = [param stringByReplacingOccurrencesOfString:@"*" withString:@""];
    param = [param stringByReplacingOccurrencesOfString:@":" withString:@""];
    param = [param stringByReplacingOccurrencesOfString:@"(" withString:@""];
    param = [param stringByReplacingOccurrencesOfString:@")" withString:@""];
    
    return param;
}

@end
