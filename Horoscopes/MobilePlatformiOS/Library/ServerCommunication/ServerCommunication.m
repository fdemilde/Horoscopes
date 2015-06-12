//
//  ServerCommunication.m
//  MobilePlatform
//
//  Created by FCS on 2/4/15.
//  Copyright (c) 2015 Zwiggler. All rights reserved.
//

#import "ServerCommunication.h"
#import <CommonCrypto/CommonDigest.h>
#import "ServerCommunicationConfig.h"

@implementation ServerCommunication

- (id)initWithBaseURL:(NSString*)_baseUrl
          andClientId:(int)_clientId
         andUserCreds:(UserCreds*)_creds{
    self = [self initWithBaseURL:_baseUrl andUploadBaseUrl:_baseUrl
                     andClientId:_clientId andUserCreds:_creds];
    return self;
}

- (id)initWithBaseURL:(NSString*)_baseUrl
     andUploadBaseUrl:(NSString*)_uploadBaseUrl
          andClientId:(int)_clientId
         andUserCreds:(UserCreds*)_creds{
    
    if ((self = [super init])){
        baseUrl = _baseUrl;
        uploadBaseUrl = _uploadBaseUrl;
        clientId = _clientId;
        creds = _creds;
        udid = [creds getUDID];
        tsoffset = 0;
    }
    
    return self;
}

- (BOOL)hasError:(NSDictionary *)responseDict {
    id errorObject = [responseDict objectForKey:@"error"];
    if(errorObject){ // "error" key exist
        int error = (int) errorObject;
        if(error == 0){
            return false;
        }
    }
    return true;
}

/**
 * Is there an Error in the specified prefix?
 *
 * @param responseDict the NSDictionary parsed from JSON Object returned from the server .
 * @param errstr The prefix to check for an error in.
 * @return true on error. false if no error
 */
- (BOOL)hasError:(NSDictionary *)responseDict andErrorString:(NSString*)errorString{
    id errorObject = [responseDict objectForKey:@"error"];
    if(errorObject){ // "error" key exist
        int error = [errorObject intValue];
        //        DebugLog(@"has error = %d", error);
        
        if(error == 0){
            return false;
        } else {
            if ([errorString hasPrefix:[self getError:responseDict]]) {
                return true;
            } else {
                return false;
            }
        }
    }
    return true;
}

/**
 * Get the error code in the JSON from the server
 *
 * @param responseDict the NSDictionary parsed from JSON Object returned from the server
 * @return Empty String if no error. Otherwise the error string
 */
- (NSString*)getError :(NSDictionary*)responseDict {
    if (![self hasError:responseDict]) {
        return @"";
    }
    NSString* errorCode = [responseDict objectForKey:@"error_code"];
    return errorCode;
}


/**
 * Encodes the passed in string for a URL
 *
 * @param str the string to encode
 * @return The URL-Encoded version of str.
 * @throws UnsupportedEncodingException Cannot do unicode
 */

- (NSString*)uenc:(NSString*)str {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                    (CFStringRef)str,
                                                                                                    NULL,
                                                                                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    kCFStringEncodingUTF8 ));
    return encodedString;
}

/**
 * Take the parameters out of a NSMutableDictionary and build a query string. Will be sorted
 * alphabetically
 *
 * @param data The SortedMap containing the parameters
 * @return The URL-Encoded Query String
 * @throws UnsupportedEncodingException Cannot do Unicode
 */
- (NSString *)map2qs:(NSDictionary *)data {
    //get the keys sorted in ascending order
    NSArray *myKeys = [data allKeys];
    NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    NSString *retStr = [[NSString alloc] init];
    for (NSString *key in sortedKeys) {
        retStr = [retStr stringByAppendingFormat:@"&%@=%@", [self uenc:key], [self uenc:(NSString *)[data objectForKey:key]]];
    }
    //    DebugLog(@"map2qs map2qs %@", [retStr substringFromIndex:1]);
    return [retStr substringFromIndex:1];
}

