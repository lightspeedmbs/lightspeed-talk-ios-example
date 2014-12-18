#import <Foundation/Foundation.h>

@interface AnSocialFile : NSObject

+ (AnSocialFile *)createWithFileName:(NSString *)name data:(NSData *)data;

@property (readonly, nonatomic, retain) NSString *name;
@property (readonly, nonatomic, retain) NSData *data;

@end