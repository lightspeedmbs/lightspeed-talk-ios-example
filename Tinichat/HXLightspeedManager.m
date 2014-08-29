//
//  HXLightspeedManager.m
//  ChatDemo
//
//  Created by Tim on 8/23/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import "HXLightspeedManager.h"
#import "LightspeedCredentials.h"

@interface HXLightspeedManager () <AnIMDelegate>
@property (strong, nonatomic) MRM *mrm;
@property (strong, nonatomic) AnIM *anIM;
@property (strong, nonatomic) NSMutableDictionary *clientIdToCircleDictionary;
@end

@implementation HXLightspeedManager

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        self.mrm = [[MRM alloc] initWithAppKey:LIGHTSPEED_APP_KEY secure:YES];
        self.anIM = [[AnIM alloc] initWithAppKey:LIGHTSPEED_APP_KEY delegate:self secure:YES];
    }
    return self;
}

+ (HXLightspeedManager *)manager
{
    static HXLightspeedManager *_manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _manager = [[HXLightspeedManager alloc] init];
    });
    return _manager;
}

#pragma mark - Lightspeed Delegate

- (void)anIM:(AnIM *)anIM didGetClientId:(NSString *)clientId exception:(ArrownockException *)exception;
{
    if (clientId && self.circleId) {
        self.clientId = clientId;
        [self updateClientId:clientId forCircleUser:self.circleId];
    } else {
        NSLog(@"Error getting clientId");
    }
}

- (void)anIM:(AnIM *)anIM didGetClientsStatus:(NSDictionary *)clientsStatus exception:(ArrownockException *)exception
{
    if (!exception) {
        if ([(NSObject *)self.talkDelegate respondsToSelector:@selector(didGetClientStatus:)]) {
            [self.talkDelegate didGetClientStatus:clientsStatus];
        }
    }
}

- (void)anIM:(AnIM *)anIM didUpdateStatus:(BOOL)status exception:(ArrownockException *)exception
{
    if (!status) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"co.herxun.Tinichat.disconnected"
                                                            object:nil];
        UIViewController *aController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [aController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
        [aController dismissViewControllerAnimated:YES completion:^{
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"Server disconnected"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
    }
}

#pragma mark -

// This is for receiving message
- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    //    NSLog(@"the message is: %@", message);
    //    NSLog(@"the messageId is: %@", messageId);
    //    NSLog(@"the sender is: %@", from);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"co.herxun.Tinichat.didReceiveMessage"
                                                        object:@{@"message": message,
                                                                 @"customData": customData ? customData : @"",
                                                                 @"from": from,
                                                                 @"parties": parties,
                                                                 @"messageId": messageId,
                                                                 @"timestamp": timestamp}];
}

- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from parties:(NSSet *)parties messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    //    NSLog(@"the custom file is: %@", fileType);
    //    NSLog(@"the messageId is: %@", messageId);
    //    NSLog(@"the sender is: %@", from);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"co.herxun.Tinichat.didReceiveMessage"
                                                        object:@{@"data": data,
                                                                 @"fileType": fileType,
                                                                 @"customData": customData ? customData : @"",
                                                                 @"from": from,
                                                                 @"parties": parties,
                                                                 @"messageId": messageId,
                                                                 @"timestamp": timestamp}];
}

#pragma mark -

- (void)anIM:(AnIM *)anIM didGetTopicList:(NSArray *)topics exception:(ArrownockException *)exception
{
    if (!exception) {
        [self.topicDelegate didGetTopicList:topics];
    }
}

- (void)anIM:(AnIM *)anIM didCreateTopic:(NSString *)topicId exception:(ArrownockException *)exception
{
    if (!exception)
        [self.topicDelegate newTopicCreated:topicId];
}

- (void)anIM:(AnIM *)anIM didGetTopicInfo:(NSString *)topicId name:(NSString *)topicName parties:(NSSet *)parties createdDate:(NSDate *)createdDate exception:(ArrownockException *)exception
{
//    [self.topicDelegate didGetTopicInfo:topicId name:topicName parties:parties createdDate:createdDate];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"co.herxun.Tinichat.didGetTopicInfo"
                                                        object:@{@"topicId": topicId,
                                                                 @"topicName": topicName,
                                                                 @"parties": parties,
                                                                 @"createdDat": createdDate}];
}

