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
    
    [[HXLightspeedManager manager]sendRequest:@"users/auth.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        
        NSLog(@"success log: %@",[response description]);
        NSString *userId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
        NSString *clientId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"clientId"];
        NSLog(@"User created, user id is: %@", userId);
        NSLog(@"User client id is: %@", clientId);
        [HXLightspeedManager manager].userId = userId;
        [HXLightspeedManager manager].username = self.nameTextField.text;
        [HXLightspeedManager manager].clientId = clientId;
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [self lightspeedTalkSignedIn];
        });
        
        
    }failure:^(NSDictionary* response){
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
        
        if ([response objectForKey:@"meta"]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[[response objectForKey:@"meta"] objectForKey:@"message"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
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
    
    // Let's create a new Lightspeed anSocial User!
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:self.nameTextField.text forKey:@"username"];
    [params setObject:self.passwordTextField.text forKey:@"password"];
    [params setObject:self.passwordTextField.text forKey:@"password_confirmation"];
    
    // get talk client ID
    [params setObject:@"true" forKey:@"enable_im"];
    
    //get talk client ID without anSocial
    //[[[HXLightspeedManager manager] anIM] getClientId:@"unique_symbol"];
    
    [[HXLightspeedManager manager]sendRequest:@"users/create.json" method:AnSocialManagerPOST params:params success:^(NSDictionary* response){
        
        NSLog(@"success log: %@",[response description]);
        NSString *userId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"id"];
        NSString *clientId = [[[response objectForKey:@"response"] objectForKey:@"user"] objectForKey:@"clientId"];
        NSLog(@"User created, user id is: %@", userId);
        NSLog(@"User client id is: %@", clientId);
        
        [HXLightspeedManager manager].userId = userId;
        [HXLightspeedManager manager].username = self.nameTextField.text;
        [HXLightspeedManager manager].clientId = clientId;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self lightspeedTalkSignedIn];
        });
        
    }failure:^(NSDictionary* response){
        NSLog(@"Error: %@", [[response objectForKey:@"meta"] objectForKey:@"message"]);
    
        if ([response objectForKey:@"meta"]) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:[[response objectForKey:@"meta"] objectForKey:@"message"]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert show];
            });
        }
        
    }];

    
    
}

@end
