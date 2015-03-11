//
//  ViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "LoginViewController.h"
#import "MainTabBarController.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Check if user is cached and linked to Facebook, if so, bypass login
    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        NSLog(@"already logged in through FB");
        [self presentHomeTabBarControllerAnimated:NO];
    } else if ([PFUser currentUser]) {
        NSLog(@"already logged in normally");
        [self presentHomeTabBarControllerAnimated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Login

- (IBAction)loginButtonPressed:(UIButton *)sender {
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            // Do stuff after successful login.
            NSLog(@"User logged in!");
            
            user[@"displayName"] = self.usernameTextField.text;
            [user save];
            
            [self login];
        } else {
            // The login failed. Check error to see why.
            NSString *errorMessage = nil;
            NSLog(@"Uh oh. An error occurred: %@", error);
            errorMessage = [error localizedDescription];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
    }];
}

- (IBAction)facebookLoginButtonPressed:(id)sender {
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"email", @"user_birthday", @"user_friends"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        [_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                            message:errorMessage
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss", nil];
            [alert show];
        } else {
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
            } else {
                NSLog(@"User with facebook logged in!");
            }
            
            //update user display name
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary *userData = (NSDictionary *)result;
                    NSString *fbUsername = userData[@"name"];
                    user[@"displayName"] = fbUsername;
                    [user save];
                }
            }];
            
            [self login];
        }
    }];
    
    [_activityIndicator startAnimating]; // Show loading indicator until login is finished
}


- (void)login {
    //TODO: clear them after testing
    self.usernameTextField.text = @"gavinc88";
    self.passwordTextField.text = @"test";
    
    //register user to PFInstallation
    PFInstallation *installation = [PFInstallation currentInstallation];
    if (installation.deviceToken) {
        installation[@"user"] = [PFUser currentUser];
        [installation saveInBackground];
    }
    
    //show Home page
    [self presentHomeTabBarControllerAnimated:YES];
}

- (void)presentHomeTabBarControllerAnimated:(BOOL)animated {
    MainTabBarController *mainTabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    [self.navigationController pushViewController:mainTabBarController animated:animated];
}

@end
