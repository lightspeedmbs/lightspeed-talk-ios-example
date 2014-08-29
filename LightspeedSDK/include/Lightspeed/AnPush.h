//
//  AnPush.h
//  AnPush
//
//  Copyright (c) 2014 Arrownock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ArrownockException.h"

/**
 * AnPushDelegate 
 * SDK 的回调方法
 */
@protocol AnPushDelegate <NSObject>

@optional
/**
 * 设备注册回调方法
 * @param anid 设备ID(如果注册失败, 此参数值为 nil)
 * @param error 错误信息(如果注册操作成功, 此参数值为 nil)
 * @param exception 包括Arrownock错误码和错误信息描述
 */
- (void)didRegistered:(NSString *)anid withError:(NSString *)error;
- (void)didRegistered:(NSString *)anid withException:(ArrownockException *)exception;

/**
 * 设备注销回调方法
 * @param success 运行结果<br/> YES - 成功 <br/> NO - 失败
 * @param error 错误信息(如果注销操作成功, 此参数值为 nil)
 * @param exception 包括Arrownock错误码和错误信息描述
 */
- (void)didUnregistered:(BOOL)success withError:(NSString *)error;
- (void)didUnregistered:(BOOL)success withException:(ArrownockException *)exception;

/**
 * 设置静默回调方法
 * @param success 运行结果<br/> YES - 成功 <br/> NO - 失败
 * @param error 错误信息(如果设置操作成功, 此参数值为 nil)
 * @param exception 包括Arrownock错误码和错误信息描述
 */
- (void)didSetMute:(BOOL)success withError:(NSString *)error;
- (void)didSetMute:(BOOL)success withException:(ArrownockException *)exception;

/**
 * 取消静默回调方法
 * @param success 运行结果<br/> YES - 成功 <br/> NO - 失败
 * @param error 错误信息(如果取消操作成功, 此参数值为 nil)
 * @param exception 包括Arrownock错误码和错误信息描述
 */
- (void)didClearMute:(BOOL)success withError:(NSString *)error;
- (void)didClearMute:(BOOL)success withException:(ArrownockException *)exception;

/**
 * 设置免打扰模式回调方法
 * @param success 运行结果<br/> YES - 成功 <br/> NO - 失败
 * @param error 错误信息(如果设置操作成功, 此参数值为 nil)
 * @param exception 包括Arrownock错误码和错误信息描述
 */
- (void)didSetSilent:(BOOL)success withError:(NSString *)error;
- (void)didSetSilent:(BOOL)success withException:(ArrownockException *)exception;

/**
 * 取消免打扰模式回调方法
 * @param success 运行结果<br/> YES - 成功 <br/> NO - 失败
 * @param error 错误信息(如果取消操作成功, 此参数值为 nil)
 * @param exception 包括Arrownock错误码和错误信息描述
 */
- (void)didClearSilent:(BOOL)success withError:(NSString *)error;
- (void)didClearSilent:(BOOL)success withException:(ArrownockException *)exception;
@end

/**
 * 主要工具类
 * 包含开启推送服务、设备注册/注销等主要功能
 */
@interface AnPush : NSObject

/**
 * 获得 AnPush 类的实例
 * 
 * @return AnPush
 */
+ (AnPush *)shared;

/**
 * 注册推送通知类型
 * 此方法为工具方法
 * @param types 推送通知类型，可注册多
 */
+ (void)registerForPushNotification:(UIRemoteNotificationType)types;

/**
 * 初始化 AnPush 实例
 * 
 * @param appKey 应用的密匙(App Key)，可在管理控制台获取
 * @param deviceToken 应用的推送唯一码(Device Token)
 * @param delegate AnPushDelegate 的实例
 * @param secure 是否使用安全传输方式 <br/> - YES 安全 <br/> - NO 非安全
 */
+ (void)setup:(NSString *)appKey deviceToken:(NSData *)deviceToken delegate:(id <AnPushDelegate>)delegate secure:(BOOL)secure;

/**
 * 设备注册
 * 为设备注册推送渠道，应用可以定义多个渠道，按不同渠道为不同设备群组推送消息
 * @param channels 要注册的一个或多个推送渠道
 * @param overwrite 是否覆盖已注册的渠道 <br/> - YES 覆盖(所有已注册过的渠道将被本次的渠道所覆盖) <br/> - NO 不覆盖(本次注册渠道将增加到设备已注册的渠道列表中)
 */
- (void)register:(NSArray *)channels overwrite:(BOOL)overwrite;

/**
 * 设备注销
 * 注销已注册的所有渠道
 */
- (void)unregister;

/**
 * 设备注销
 * 注销指定推送渠道
 * @param channels 要注销的一个或多个推送渠道
 */
- (void)unregister:(NSArray *)channels;

/**
 * 设置静默推送
 * 所有接收到的推送消息均采用静音方式
 */
- (void)setMute;

/**
 * 设置静默推送及适用时段
 * 所有接收到的推送消息在某一时间段内均采用静音方式
 * @param startHour 静默推送的开始时间(小时)
 * @param minute 静默推送的开始时间(分钟)
 * @param duration 静默推送的持续时长(秒)
 */
- (void)setMuteWithHour:(NSInteger)startHour minute:(NSInteger)startMinute duration:(NSInteger)duration;

/**
 * 取消静默推送设置
 */
- (void)clearMute;

/**
 * 设置免打扰模式及适用时段
 * 在设置时间段内将不会有任何推送消息
 * @param startHour 免打扰模式的开始时间(小时)
 * @param minute 免打扰模式的开始时间(分钟)
 * @param duration 免打扰模式的持续时长(秒)
 * @param resend 是否重发推送消息 <br/> 在免打扰时段内如果有推送消息，可使用此参数设置是否在时段结束后重新推送该消息 <br/> YES - 重新发送  <br/> NO - 不发送 (该消息将丢失)
 */
- (void)setSilentWithHour:(NSInteger)startHour minute:(NSInteger)startMinute duration:(NSInteger)duration resend:(BOOL)resend;

/**
 * 取消静默推送设置
 */
- (void)clearSilent;

/**
 * 获取设备ID
 * @return NSString 设备ID
 */
- (NSString *)getAnID;
- (void)setId:(NSString *)theId;
- (void)setHost:(NSString *)host;
@end