/**
 * Calculates the MD5 Hash of the passed in string
 *
 * @param input the string to md5
 * @return the MD5 hash or all zeros if md5 not supported.
 */
- (NSString *)md5:(NSString *)input {
    //    DebugLog(@"md5 md5 input %@", input);
    const char *concat_str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, (int)strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        [hash appendFormat:@"%02X", result[i]];
    }
    
    NSString *resultStr = [NSString stringWithString:hash];
    
    while (resultStr.length < 32) {
        resultStr = [@"0" stringByAppendingString:resultStr];
    }
    
    return [resultStr lowercaseString];
}

#pragma mark - HTTP request

/**
 * Posts the parameters to the URL and return the body of the reply as a
 * String
 *
 * @param stringUrl  The URL to query
 * @param stringPost The data as a query string to post to strURL
 * @param completeBlock Block to handle response data
 * @return a data from the server and pass into complete block
 */
- (void)doHttpStringWithStrUrl:(NSString*)stringUrl
                 andPostString:(NSString*)stringPost
              andCompleteBlock:(void (^)(NSData* data, NSError *error))completeBlock {
    // for normal request, we just use shareSession is enough.
    NSURLSession *defaultSession = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *params =stringPost;
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    //    DebugLog(@"params params data = %@" , params);
    [self doesHTTPRequestExist:urlRequest completion:^(BOOL doesExist) {
        // request exited --> we should wait for response NO need to send another request
        if (doesExist == YES){
//            DebugLog(@"doHttpStringWithStrUrl - the URLRequest existed. Just wait for response");
            return;
        }
        
        NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(error == nil)
            {
                //NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                //DebugLog(@"doHttpStringWithStrUrl json data = %@" , json);
                completeBlock(data, error);
            } else {
                completeBlock(data, error);
            }
        }];
        [dataTask resume];
    }];
}

/**
 * Posts the parameters along with a file to the URL and return the body of the reply as a
 * String
 *
 * @param stringUrl  The URL to query
 * @param params The data as a query string to post to strURL
 * @return a String of the body of the reply from the server
 */

- (NSString*)doMultipartPostWithStrUrl:(NSString*)stringUrl
                             andParams:(NSDictionary*)params
                          withFilePath:(NSString*)filePath
                         withFileField:(NSString*)fileField
                      andCompleteBlock:(void (^)(NSData* data, NSError *error))completeBlock{
    
    // Build the request body
    NSString* boundaryBody = [NSString stringWithFormat:@"*****%f*****" , [[NSDate date] timeIntervalSince1970]];
    NSMutableData *body = [NSMutableData data];
    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
    
    if (data) {
//        DebugLog(@"Data is not nil");
        body = [self prepareHeaderWithBody:body data:data filePath:filePath fileField:fileField boundaryBody:boundaryBody];
    } else {
        DebugLog(@"ERROR ERROR. Data is nil. Why calling send file request and the file data  == NIL");
        // just return here
        completeBlock(nil, [NSError errorWithDomain:@"Send file request with NIL data file" code:404 userInfo:nil]);
    }
    
    // Upload POST Data
    body = [self prepareUploadDataWithBody:body params:params boundaryBody:boundaryBody];
    // send sig last
    body = [self prepareSigWithBody:body params:params boundaryBody:boundaryBody];
    
    //    NSString * bodyString = [[NSString alloc] initWithData:body encoding:NSASCIIStringEncoding];
    
    // Setup the session
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"Connection"    : @"Keep-Alive",
                                                   @"Content-Type"  : [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryBody]
                                                   };
    // Create the session
    // We can use the delegate to track upload progress
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    // Data uploading task. We could use NSURLSessionUploadTask instead of NSURLSessionDataTask if we needed to support uploads in the background
    NSURL *url = [NSURL URLWithString:stringUrl];
