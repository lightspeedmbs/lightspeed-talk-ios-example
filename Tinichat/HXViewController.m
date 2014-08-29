//
//  HXViewController.m
//  Tinichat
//
//  Created by Tim on 8/25/14.
//  Copyright (c) 2014 Herxun. All rights reserved.
//

#import "HXViewController.h"
#import "HXLightspeedManager.h"

@interface HXViewController () <UITextFieldDelegate, HXLightspeedManagerSignInDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation HXViewController

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [HXLightspeedManager manager].signInDelegate = self;
    self.nameTextField.delegate = self;
    self.passwordTextField.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDeleagte

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - HXLightspeedManagerDelegate

- (void)lightspeedTalkSignedIn
{
    [self performSegueWithIdentifier:@"showTabBarController" sender:self];
}

#pragma mark - Listener

- (IBAction)logInButtonListener:(UIButton *)sender
{
    if (!(self.nameTextField.text.length && self.passwordTextField.text.length)) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Enter a user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.nameTextField.text forKey:@"username"];
    [params setObject:self.passwordTextField.text forKey:@"password"];
    
    [[[HXLightspeedManager manager] mrm] sendPostRequest:@"users/login"
                                                  params:params
                                                 success:^(int statusCode, NSDictionary *response) {
                                                     NSString *circleId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
                                                     [HXLightspeedManager manager].circleId = circleId;
                                                     NSLog(@"User login, circle id is: %@", circleId);
                                                     [HXLightspeedManager manager].username = self.nameTextField.text;
                                                     // Get Talk Client ID using Circle ID
                                                     [[[HXLightspeedManager manager] anIM] getClientId:circleId];
                                                 }
                                                 failure:^(int statusCode, NSDictionary *response) {
                                                     NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
                                                     
                                                     int errorCode = [[[response objectForKey:@"meta"] objectForKey:@"errorCode"] intValue];
                                                     if (errorCode == 10212) {
                                                         UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                                         message:@"Invalid user name or password!"
                                                                                                        delegate:nil
                                                                                               cancelButtonTitle:@"OK"
                                                                                               otherButtonTitles:nil, nil];
                                                         [alert show];
                                                     } else {
                                                         if ([response objectForKey:@"meta"]) {
                                                             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                                             message:[[response objectForKey:@"meta"] objectForKey:@"message"]
                                                                                                            delegate:nil
                                                                                                   cancelButtonTitle:@"OK"
                                                                                                   otherButtonTitles:nil, nil];
                                                             [alert show];
                                                         } else if ([response objectForKey:@"message"]) {
                                                             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                                             message:[response objectForKey:@"message"]
                                                                                                            delegate:nil
                                                                                                   cancelButtonTitle:@"OK"
                                                                                                   otherButtonTitles:nil, nil];
                                                             [alert show];
                                                         }
                                                     }
                                                 }];
}

- (IBAction)signUpButtonListener:(UIButton *)sender
{
    if (!(self.nameTextField.text.length && self.passwordTextField.text.length)) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Enter a user name and password!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // Let's create a new Lightspeed Circle User!
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.nameTextField.text forKey:@"username"];
    [params setObject:self.passwordTextField.text forKey:@"password"];
    
    MRM *mrm = [[HXLightspeedManager manager] mrm];
    
    [mrm sendPostRequest:@"users/create"
                  params:params
                 success:^(int statusCode, NSDictionary *response) {
                     NSString *circleId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
                     NSLog(@"User created, circle id is: %@", circleId);
                     [HXLightspeedManager manager].circleId = circleId;
                     [HXLightspeedManager manager].username = self.nameTextField.text;
                     [[[HXLightspeedManager manager] anIM] getClientId:circleId];
                 }
                 failure:^(int statusCode, NSDictionary *response) {
                     NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
                     
                     int errorCode = [[[response objectForKey:@"meta"] objectForKey:@"errorCode"] intValue];
                     if (errorCode == 10202) {
                         UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                                         message:@"User name already exist!"
                                                                        delegate:nil
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil, nil];
                         [alert show];
                     } else {
                         if ([response objectForKey:@"meta"]) {
                             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                                             message:[[response objectForKey:@"meta"] objectForKey:@"message"]
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil, nil];
                             [alert show];
                         } else if ([response objectForKey:@"message"]) {
                             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                                             message:[response objectForKey:@"message"]
                                                                            delegate:nil
                                                                   cancelButtonTitle:@"OK"
                                                                   otherButtonTitles:nil, nil];
                             [alert show];
                         }
                     }
                 }];
}

@end
