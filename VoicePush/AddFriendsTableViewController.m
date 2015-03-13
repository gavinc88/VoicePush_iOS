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
#import "FBUser.h"
#import "AddUserTableViewCell.h"

@implementation AddFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 50;
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
    
    FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture{url}"];
    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        
        if (!error) {
            NSArray *data = [result objectForKey:@"data"];
            NSLog(@"%@", result);
            for (FBGraphObject<FBGraphUser> *friend in data) {
                // Get FB User info
                NSString *fbId = friend.objectID;
                NSString *name = friend.name;
                NSString *url = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
                
                FBUser *fbUser = [[FBUser alloc] initWithId:fbId name:name url:url];
                [self.fbFriends addObject:fbUser];
            }
            
            [self.tableView reloadData];
        }
        
    }];
    
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name beginswith[c] %@", searchText];
    self.searchResults = [self.fbFriends filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:[[controller.searchBar scopeButtonTitles] objectAtIndex:[controller.searchBar selectedScopeButtonIndex]]];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
    } else {
        return [self.fbFriends count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddUserTableViewCell *cell = (AddUserTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"fbFriendIdentifier" ];
    if (cell == nil) {
        cell = [[AddUserTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"fbFriendIdentifier" ];
    }
    
    FBUser *currentFacebookFriend = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        currentFacebookFriend = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        currentFacebookFriend = [self.fbFriends objectAtIndex:indexPath.row];
    }
    
    cell.name.text = currentFacebookFriend.name;
    
    return cell;
}


@end