//    DebugLog(@"stringUrl stringUrl stringUrl: %@\n", stringUrl);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    NSString *contentTypeString = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundaryBody];
    [request setValue:contentTypeString forHTTPHeaderField:@"Content-Type"];
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Process the response
        //        DebugLog(@"Response:%@ %@\n", response, error);
        if(error == nil)
        {
            //NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            //DebugLog(@"doMultipartPostWithStrUrl json data = %@" , json);
            
            completeBlock(data, error);
        } else {
            completeBlock(data, error);
        }
    }];
    
    [uploadTask resume];
    
    return nil;
}

/*
 This' only support the normal HTTP request as the multipart request requires
 a separate NSURLSession
 */
- (void)doesHTTPRequestExist:(NSURLRequest*)request completion:(void (^)(BOOL doesExist))completionBlock{
    [[NSURLSession sharedSession] getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        // check dataTasks
        for (NSURLSessionDataTask *dataTask in dataTasks){
            // get request object
            NSURLRequest *originalRequest = dataTask.originalRequest;
            //compare with the input request. URL,method, data body
            if ([request.URL.absoluteString isEqualToString:originalRequest.URL.absoluteString] == YES){
                if ([request.HTTPMethod isEqualToString:originalRequest.HTTPMethod] == YES){
                    if([request.HTTPBody isEqualToData:originalRequest.HTTPBody]){
                        // Yeah the request existed. We should wait for response
                        completionBlock(YES);
                        break;
                    }
                }
            }
        }
        
        completionBlock(NO);
    }];
}

#pragma mark - Request Util Methods

/**
 * Send request to server with method name, post data and complete block to handle response
 *
 * @param rpcName method name
 * @param params The data as a query string to post to server
 */

- (void)sendRequest:(NSString *)rpcName
        andPostData:(NSMutableDictionary*)postData
   andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
//    DebugLog(@"sendRequest sendRequest ");
    [self sendRequestWithFilePath:rpcName andUserCredsLoginRequired:NOT_REQUIRED andPostData:postData andFilePath:nil andCompleteBlock:completeBlock];
}

/**
 * Send request to server with method name, post data and complete block to handle response
 *
 * @param rpcName method name
 * @param loginRequired REQUIRED, OPTIONAL, NOT_REQUIRED
 * @param params The data as a query string to post to server
 */
- (void)sendRequest:(NSString *)rpcName
  withLoginRequired:(LoginReq)loginRequired
        andPostData:(NSMutableDictionary*)postData
   andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock {
    
    [self sendRequestWithFilePath:rpcName andUserCredsLoginRequired:loginRequired andPostData:postData andFilePath:nil andCompleteBlock:completeBlock];
}

/**
 * Send request to server with method name, post data, file path and complete block to handle response
 *
 * @param rpcName method name
 * @param postData The data as a query string to post to server
 * @param filePath Path to the file that want to post to server
 */
- (void)sendRequestWithFilePath:(NSString*)rpcName
      andUserCredsLoginRequired:(LoginReq)loginRequired
                    andPostData:(NSMutableDictionary*)postData
                    andFilePath:(NSString*)filePath
               andCompleteBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
//    DebugLog(@"sendRequestWithFilePath sendRequestWithFilePath ");
    long currtime = (long)([[NSDate date] timeIntervalSince1970]);
    postData = [self fillParams:rpcName andUserCredsLoginRequired:loginRequired andPostData:postData andCurrentTime:currtime];
    [self doPost:postData withFilePath:filePath andCompleteBlock:^(NSData* data, NSError *error) {
        if(data == nil || error){
            [self doPost:postData withFilePath:filePath andCompleteBlock:^(NSData* data, NSError *error) {
                if(data != nil && error == nil){
                    [self checkServerTimestampAndPostData:postData data:data error:error filePath:filePath currentTime:currtime completeBlock:completeBlock];
                } else {
                    DebugLog(@"retry failed");
                }
            }];
        } else {
            [self checkServerTimestampAndPostData:postData data:data error:error filePath:filePath currentTime:currtime completeBlock:completeBlock];
        }
        
    }];
}

