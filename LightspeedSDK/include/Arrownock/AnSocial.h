#import <Foundation/Foundation.h>

typedef enum {
    AnSocialMethodGET,
    AnSocialMethodPOST
} AnSocialMethod;

@interface AnSocial : NSObject

- (AnSocial *)initWithAppKey:(NSString *)appKey;
- (void)setTimeout:(NSTimeInterval)secondTimeout;
- (void)setSecureConnection:(BOOL)secure;

- (void)sendRequest:(NSString *)path
            method:(AnSocialMethod)method
            params:(NSDictionary *)params
           success:(void (^)(NSDictionary *response))success
           failure:(void (^)(NSDictionary *response))failure;

@end
