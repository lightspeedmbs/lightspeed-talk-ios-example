//
//  HXImagePresentViewController.h
//  Tinichat
//
//  Created by Tim on 8/27/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXImagePresentViewController : UIViewController
@property BOOL isSendMode;
@property (strong, nonatomic) NSString *receiverId;
@property (strong, nonatomic) NSDictionary *topicInfo;
@property (strong, nonatomic) NSString *fileType;
@property (strong, nonatomic) NSData *fileData;
@end
