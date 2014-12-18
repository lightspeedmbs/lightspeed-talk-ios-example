//
//  HXLightspeedManager.h
//  ChatDemo
//
//  Created by Tim on 8/23/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnIM.h"

typedef enum {
    AnSocialManagerGET,
    AnSocialManagerPOST
} AnSocialManagerMethod;

@protocol HXLightspeedManagerSignInDelegate
- (void)lightspeedTalkSignedIn;
@end

@protocol HXLightspeedManagerTalkDelegate
@optional
- (void)messageSent:(NSString *)messageId;
- (void)didGetClientStatus:(NSDictionary *)clientStatus;
@end

@protocol HXLightspeedManagerTopicDelegate
- (void)didGetTopicList:(NSArray *)topics;
- (void)newTopicCreated:(NSString *)exception;
//- (void)didGetTopicInfo:(NSString *)topicId name:(NSString *)topicName parties:(NSSet *)parties createdDate:(NSDate *)createdDate;

@end

@interface HXLightspeedManager : NSObject
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *username;
@property (weak, nonatomic) id<HXLightspeedManagerSignInDelegate> signInDelegate;
@property (weak, nonatomic) id<HXLightspeedManagerTalkDelegate> talkDelegate;
@property (weak, nonatomic) id<HXLightspeedManagerTopicDelegate> topicDelegate;

+ (HXLightspeedManager *)manager;
- (AnIM *)anIM;
- (void)logOut;
- (void)saveFriendsIds:(NSArray *)friends;
- (NSDictionary *)getCircleFriendForClientId:(NSString *)clientId;

- (void)sendRequest:(NSString *)path
             method:(AnSocialManagerMethod)method
             params:(NSDictionary *)params
            success:(void (^)(NSDictionary *response))success
            failure:(void (^)(NSDictionary *response))failure;
@end