-(void)checkServerTimestampAndPostData:(NSMutableDictionary*)postData
                                  data:(NSData*)data
                                 error:(NSError *)error
                              filePath:(NSString*)filePath
                           currentTime:(long)currtime
                         completeBlock:(void (^)(NSDictionary* responseDict, NSError *error))completeBlock{
    //    DebugLog(@"checkServerTimestampAndPostData checkServerTimestampAndPostData");
    NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([self hasError:responseDict andErrorString:@"error.timestamp"]){
        long svrtime = [[responseDict objectForKey:@"server_timestamp"] longValue];
        tsoffset = svrtime - currtime;
        [postData setObject:[NSString stringWithFormat:@"%ld",(currtime + tsoffset )] forKey:@"ts"];
        [self doPost:postData withFilePath:filePath andCompleteBlock:^(NSData* data, NSError *error){
            if(data != nil){
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                completeBlock(responseDict, error);
            }
        }];
    } else {
//        DebugLog(@"time stamp is correct");
        completeBlock(responseDict, error);
    }
}

/**
 * Prepare params for server request
 *
 * @param rpcName method name
 * @param UserCredsLoginRequired Require login or not
 * @param postData The data as a query string to post to server
 * @param currentTime time that the request is posted
 */
-(NSMutableDictionary*)fillParams:(NSString*)rpcName
        andUserCredsLoginRequired:(LoginReq)loginRequired
                      andPostData:(NSMutableDictionary*)postData
                   andCurrentTime:(long)currentTime {
    
    if (postData == nil) {
        postData = [[NSMutableDictionary alloc] init];
    }
    NSString *eventValue = [postData objectForKey:@"events"];
    if(eventValue != nil){
        eventValue = [eventValue stringByReplacingOccurrencesOfString:@"\n"
                                                           withString:@""];
        [postData removeObjectForKey:@"events"];
        [postData setObject:eventValue forKey:@"events"];
    }
//    DebugLog(@"CLIENT ID ===== %d", clientId);
    [postData setObject:rpcName forKey:@"method"];
    [postData setObject:VERSION forKey:@"v"];
    [postData setObject:[NSString stringWithFormat:@"%ld", (currentTime + tsoffset)] forKey:@"ts"];
    [postData setObject:[NSString stringWithFormat:@"%d", clientId] forKey:@"client_id"];
    [postData setObject:[NSString stringWithFormat:@"%ld", tsoffset] forKey:@"device_time_offset"];
    [postData setObject:udid forKey:@"udid"];
    
    if(loginRequired == REQUIRED){
        if([creds hasToken] == NO){
            DebugLog(@"ERROR. Login Require BUT user token not existed."); // TODO: must handle later
        } else {
            [postData setObject:[creds getToken] forKey:@"token"];
        }
    } else if (loginRequired == OPTIONAL){
        if([creds hasToken] == YES){
            [postData setObject:[creds getToken] forKey:@"token"];
        }
    }
    
    return postData;
}


/**
 * Post the string to the base_url and return the reponse as a JSON object
 *
 * @param postdata The parameters to post as a Query String
 * @param filepath filename of hte file to upload or null
 * @return a JSON Object with the response from the server
 * @throws JSONException                    Invalid JSON from server
 * @throws ServerCommunicationPermException Permanently failed to post
 * @throws ServerCommunicationTempException Temporarily failed to post
 */
