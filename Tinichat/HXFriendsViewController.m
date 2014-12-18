//
//  HXFriendsViewController.m
//  Tinichat
//
//  Created by Tim on 8/25/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import "HXFriendsViewController.h"
#import "HXLightspeedManager.h"
#import "HXChatViewController.h"

@interface HXFriendsViewController () <HXLightspeedManagerTalkDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *friendsArray;
@property (strong, nonatomic) NSMutableSet *unreadMessagesSet;
@property (strong, nonatomic) NSString *friendChatting;
@property (strong, nonatomic) NSMutableDictionary *clientStatus;

@end

@implementation HXFriendsViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.friendsArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.unreadMessagesSet = [[NSMutableSet alloc] initWithCapacity:0];
    [[[HXLightspeedManager manager] anIM] connect:[HXLightspeedManager manager].clientId];
    [HXLightspeedManager manager].talkDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveMessageNotification:)
                                                 name:@"co.herxun.Tinichat.didReceiveMessage"
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    // For the demo friends list is only refreshed during viewWillAppear,
    // but for your app you should update the list much more often
    [self loadCircleUser];
    [HXLightspeedManager manager].talkDelegate = self;
    self.friendChatting = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.friendsArray[self.tableView.indexPathForSelectedRow.row][@"clientId"])
    {
        return YES;
    }
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HXChatViewController *CVC = [segue destinationViewController];
    CVC.hidesBottomBarWhenPushed = YES;
    CVC.friendInfo = self.friendsArray[self.tableView.indexPathForSelectedRow.row];
    self.friendChatting = [self.friendsArray[self.tableView.indexPathForSelectedRow.row] objectForKey:@"clientId"];
}

#pragma mark - Helper

- (void)loadCircleUser
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:@99 forKey:@"limit"];
    
    [[HXLightspeedManager manager]sendRequest:@"users/search.json" method:AnSocialManagerGET params:params success:^(NSDictionary* response){
        
        NSLog(@"success log: %@",[response description]);
        NSLog(@"Recieved a list of circle users");
        self.friendsArray =  [[NSArray arrayWithArray:[[response objectForKey:@"response"] objectForKey:@"users"]] mutableCopy];
        [[HXLightspeedManager manager] saveFriendsIds:self.friendsArray];
        
        // Remove logged-in user from the friends list, also store all the clientIds of friends and query for their online status
        NSMutableSet *userSet = [[NSMutableSet alloc] initWithCapacity:0];
        __block NSUInteger _idx = -1;
        [self.friendsArray enumerateObjectsUsingBlock:^(NSDictionary *friend, NSUInteger idx, BOOL *stop) {
            if ([[friend objectForKey:@"id"] isEqualToString:[[HXLightspeedManager manager] userId]]) {
                _idx = idx;
            } else {
                if (friend[@"clientId"])
                    [userSet addObject:[friend objectForKey:@"clientId"]];
            }
        }];
        if (_idx != -1)
            [self.friendsArray removeObjectAtIndex:_idx];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadCircleUserStatus:userSet];
            [self.tableView reloadData];
        });
        
    }failure:^(NSDictionary* response){
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        
    }];

}

- (void)loadCircleUserStatus:(NSSet *)userSet
{
    [[[HXLightspeedManager manager] anIM] getClientsStatus:userSet];
}

#pragma mark - Listener

- (IBAction)logOutBarButtonListener:(UIBarButtonItem *)sender
{
    [[HXLightspeedManager manager] logOut];
    [self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friendsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"friendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *newMessageLabel = (UILabel *)[cell viewWithTag:101];
    UILabel *statusMessageLabel = (UILabel *)[cell viewWithTag:102];
    
    nameLabel.text = [self.friendsArray[indexPath.row] objectForKey:@"username"];
    newMessageLabel.text = @"";
    if ([self.unreadMessagesSet containsObject:[self.friendsArray[indexPath.row] objectForKey:@"clientId"]])
        newMessageLabel.text = @"New!";
    NSString *status = [self.clientStatus objectForKey:[self.friendsArray[indexPath.row] objectForKey:@"clientId"]];
    if (status) {
        if ([status isEqualToString:@"NO"]) {
            statusMessageLabel.text = @"Offline";
            statusMessageLabel.textColor = [UIColor lightGrayColor];
        } else {
            statusMessageLabel.text = @"Online";
            statusMessageLabel.textColor = [UIColor blackColor];
        }
    }
    else
        statusMessageLabel.text = @"";
    
    return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *newMessageLabel = (UILabel *)[[tableView cellForRowAtIndexPath:indexPath] viewWithTag:101];
    if (newMessageLabel.text.length) {
        newMessageLabel.text = @"";
        NSString *selectedId = [self.friendsArray[indexPath.row] objectForKey:@"clientId"];
        [self.unreadMessagesSet removeObject:selectedId];
    }
}

#pragma mark - HXLightspeedManager Delegate

- (void)didGetClientStatus:(NSDictionary *)clientStatus
{
    self.clientStatus = [NSMutableDictionary dictionaryWithDictionary:clientStatus];
    [self.tableView reloadData];
}

#pragma mark - HXLightspeedManager Notification

- (void)didReceiveMessageNotification:(NSNotification*)notification
{
    NSDictionary *notificaitonObject = (NSDictionary *)(notification.object);
    if (![[notificaitonObject objectForKey:@"from"] isEqualToString:self.friendChatting]) {
        [self.unreadMessagesSet addObject:[notificaitonObject objectForKey:@"from"]];
        NSLog(@"From: %@", [notificaitonObject objectForKey:@"from"]);
        [self.tableView reloadData];
    }
}


@end
