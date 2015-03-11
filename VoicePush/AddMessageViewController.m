//
//  AddMessageViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/11/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "AddMessageViewController.h"
#import "SelectFriendsTableViewController.h"

@implementation AddMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.messageBox becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the sound along
    if ([segue.identifier isEqualToString:@"segueToSelectFriends"]) {
        SelectFriendsTableViewController *dest = [segue destinationViewController];
        dest.mySound = self.mySound;
        dest.myMessage = self.messageBox.text;
    }
}

@end
