//
//  AnIM.h
//  AnIM
//
//  Copyright (c) 2014 arrownock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArrownockException.h"

@class AnIM;
@protocol AnIMDelegate <NSObject>

@optional
- (void)anIM:(AnIM *)anIM messageSent:(NSString *)messageId;
- (void)anIM:(AnIM *)anIM sendReturnedException:(ArrownockException *)exception messageId:(NSString *)messageId;
- (void)anIM:(AnIM *)anIM messageReceived:(NSString *)messageId from:(NSString *)from;
- (void)anIM:(AnIM *)anIM messageRead:(NSString *)messageId from:(NSString *)from;

- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp;
- (void)anIM:(AnIM *)anIM didReceiveNotice:(NSString *)notice customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp;

//------------------------------------------
// return the error with ArrownockException
- (void)anIM:(AnIM *)anIM didGetClientId:(NSString *)clientId exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didUpdateStatus:(BOOL)status exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didCreateTopic:(NSString *)topicId exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didUpdateTopicWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didAddClientsWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didRemoveClientsWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didRemoveTopic:(NSString *)topicId exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didGetTopicInfo:(NSString *)topicId name:(NSString *)topicName parties:(NSSet *)parties createdDate:(NSDate *)createdDate exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didGetTopicLog:(NSArray *)logs exception:(ArrownockException *)exception __attribute__((deprecated));
- (void)anIM:(AnIM *)anIM didGetTopicList:(NSArray *)topics exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didBindServiceWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didUnbindServiceWithException:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didGetClientsStatus:(NSDictionary *)clientsStatus exception:(ArrownockException *)exception;
- (void)anIM:(AnIM *)anIM didGetSessionInfo:(NSString *)sessionId parties:(NSSet *)parties exception:(ArrownockException *)exception;
@end

typedef enum {
    AnPushTypeiOS,
    AnPushTypeAndroid,
    AnPushTypeWP8
} AnPushType;

typedef enum {
    AnIMTextMessage,
    AnIMBinaryMessage
} AnIMMessageType;

@interface AnIM : NSObject
- (AnIM *)initWithAppKey:(NSString *)appKey delegate:(id <AnIMDelegate>)delegate secure:(BOOL)secure;

- (void)getClientId:(NSString *)userId;
- (NSString *)getRemoteClientId:(NSString *)userId;
- (void)connect:(NSString *)clientId;
- (void)disconnect;

- (NSString *)sendMessage:(NSString *)message toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need;
- (NSString *)sendMessage:(NSString *)message customData:(NSDictionary *)customData toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need;
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need;
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need;

- (NSString *)sendMessage:(NSString *)message toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;
- (NSString *)sendMessage:(NSString *)message customData:(NSDictionary *)customData toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;
- (NSString *)sendBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;

- (NSString *)sendNotice:(NSString *)notice toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need;
- (NSString *)sendNotice:(NSString *)notice customData:(NSDictionary *)customData toClients:(NSSet *)clientIds needReceiveACK:(BOOL)need;
- (NSString *)sendNotice:(NSString *)notice toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;
- (NSString *)sendNotice:(NSString *)notice customData:(NSDictionary *)customData toTopicId:(NSString *)topicId needReceiveACK:(BOOL)need;

- (NSString *)sendReadACK:(NSString *)messageId toClients:(NSSet *)clientIds;

- (void)createTopic:(NSString *)topicName;
- (void)createTopic:(NSString *)topicName withClients:(NSSet *)clientIds;
- (void)createTopic:(NSString *)topicName withOwner:(NSString *)owner withClients:(NSSet *)clientIds;
- (void)updateTopic:(NSString *)topicId withName:(NSString *)topicName withOwner:(NSString *)owner;
- (void)addClients:(NSSet *)clientIds toTopicId:(NSString *)topicId;
- (void)removeClients:(NSSet *)clientIds fromTopicId:(NSString *)topicId;
- (void)removeTopic:(NSString *)topicId;
- (void)getTopicInfo:(NSString *)topicId;
- (void)getTopicLog:(NSString *)topicId start:(NSDate *)start end:(NSDate *)end __attribute__((deprecated));

- (void)getTopicHistory:(NSString *)topicId clientId:(NSString *)clientId limit:(int)limit timestamp:(NSNumber *)timestamp success:(void (^)(NSArray *messages))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getFullTopicHistory:(NSString *)topicId limit:(int)limit timestamp:(NSNumber *)timestamp success:(void (^)(NSArray *messages))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getFullTopicHistory:(NSString *)topicId clientId:(NSString *)clientId limit:(int)limit timestamp:(NSNumber *)timestamp success:(void (^)(NSArray *messages))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getHistory:(NSSet *)clientIds clientId:(NSString *)clientId limit:(int)limit timestamp:(NSNumber *)timestamp success:(void (^)(NSArray *messages))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getOfflineTopicHistory:(NSString *)clientId limit:(int)limit success:(void (^)(NSArray *messages, int count))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getOfflineTopicHistory:(NSString *)topicId clientId:(NSString *)clientId limit:(int)limit success:(void (^)(NSArray *messages, int count))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getOfflineHistory:(NSString *)clientId limit:(int)limit success:(void (^)(NSArray *messages, int count))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getOfflineHistory:(NSSet *)clientIds clientId:(NSString *)clientId limit:(int)limit success:(void (^)(NSArray *messages, int count))success failure:(void (^)(ArrownockException *exception))failure;

- (void)getAllTopics;
- (void)getMyTopics;

- (void)bindAnPushService:(NSString *)anId appKey:(NSString *)appKey deviceType:(AnPushType)deviceType;
- (void)unbindAnPushService:(AnPushType)deviceType;

- (void)getClientsStatus:(NSSet *)clientIds;
- (void)getSessionInfo:(NSString *)sessionId;

- (void)setPushNotificationForChatSession:(NSString *)clientId isEnable:(BOOL)isEnable success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)setPushNotificationForTopic:(NSString *)clientId isEnable:(BOOL)isEnable success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)setPushNotificationForNotice:(NSString *)clientId isEnable:(BOOL)isEnable success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)enablePushNotificationForTopics:(NSString *)clientId topicIds:(NSSet *)topicIds success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
- (void)disablePushNotificationForTopics:(NSString *)clientId topicIds:(NSSet *)topicIds success:(void (^)())success failure:(void (^)(ArrownockException *exception))failure;
@end
