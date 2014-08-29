//
//  HXLightspeedManager.h
//  ChatDemo
//
//  Created by Tim on 8/23/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRM.h"
#import "AnIM.h"

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
@property (strong, nonatomic) NSString *circleId;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *username;
@property (weak, nonatomic) id<HXLightspeedManagerSignInDelegate> signInDelegate;
@property (weak, nonatomic) id<HXLightspeedManagerTalkDelegate> talkDelegate;
@property (weak, nonatomic) id<HXLightspeedManagerTopicDelegate> topicDelegate;

+ (HXLightspeedManager *)manager;
- (MRM *)mrm;
- (AnIM *)anIM;

- (void)logOut;
- (void)saveFriendsIds:(NSArray *)friends;
- (NSDictionary *)getCircleFriendForClientId:(NSString *)clientId;

@end
