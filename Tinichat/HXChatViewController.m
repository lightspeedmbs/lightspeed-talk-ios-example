//
//  HXChatViewController.m
//  Tinichat
//
//  Created by Tim on 8/25/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "HXChatViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HXLightspeedManager.h"
#import "AnIMMessage.h"
#import "HXImagePresentViewController.h"

@interface HXChatViewController () <UITextFieldDelegate, UIActionSheetDelegate, HXLightspeedManagerTalkDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *attachmentBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendBarButton;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) NSMutableArray *messagesArray;
@property CGFloat keyboardHeight;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *memberBarButton;

@end

@implementation HXChatViewController

#pragma mark - View

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.messagesArray = [[NSMutableArray alloc] initWithCapacity:0];
        _keyboardHeight = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillBeHidden:)
                                                     name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMessageNotification)
                                                     name:@"co.herxun.Tinichat.didReceiveMessage"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveMessageNotification)
                                                     name:@"co.herxun.Tinichat.didReceiveTopicMessage"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(talkDisconnected)
                                                     name:@"co.herxun.Tinichat.disconnected"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didGetTopicInfo:)
                                                     name:@"co.herxun.Tinichat.didGetTopicInfo"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (!_isTopicMode) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.title = [self.friendInfo objectForKey:@"username"];
        [self getChatHistory];
    } else {
        self.navigationItem.title = self.topicInfo[@"name"];
        [[[HXLightspeedManager manager] anIM] addClients:[NSSet setWithObject:[HXLightspeedManager manager].clientId] toTopicId:self.topicInfo[@"id"]];
        [self getTopicHistory];
    }
    self.messageTextField.delegate = self;
    [HXLightspeedManager manager].talkDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (_isTopicMode && [self isMovingFromParentViewController])
        [[[HXLightspeedManager manager] anIM] removeClients:[NSSet setWithObject:[HXLightspeedManager manager].clientId] fromTopicId:self.topicInfo[@"id"]];
}

- (void)viewDidLayoutSubviews
{
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height - self.toolBar.bounds.size.height - _keyboardHeight;

    self.tableView.frame = frame;
    frame = self.toolBar.frame;
    frame.origin = CGPointMake(0, self.tableView.bounds.size.height);
    self.toolBar.frame = frame;
    
    
    if (self.messagesArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"imagePresentation"]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            int idx = (int)[self.tableView indexPathForCell:sender].row;
            if ([[self.messagesArray[idx] fileType] isEqualToString:@"image"]) {
                return YES;
            } else if ([[[self.messagesArray[idx] customData] objectForKey:@"type"] isEqualToString:@"link"]) {
                NSURL *url = [NSURL URLWithString:[[self.messagesArray[idx] customData] objectForKey:@"data"]];
                [[UIApplication sharedApplication] openURL:url];
            } else if ([[[self.messagesArray[idx] customData] objectForKey:@"type"] isEqualToString:@"video"]) {
                NSURL *urlString=[NSURL URLWithString:[[self.messagesArray[idx] customData] objectForKey:@"data"]];
                NSLog(@"Movie url: |%@|", urlString);
                self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:urlString];
                self.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
                [self.moviePlayer prepareToPlay];
                [self.moviePlayer.view setFrame: self.view.bounds];
                [self.view addSubview: self.moviePlayer.view];
                [self.moviePlayer setFullscreen:YES animated:YES];
                [self.moviePlayer play];
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(playerViewDidExitFullScreen)
                                                             name:MPMoviePlayerWillExitFullscreenNotification
                                                           object:self.moviePlayer];
            } else if ([[[self.messagesArray[idx] customData] objectForKey:@"type"] isEqualToString:@"location"]) {
                NSArray *mapData = [[[self.messagesArray[idx] customData] objectForKey:@"data"] componentsSeparatedByString:@","];
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.apple.com/maps?t=k&ll=%@,%@", mapData[0], mapData[1]]];

                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"imagePresentation"]) {
        HXImagePresentViewController *IPVC = (HXImagePresentViewController *)[(UINavigationController *)[segue destinationViewController] topViewController];
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            IPVC.isSendMode = NO;
            int idx = (int)[self.tableView indexPathForCell:sender].row;
            IPVC.fileType = [self.messagesArray[idx] fileType];
            IPVC.fileData = [self.messagesArray[idx] content];
        } else {
            IPVC.isSendMode = YES;
            if (!_isTopicMode) {
                IPVC.receiverId = [self.friendInfo objectForKey:@"clientId"];
            } else {
                IPVC.topicInfo = self.topicInfo;
            }
        }
    }
}