#pragma mark -

- (void)anIM:(AnIM *)anIM didReceiveMessage:(NSString *)message customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"co.herxun.Tinichat.didReceiveTopicMessage"
                                                        object:@{@"message": message,
                                                                 @"customData": customData ? customData : @"",
                                                                 @"from": from,
                                                                 @"topicId": topicId,
                                                                 @"messageId": messageId,
                                                                 @"timestamp": timestamp}];

}

- (void)anIM:(AnIM *)anIM didReceiveBinary:(NSData *)data fileType:(NSString *)fileType customData:(NSDictionary *)customData from:(NSString *)from topicId:(NSString *)topicId messageId:(NSString *)messageId at:(NSNumber *)timestamp
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"co.herxun.Tinichat.didReceiveTopicMessage"
                                                        object:@{@"data": data,
                                                                 @"fileType": fileType,
                                                                 @"customData": customData ? customData : @"",
                                                                 @"from": from,
                                                                 @"topicId": topicId,
                                                                 @"messageId": messageId,
                                                                 @"timestamp": timestamp}];
}

#pragma mark -

- (void)anIM:(AnIM *)anIM messageSent:(NSString *)messageId
{
    NSLog(@"Message sent");
    [self.talkDelegate messageSent:messageId];
}

- (void)anIM:(AnIM *)anIM messageReceived:(NSString *)messageId from:(NSString *)from
{
    NSLog(@"Message received by: %@", from);
}

// This is for receiving message read acknowledgment
- (void)anIM:(AnIM *)anIM messageRead:(NSString *)messageId from:(NSString *)from
{
    NSLog(@"The message with this messageId is already read by the recipient(from)");
}

#pragma mark -

- (void)anIM:(AnIM *)anIM sendReturnedException:(ArrownockException *)exception messageId:(NSString *)messageId
{
    NSLog(@"IM returned exception for message %@! ERROR: %@", messageId, exception);
}

#pragma mark - Public Method

- (MRM *)mrm
{
    return _mrm;
}

- (AnIM *)anIM
{
    return _anIM;
}

- (void)logOut
{
    [_anIM disconnect];
    self.circleId = nil;
    self.clientId = nil;
    self.username = nil;
    self.talkDelegate = nil;
    [self.clientIdToCircleDictionary removeAllObjects];
    [_mrm sendPostRequest:@"users/logout"
                   params:nil
                  success:^(int statusCode, NSDictionary *response) {
                      NSLog(@"User logged out: %@", [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"]);
                  }
                  failure:^(int statusCode, NSDictionary *response) {
                      NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
                  }];
}

- (void)saveFriendsIds:(NSArray *)friends
{
    if (!self.clientIdToCircleDictionary)
        self.clientIdToCircleDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    [friends enumerateObjectsUsingBlock:^(id friend, NSUInteger idx, BOOL *stop) {
//        [self.clientIdToCircleDictionary setObject:friend[@"id"] forKey:friend[@"customFields"][@"clientId"]];
        [self.clientIdToCircleDictionary setObject:friend forKey:friend[@"customFields"][@"clientId"]];
    }];
}

- (NSDictionary *)getCircleFriendForClientId:(NSString *)clientId
{
    return self.clientIdToCircleDictionary[clientId];
}


#pragma mark - Helper

- (void)updateClientId:(NSString *)clientId forCircleUser:(NSString *)circleId
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:circleId forKey:@"id"];
    
    // Data in 'customFields' needs to be in JSON String format
    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"clientId": clientId}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    [params setObject:jsonString forKey:@"customFields"];
    
    [self.mrm sendPostRequest:@"users/update"
                       params:params
                      success:^(int statusCode, NSDictionary *response) {
                          NSLog(@"User updated, response: %@", [response objectForKey:@"response"]);
                          
                          [self.signInDelegate lightspeedTalkSignedIn];
                      }
                      failure:^(int statusCode, NSDictionary *response) {
                          NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
                      }];
}

@end
