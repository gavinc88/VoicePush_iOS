//
//  AddFriendsTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/12/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "FindFriendsTableViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AddUserTableViewCell.h"
#import "Constants.h"

@implementation FindFriendsTableViewController

NSString * const PENDING_BUTTON = @"Pending";
NSString * const ADD_BUTTON = @"Add";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 50;
    [self fetchFBFriends];
}

- (void)fetchFBFriends {
    self.fbFriends = [[NSMutableArray alloc] init];
    NSLog(@"fetching friends with this app");
    
    FBRequest *getFriends = [FBRequest requestForMyFriends];
    [getFriends startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
        
        NSArray *friendObjects = [result objectForKey:@"data"];
        NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
        
        // Create a list of friends' Facebook IDs
        for (NSDictionary *friendObject in friendObjects) {
            // ignore those fb id already associated with you
            NSString *fbId = [friendObject objectForKey:@"id"];
            if (![self.ignoreList containsObject:fbId]) {
                [friendIds addObject:fbId];
            }
        }
        
        // Construct a PFUser query that will find friends whose facebook ids are contained in the current user's facebook friend list.
        PFQuery *getAllUsersQuery = [PFUser query];
        [getAllUsersQuery whereKey:@"fbId" containedIn:friendIds];
        
        // findObjects will return a list of PFUsers that are facebook friends with the current user
        NSArray *parseUsers = [getAllUsersQuery findObjects];
        //NSLog(@"parse users: %@", parseUsers);
        
        for (PFUser *parseUser in parseUsers) {
            [self.fbFriends addObject:parseUser];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"displayName beginswith[c] %@", searchText];
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
    
    //[parseUser[@"status"] isEqualToString:PENDING]
    
    PFUser *currentFacebookFriend = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        currentFacebookFriend = [self.searchResults objectAtIndex:indexPath.row];
    } else {
        currentFacebookFriend = [self.fbFriends objectAtIndex:indexPath.row];
    }
    
    cell.name.text = currentFacebookFriend[@"displayName"];
    cell.addButton.tag = indexPath.row;
    [cell.addButton addTarget:self action:@selector(addButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (IBAction)addButtonClicked:(UIButton *)sender {
    // Get the right PFUser
    PFUser *selectedFacebookFriend = nil;
    if (self.searchDisplayController.active) {
        NSLog(@"search is active");
        selectedFacebookFriend = [self.searchResults objectAtIndex:sender.tag];
    } else {
        selectedFacebookFriend = [self.fbFriends objectAtIndex:sender.tag];
    }
    NSLog(@"selected user: %@", selectedFacebookFriend[@"displayName"]);
    
    // Retrieve Friend relations
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"from" equalTo:[PFUser currentUser]];
    [query whereKey:@"to" equalTo:selectedFacebookFriend];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            NSLog(@"existing relation: %@", results);
            
            if ([results count]) {
                // Update existing friend relation
                PFObject *existingRelation = [results objectAtIndex:0];
                existingRelation[@"status"] = PENDING;
                [existingRelation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Add success");
                    } else {
                        NSLog(@"Add error: %@", error);
                    }
                }];
            } else {
                // Add friend relation
                PFObject *friendRelation = [PFObject objectWithClassName:@"Friends"];
                friendRelation[@"from"] = [PFUser currentUser];
                friendRelation[@"fromDisplayName"] = [PFUser currentUser][@"displayName"];
                friendRelation[@"fromFbId"] = [PFUser currentUser][@"fbId"];
                friendRelation[@"to"] = selectedFacebookFriend;
                friendRelation[@"toDisplayName"] = selectedFacebookFriend[@"displayName"];
                friendRelation[@"toFbId"] = selectedFacebookFriend[@"fbId"];
                friendRelation[@"status"] = PENDING;
                [friendRelation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Add success");
                    } else {
                        NSLog(@"Add error: %@", error);
                    }
                }];
            }
        } else {
            NSLog(@"retrieve Friends error: %@", error);
        }
    }];
}


@end