#pragma mark - Keyboard Notification

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _keyboardHeight = kbSize.height;

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.toolBar.frame = CGRectMake(self.toolBar.frame.origin.x,
                                    self.view.bounds.size.height - kbSize.height - self.toolBar.bounds.size.height,
                                    self.toolBar.bounds.size.width,
                                    self.toolBar.bounds.size.height);
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height - self.toolBar.bounds.size.height - _keyboardHeight;
    self.tableView.frame = frame;
    [UIView commitAnimations];
    
    if (self.messagesArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messagesArray.count-1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification *)aNotification
{
    _keyboardHeight = 0;
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[aNotification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[aNotification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.toolBar.center = CGPointMake(self.toolBar.center.x,
                                      self.toolBar.center.y + kbSize.height);
    CGRect frame = self.tableView.frame;
    frame.size.height += kbSize.height;
    self.tableView.frame = frame;

    [UIView commitAnimations];
}

#pragma mark - HXLightspeedManager Delegate & Notification

- (void)messageSent:(NSString *)messageId
{
    if (!_isTopicMode) {
        [self getChatHistory];
    } else {
        [self getTopicHistory];
        [[[HXLightspeedManager manager] anIM] getTopicInfo:self.topicInfo[@"id"]];
    }
}

- (void)didReceiveMessageNotification
{
    if (!_isTopicMode) {
        [self getChatHistory];
    } else {
        [self getTopicHistory];
        [[[HXLightspeedManager manager] anIM] getTopicInfo:self.topicInfo[@"id"]];
    }
}

- (void)talkDisconnected
{
    if (_isTopicMode) {
        [[[HXLightspeedManager manager] anIM] removeClients:[NSSet setWithObject:[HXLightspeedManager manager].clientId] fromTopicId:self.topicInfo[@"id"]];
    }
}

- (void)didGetTopicInfo:(NSNotification *)notificaiton
{
    self.topicInfo[@"name"] = notificaiton.object[@"topicName"];
    self.topicInfo[@"parties"] = [notificaiton.object[@"parties"] allObjects];
    self.topicInfo[@"parties_count"] = [NSNumber numberWithInt:[notificaiton.object[@"parties"] count]];
}

#pragma mark - UITextFieldDeleagte

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"messageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *messageLabel = (UILabel *)[cell viewWithTag:101];
    
    if ([self.messagesArray[indexPath.row] customData]) {
        if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"link"]) {
            messageLabel.text = [NSString stringWithFormat:@"[Link]"];
            messageLabel.textColor = UIColorFromRGB(0xea9c29);
        } else if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"video"]) {
            messageLabel.text = [NSString stringWithFormat:@"[Video]"];
            messageLabel.textColor = UIColorFromRGB(0xec4f54);
        } else if ([[[self.messagesArray[indexPath.row] customData] objectForKey:@"type"] isEqualToString:@"location"]) {
            messageLabel.text = [NSString stringWithFormat:@"[Location]"];
            messageLabel.textColor = UIColorFromRGB(0x27abb9);
        }
    } else if ([self.messagesArray[indexPath.row] message]) {
        messageLabel.text = [self.messagesArray[indexPath.row] message];
        messageLabel.textColor = [UIColor blackColor];
    } else {
        messageLabel.text = [self stringForCustomFileType:[self.messagesArray[indexPath.row] fileType]];
        messageLabel.textColor = UIColorFromRGB(0x7ca941);
    }
    
    if ([[self.messagesArray[indexPath.row] from] isEqualToString:[HXLightspeedManager manager].clientId]) {
        nameLabel.text = @"Me";
        nameLabel.textAlignment = NSTextAlignmentRight;
        messageLabel.textAlignment = NSTextAlignmentRight;
    } else {
        if (!_isTopicMode) {
            nameLabel.text = [self.friendInfo objectForKey:@"username"];
        } else {
            nameLabel.text = [[HXLightspeedManager manager] getCircleFriendForClientId:[self.messagesArray[indexPath.row] from]][@"username"];
        }
        nameLabel.textAlignment = NSTextAlignmentLeft;
        messageLabel.textAlignment = NSTextAlignmentLeft;
    }
    return cell;
}

#pragma mark - Listener

- (IBAction)sendBarButtonListener:(id)sender
{
    if (!self.messageTextField.text.length) return;
    if (!_isTopicMode) {
        [[[HXLightspeedManager manager] anIM] sendMessage:self.messageTextField.text
                                                toClients:[NSSet setWithObject:[self.friendInfo objectForKey:@"clientId"]]
                                           needReceiveACK:YES];
    } else {
        [[[HXLightspeedManager manager] anIM] sendMessage:self.messageTextField.text
                                                toTopicId:self.topicInfo[@"id"]
                                           needReceiveACK:YES];
    }
    self.messageTextField.text = @"";
}

- (IBAction)addBarButtonListener:(id)sender
{
    [self textFieldShouldReturn:self.messageTextField];

    NSString *button1 = @"Send Image";
    NSString *button2 = @"Send Link";
    NSString *button3 = @"Send Video";
    NSString *button4 = @"Send Location";
    NSString *cancelTitle = @"Cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:button1, button2, button3, button4, nil];
    [actionSheet showInView:self.view];
}

