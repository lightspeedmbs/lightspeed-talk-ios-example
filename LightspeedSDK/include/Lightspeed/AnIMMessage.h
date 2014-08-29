#import "AnIM.h"

@interface AnIMMessage : NSObject {

}

@property (readonly, nonatomic, assign) AnIMMessageType type;
@property (readonly, nonatomic, retain) NSString *msgId;
@property (readonly, nonatomic, retain) NSString *topicId;
@property (readonly, nonatomic, retain) NSString *message;
@property (readonly, nonatomic, retain) NSData *content;
@property (readonly, nonatomic, copy) NSString *fileType;
@property (readonly, nonatomic, copy) NSString *from;
@property (readonly, nonatomic, retain) NSDictionary *customData;
@property (readonly, nonatomic, retain) NSNumber *timestamp;

- (id)initWithType:(AnIMMessageType)type msgId:(NSString*)msgId topicId:(NSString*)topicId message:(NSString*)message content:(NSData*)content fileType:(NSString*)fileType from:(NSString*)from customData:(NSDictionary*)customData timestamp:(NSNumber*)timestamp;
@end