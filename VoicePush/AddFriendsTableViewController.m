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
#import "AddUserTableViewCell.h"

@implementation AddFriendsTableViewController

NSString * const PENDING = @"pending";
NSString * const ACCEPTED = @"accepted";
NSString * const REJECTED = @"rejected";

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
    
//    FBRequest *friendRequest = [FBRequest requestForGraphPath:@"me/friends?fields=name,picture{url}"];
//    [friendRequest startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//        
//        if (!error) {
//            NSArray *data = [result objectForKey:@"data"];
//            //NSLog(@"%@", result);
//            for (FBGraphObject<FBGraphUser> *friend in data) {
//                // Get FB User info
//                NSString *fbId = friend.objectID;
//                NSString *name = friend.name;
//                NSString *url = [[[friend objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
//                
//                User *fbUser = [[User alloc] initWithId:fbId name:name url:url];
//                [self.fbFriends addObject:fbUser];
//            }
//            
//            [self.tableView reloadData];
//        }
//        
//    }];
    
    // Issue a Facebook Graph API request to get your user's friend list
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result will contain an array with your user's friends in the "data" key
            NSArray *friendObjects = [result objectForKey:@"data"];
            NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
            // Create a list of friends' Facebook IDs
            for (NSDictionary *friendObject in friendObjects) {
                [friendIds addObject:[friendObject objectForKey:@"id"]];
            }
            
            // Construct a PFUser query that will find friends whose facebook ids are contained in the current user's friend list.
            PFQuery *getAllUsersQuery = [PFUser query];
            [getAllUsersQuery whereKey:@"fbId" containedIn:friendIds];
            
            // findObjects will return a list of PFUsers that are facebook friends with the current user
            NSArray *parseUsers = [getAllUsersQuery findObjects];
            NSLog(@"parse users: %@", parseUsers);
            
            // Get your list of Friends
            PFQuery *getExistingFriends = [PFQuery queryWithClassName:@"Friends"];
            [getExistingFriends whereKey:@"from" equalTo:[PFUser currentUser]];
            NSArray* existingFriends = [getExistingFriends findObjects];
            NSLog(@"friends: %@", existingFriends);
            
            // Get "toFbIds" from Friends table
            NSMutableArray *toFbIds = [[NSMutableArray alloc] init];
            for (PFObject *friend in existingFriends) {
                NSString *toFbId = friend[@"toFbId"];
                [toFbIds addObject:toFbId];
                NSLog(@"%@", toFbId);
            }
            NSLog(@"friends toFbIds: %@", toFbIds);
            
            for (PFUser *parseUser in parseUsers) {
                
                BOOL foundExistingFriend = NO;
                for (PFObject *existingFriend in existingFriends) {
                    if ([parseUser[@"fbId"] isEqualToString:existingFriend[@"toFbId"]]) {
                        NSLog(@"found existing friend: %@", parseUser[@"displayName"]);
                        
                        NSString *status = existingFriend[@"status"];
                        NSLog(@"status: %@", status);
                        if ([status isEqualToString:REJECTED]) {
                            // if friend relation exists and status is rejected, facebook friend should reappear
                            [self.fbFriends addObject:parseUser];
                        }
                        foundExistingFriend = YES;
                        break;
                    }
                }
                
                if (!foundExistingFriend) {
                    //if friend relation doesn't exist, then this user is for sure not your friend yet
                    [self.fbFriends addObject:parseUser];
                }
                
//                NSString *status = parseUser[@"status"];
//                NSLog(@"status: %@", status);
//                if ([toFbIds containsObject:parseUser[@"toFbId"]] && status && [status isEqualToString:REJECTED]) {
//                    // if friend relation exists and status is rejected, facebook friend should reappear
//                    [self.fbFriends addObject:parseUser];
//                } else if (![toFbIds containsObject:parseUser[@"toFbId"]]) {
//                    // or if friend relation doesn't exist, then this user is for sure not your friend yet
//                    [self.fbFriends addObject:parseUser];
//                } else {
//                    NSLog(@"%@ is already your friend", parseUser[@"toFbId"]);
//                }
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"error: %@", error);
        }
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
                friendRelation[@"to"] = selectedFacebookFriend;
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
