//
//  HXImagePresentViewController.m
//  Tinichat
//
//  Created by Tim on 8/27/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import "HXImagePresentViewController.h"
#import "HXLightspeedManager.h"
@interface HXImagePresentViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *presentedImage;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

@end

@implementation HXImagePresentViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (_isSendMode) {
        self.presentedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mrLight"]];
    } else {
        if ([self.fileType isEqualToString:@"image"]) {
            self.presentedImage = [[UIImageView alloc] initWithImage:[UIImage imageWithData:self.fileData]];
        }
    }
    self.presentedImage.center = self.view.center;
    [self.view addSubview:self.presentedImage];
    
    if (!_isSendMode) {
        self.navigationItem.RightBarButtonItem = nil;
        [self.cancelButton setTitle:@"Back"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Listner

- (IBAction)cancelButtonListener:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonListener:(UIBarButtonItem *)sender
{
    if (self.receiverId) {
        [[[HXLightspeedManager manager] anIM] sendBinary:UIImagePNGRepresentation(self.presentedImage.image)
                                                                       fileType:@"image"
                                                                      toClients:[NSSet setWithObject:self.receiverId]
                                                                 needReceiveACK:NO];
    } else {
        [[[HXLightspeedManager manager] anIM] sendBinary:UIImagePNGRepresentation(self.presentedImage.image)
                                                fileType:@"image"
                                               toTopicId:self.topicInfo[@"id"]
                                          needReceiveACK:NO];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