- (void)doPost:(NSDictionary*)postData withFilePath:(NSString*)filePath andCompleteBlock:(void (^)(NSData* data, NSError *error))completeBlock{
    NSString* strPost = [self map2qs:postData];
//    DebugLog(@"doPost doPost ");
    // Calculate the hash of params
    NSString* sig = [self md5:strPost];
    strPost = [NSString stringWithFormat:@"%@&sig=%@" ,strPost, sig];
    //DebugLog(@"doPost strPost %@", strPost);
    if (filePath != nil) {
        if (uploadBaseUrl == nil) {
            //throw exception
            DebugLog(@"upload_base_url is nil");
        }
        [postData setValue:sig forKeyPath:@"sig"];
        // do upload file
        [self doMultipartPostWithStrUrl:uploadBaseUrl andParams:postData withFilePath:filePath withFileField:@"upload_file" andCompleteBlock:^(NSData* data, NSError *error) {
            completeBlock(data, error);
        }];
        
    } else {
        //        DebugLog(@"doPost - data: %@", strPost);
        [self doHttpStringWithStrUrl:baseUrl andPostString:strPost andCompleteBlock:^(NSData* data, NSError *error) {
            completeBlock(data, error);
        }];
    }
}


#pragma mark - Multipart helpers

/**
 * Prepare header body for the request
 **/
-(NSMutableData *)prepareHeaderWithBody:(NSMutableData*)body data:(NSData*)data filePath:(NSString *)filePath fileField:(NSString*)fileField boundaryBody:(NSString *)boundaryBody{
    
    NSString* lineEnd = @"\r\n";
    NSString* twoHyphens = @"--";
    //find the data extension
    NSString* dataType = filePath.lastPathComponent.pathExtension;
    if ([dataType isEqualToString:@"jpg"] == YES) dataType = @"jpeg";
    
    [body appendData:[[NSString stringWithFormat:@"%@%@%@", twoHyphens,boundaryBody,lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    //DebugLog(@"file Field = %@   file name = %@" , fileField , filePath.lastPathComponent );
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\";filename=\"%@\"%@", fileField, filePath.lastPathComponent ,lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/%@%@", dataType, lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    [body appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    [body appendData:[[NSString stringWithFormat:@"%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    [body appendData:data];
    [body appendData:[[NSString stringWithFormat:@"%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    
    return body;
}

/**
 * Prepare upload data for the request
 **/
-(NSMutableData *)prepareUploadDataWithBody:(NSMutableData*)body params:(NSDictionary *)params boundaryBody:(NSString *)boundaryBody{
    NSString* lineEnd = @"\r\n";
    NSString* twoHyphens = @"--";
    for (NSString* key in params) {
        if ([key isEqualToString:@"sig"]) {
        } else {
            [body appendData:[[NSString stringWithFormat:@"%@%@%@", twoHyphens,boundaryBody,lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"%@",key,lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
            [body appendData:[[NSString stringWithFormat:@"Content-Type: text/plain%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
            [body appendData:[[NSString stringWithFormat:@"%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
            [body appendData:[[NSString stringWithFormat:@"%@", [params objectForKey:key]] dataUsingEncoding:NSUTF8StringEncoding ]];
            [body appendData:[[NSString stringWithFormat:@"%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
        }
        
    }
    return body;
}

/**
 * Prepare signature for the request
 **/
-(NSMutableData *)prepareSigWithBody:(NSMutableData*)body params:(NSDictionary *)params boundaryBody:(NSString *)boundaryBody{
    NSString* lineEnd = @"\r\n";
    NSString* twoHyphens = @"--";
    
    [body appendData:[[NSString stringWithFormat:@"%@%@%@", twoHyphens,boundaryBody,lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"sig\"%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: text/plain%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    [body appendData:[[NSString stringWithFormat:@"%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    [body appendData:[[NSString stringWithFormat:@"%@", [params objectForKey:@"sig"]] dataUsingEncoding:NSUTF8StringEncoding ]];
    [body appendData:[[NSString stringWithFormat:@"%@",lineEnd] dataUsingEncoding:NSUTF8StringEncoding ]];
    
    //DebugLog(@"params sig = %@" , [params objectForKey:@"sig"]);
    return body;
}


@end
