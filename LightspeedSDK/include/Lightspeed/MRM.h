//
//  MRM.h
//  MRM
//
//  Copyright (c) 2014 arrownock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRM : NSObject

- (MRM *)initWithAppKey:(NSString *)appKey secure:(BOOL)secure;
- (void)setTimeout:(NSTimeInterval)secondTimeout;

- (int)sendGetRequest:(NSString *)urlPathString
               withId:(NSString *)objectId
              success:(void (^)(int statusCode, NSDictionary *response))success
              failure:(void (^)(int statusCode, NSDictionary *response))failure;
- (int)sendPostRequest:(NSString *)urlPathString
                params:(NSDictionary *)params
               success:(void (^)(int statusCode, NSDictionary *response))success
               failure:(void (^)(int statusCode, NSDictionary *response))failure;
- (int)uploadData:(NSString *)urlPathString
           params:(NSDictionary *)params
           data:(NSData *)data
         dataType:(NSString *)dataType
          success:(void (^)(int statusCode, NSDictionary *response))success
          failure:(void (^)(int statusCode, NSDictionary *response))failure;
- (int)sendDeleteRequest:(NSString *)urlPathString
                  withId:(NSString *)objectId
                 success:(void (^)(int statusCode, NSDictionary *response))success
                 failure:(void (^)(int statusCode, NSDictionary *response))failure;
- (int)download:(NSString *)urlPathString
          doing:(void (^)(int bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))doing
        success:(void (^)(NSData *data))success
        failure:(void (^)(NSDictionary *response))failure;

@end
