//
//  MainTabBarController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/10/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "MainTabBarController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
}

- (void)logout {
    [PFUser logOut]; // Log out
    
    // Return to Login view controller
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //unregister user from PFInstallation
    PFInstallation *installation = [PFInstallation currentInstallation];
    if (installation.deviceToken) {
        [installation removeObjectForKey:@"user"];
        [installation saveInBackground];
    }
}

@end