- (IBAction)memberBarButtonListener:(id)sender
{

    NSMutableString *memeberListString = [NSMutableString string];
    [self.topicInfo[@"parties"] enumerateObjectsUsingBlock:^(id memeberId, NSUInteger idx, BOOL *stop) {
        if ([[HXLightspeedManager manager] getCircleFriendForClientId:memeberId][@"username"]) {
                [memeberListString appendString:[NSString stringWithFormat:@"%@\n", [[HXLightspeedManager manager] getCircleFriendForClientId:memeberId][@"username"]]];
        }
    }];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Member"
                                                        message:memeberListString
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UIActionsheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!_isTopicMode) {
        switch (buttonIndex) {
            case 0: {
                // Share Image
                [self performSegueWithIdentifier:@"imagePresentation" sender:self];
                break;
            }
            case 1: {
                // Share Link
                [[[HXLightspeedManager manager] anIM] sendMessage:@""
                                                       customData:@{@"type": @"link",
                                                                    @"data": @"http://www.lightspeedmbs.com"}
                                                        toClients:[NSSet setWithObject:[self.friendInfo objectForKey:@"clientId"]]
                                                   needReceiveACK:YES];
                break;
            }
            case 2: {
                // Share Video
                [[[HXLightspeedManager manager] anIM] sendMessage:@""
                                                       customData:@{@"type": @"video",
                                                                    @"data": @"http://testking.omyapps.com.s3.amazonaws.com/demo01.MP4"}
                                                        toClients:[NSSet setWithObject:[self.friendInfo objectForKey:@"clientId"]]
                                                   needReceiveACK:YES];
                break;
            }
            case 3: {
                // Share Location
                [[[HXLightspeedManager manager] anIM] sendMessage:@""
                                                       customData:@{@"type": @"location",
                                                                    @"data": @"25.0335,121.564505"}
                                                        toClients:[NSSet setWithObject:[self.friendInfo objectForKey:@"clientId"]]
                                                   needReceiveACK:YES];
                break;
            }
            default:
                break;
        }
    } else {
        switch (buttonIndex) {
            case 0: {
                // Share Image
                [self performSegueWithIdentifier:@"imagePresentation" sender:self];
                break;
            }
            case 1: {
                // Share Link
                [[[HXLightspeedManager manager] anIM] sendMessage:@""
                                                       customData:@{@"type": @"link",
                                                                    @"data": @"http://www.lightspeedmbs.com"}
                                                        toTopicId:self.topicInfo[@"id"]
                                                   needReceiveACK:NO];
                break;
            }
            case 2: {
                // Share Video
                [[[HXLightspeedManager manager] anIM] sendMessage:@""
                                                       customData:@{@"type": @"video",
                                                                    @"data": @"http://testking.omyapps.com.s3.amazonaws.com/demo01.MP4"}
                                                        toTopicId:self.topicInfo[@"id"]
                                                   needReceiveACK:NO];
                break;
            }
            case 3: {
                // Share Location
                [[[HXLightspeedManager manager] anIM] sendMessage:@""
                                                       customData:@{@"type": @"location",
                                                                    @"data": @"25.0335,121.564505"}
                                                        toTopicId:self.topicInfo[@"id"]
                                                   needReceiveACK:NO];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - Method

- (void)getChatHistory
{
    [[[HXLightspeedManager manager] anIM] getHistory:[NSSet setWithObject:[self.friendInfo objectForKey:@"clientId"]]
                                            clientId:[HXLightspeedManager manager].clientId
                                               limit:30
                                           timestamp:0
                                             success:^(NSArray *messages) {
                                                 if (messages.count) {
                                                     self.messagesArray = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];
                                                     [self.tableView reloadData];
                                                 }
                                             }
                                             failure:^(ArrownockException *exception) {
                                                 
                                             }];
}

- (void)getTopicHistory
{
    [[[HXLightspeedManager manager] anIM] getTopicHistory:self.topicInfo[@"id"]
                                                 clientId:[HXLightspeedManager manager].clientId
                                                    limit:30
                                                timestamp:0
                                                  success:^(NSArray *messages) {
                                                      if (messages.count) {
                                                          self.messagesArray = [[[messages reverseObjectEnumerator] allObjects] mutableCopy];
                                                          [self.tableView reloadData];
                                                      }
                                                  } failure:^(ArrownockException *exception) {
                                                      
                                                  }];
}

- (NSString *)stringForCustomFileType:(NSString *)fileType
{
    if ([fileType isEqualToString:@"image"])
        return @"[Image]";
    else
        return fileType;
}

- (void)playerViewDidExitFullScreen {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerWillExitFullscreenNotification
                                                  object:self.moviePlayer];
    [self.moviePlayer stop];
    [self.moviePlayer.view removeFromSuperview];
    self.moviePlayer = nil;
}


@end
