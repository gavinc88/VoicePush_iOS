//
//  AddFriendsTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/12/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "AddFriendsTableViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>

@implementation AddFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchFBFriends];
}

- (void)fetchFBFriends {
    self.fbFriends = [[NSMutableArray alloc] init];
    NSLog(@"fetching friends with this app");
//    FBRequest *getFriends = [FBRequest requestForMyFriends];
//    [getFriends startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
//        NSArray *friends = result[@"data"];
//        NSLog(@"%@", result);
//        for (NSDictionary<FBGraphUser> *friend in friends) {
//            NSLog(@"Found a friend with this app: %@", friend.name);
//            [self.fbFriends addObject:friend];
//        }
//        
//        
//    }];
    
    FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture"];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        NSArray *data = [result objectForKey:@"data"];
        NSLog(@"%@", result);
        for (FBGraphObject<FBGraphUser> *friend in data) {
            [self.fbFriends addObject:friend];
        }
        
        [self.tableView reloadData];
    }];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fbFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"fbFriendidentifier" forIndexPath:indexPath];
    
    FBGraphObject *currentFacebookFriend = [self.fbFriends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [currentFacebookFriend objectForKey:@"name"];
    
    return cell;
}


@end
