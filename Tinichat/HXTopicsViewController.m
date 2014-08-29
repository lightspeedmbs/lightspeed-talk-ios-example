//
//  HXTopicsViewController.m
//  Tinichat
//
//  Created by Tim on 8/27/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import "HXTopicsViewController.h"
#import "HXLightspeedManager.h"
#import "HXChatViewController.h"

@interface HXTopicsViewController () <HXLightspeedManagerTopicDelegate, UIAlertViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *topicsArray;
@property (strong, nonatomic) UITextField * alertTextField;
@property (strong, nonatomic) NSMutableDictionary *topicTempInfo;
@end

@implementation HXTopicsViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.topicsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [HXLightspeedManager manager].topicDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getTopics];
}

#pragma mark - Helper

- (void)getTopics
{
    [[[HXLightspeedManager manager] anIM] getAllTopics];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HXChatViewController *CVC = (HXChatViewController *)segue.destinationViewController;
    CVC.hidesBottomBarWhenPushed = YES;
    CVC.isTopicMode = YES;
    if ([sender isKindOfClass:[UITableViewCell class]]) {
            int idx = [self.tableView indexPathForCell:sender].row;
            CVC.topicInfo = self.topicsArray[idx];
    } else {
        CVC.topicInfo = self.topicTempInfo;
    }
}

#pragma mark - HXLightspeed Topic Delegate

- (void)didGetTopicList:(NSArray *)topics
{
    self.topicsArray = [NSMutableArray arrayWithArray:topics];
    [self.tableView reloadData];
}

- (void)newTopicCreated:(NSString *)topicId
{
    [self getTopics];
    [self.topicTempInfo setObject:topicId forKey:@"id"];
    [self.topicTempInfo setObject:@[[HXLightspeedManager manager].clientId] forKey:@"parties"];
    [self.topicTempInfo setObject:@1 forKey:@"parties_count"];
    [self performSegueWithIdentifier:@"presentChatView" sender:self];
}

#pragma mark - Listener

- (IBAction)newTopicBarButtonListener:(UIBarButtonItem *)sender
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"New Topic Name"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.alertTextField = [alert textFieldAtIndex:0];
    [alert show];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && self.alertTextField.text.length) {
        [[[HXLightspeedManager manager] anIM] createTopic:self.alertTextField.text];
        self.topicTempInfo = [NSMutableDictionary dictionaryWithObject:self.alertTextField.text
                                                                   forKey:@"name"];
    }
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topicsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"topicsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *peopleCountLabel = (UILabel *)[cell viewWithTag:101];

    nameLabel.text = self.topicsArray[indexPath.row][@"name"];
    if ([self.topicsArray[indexPath.row][@"parties_count"] intValue] > 0)
        peopleCountLabel.text = [NSString stringWithFormat:@"%@ people", self.topicsArray[indexPath.row][@"parties_count"]];
    else
        peopleCountLabel.text = @"";
    
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


@end
