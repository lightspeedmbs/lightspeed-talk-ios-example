//
//  HXChatViewController.h
//  Tinichat
//
//  Created by Tim on 8/25/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXChatViewController : UIViewController
@property (strong, nonatomic) NSDictionary *friendInfo;
@property (strong, nonatomic) NSMutableDictionary *topicInfo;
@property BOOL isTopicMode;

@end
