//
//  FriendsTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "FriendsTableViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"
#import "Friend.h"
#import "MyRequestTableViewCell.h"
#import "FriendRequestTableViewCell.h"
#import "FindFriendsTableViewController.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

NSIndexPath *alertIndexPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self initializeMyFriends];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor blueColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(initializeMyFriends)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initializeMyFriends];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeMyFriends {
    self.myFriends = [[NSMutableArray alloc] init];
    self.myFriendRequests = [[NSMutableArray alloc] init];
    self.myPendingFriendRequestsFromOthers = [[NSMutableArray alloc] init];
    
    // Get your list of Friends
    PFQuery *getFriends = [PFQuery queryWithClassName:@"Friends"];
    [getFriends whereKey:@"from" equalTo:[PFUser currentUser]];
    
    PFQuery *getFriendRequests = [PFQuery queryWithClassName:@"Friends"];
    [getFriendRequests whereKey:@"to" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[getFriends,getFriendRequests]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu Friends relations", (unsigned long)results.count);
            if (results.count) {
                NSString *currentUserId = [[PFUser currentUser] objectId];
                
                for (PFObject *relation in results) {
                    //NSLog(@"relation: %@", relation);
                    
                    PFUser *fromUser = relation[@"from"];
                    NSString *fromId = [fromUser objectId];
                    NSString *fromDisplayName = relation[@"fromDisplayName"];
                    NSString *fromFbId = relation[@"fromFbId"];
                    PFUser *toUser = relation[@"to"];
                    NSString *toId = [toUser objectId];
                    NSString *toDisplayName = relation[@"toDisplayName"];
                    NSString *toFbId = relation[@"toFbId"];
                    NSLog(@"from %@   to %@  with status %@ ",fromDisplayName,toDisplayName,relation[@"status"]);
                    
                    if ([fromId isEqualToString:currentUserId]) {
                        if ([relation[@"status"] isEqualToString:PENDING]) {
                            Friend *myFriend = [[Friend alloc] initWithPFUser:toUser displayName:toDisplayName facebookId:toFbId];
                            [self.myFriendRequests addObject:myFriend];
                        } else if ([relation[@"status"] isEqualToString:ACCEPTED]) {
                            Friend *myFriend = [[Friend alloc] initWithPFUser:toUser displayName:toDisplayName facebookId:toFbId];
                            [self.myFriends addObject:myFriend];
                        }
                    } else if ([toId isEqualToString:currentUserId]) {
                        if ([relation[@"status"] isEqualToString:PENDING]) {
                            Friend *myFriend = [[Friend alloc] initWithPFUser:fromUser displayName:fromDisplayName facebookId:fromFbId];
                            [self.myPendingFriendRequestsFromOthers addObject:myFriend];
                        }                        
                    }
                }
            } else {
                NSLog(@"no result");
            }
            
            [self sortFriends];
            [self.tableView reloadData];
        } else {
            NSLog(@"error: %@", error);
        }
        
        [self.refreshControl endRefreshing];
    }];
}

- (void)sortFriends{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    //sort alphabetically
    NSArray *sortedArray;
    sortedArray = [self.myFriends sortedArrayUsingDescriptors:sortDescriptors];
    [self.myFriends removeAllObjects];
    [self.myFriends addObjectsFromArray:sortedArray];
    
    sortedArray = [self.myFriendRequests sortedArrayUsingDescriptors:sortDescriptors];
    [self.myFriendRequests removeAllObjects];
    [self.myFriendRequests addObjectsFromArray:sortedArray];
    
    sortedArray = [self.myPendingFriendRequestsFromOthers sortedArrayUsingDescriptors:sortDescriptors];
    [self.myPendingFriendRequestsFromOthers removeAllObjects];
    [self.myPendingFriendRequestsFromOthers addObjectsFromArray:sortedArray];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.myPendingFriendRequestsFromOthers count];
    } else if (section == 1) {
        return [self.myFriendRequests count];
    } else if (section == 2) {
        return [self.myFriends count];
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && [self.myPendingFriendRequestsFromOthers count]) {
        return @"Friend Requests";
    } else if (section == 1 && [self.myFriendRequests count]) {
        return @"Waiting for Response";
    } else if (section == 2) {
        return @"My Friends";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Friend *currentFriend = nil;
    if (indexPath.section == 0) {
        currentFriend = [self.myPendingFriendRequestsFromOthers objectAtIndex:indexPath.row];
        
        FriendRequestTableViewCell *cell = (FriendRequestTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"friendrequestidentifier" ];
        if (cell == nil) {
            cell = [[FriendRequestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendrequestidentifier" ];
        }
        cell.name.text = currentFriend.displayName;
        cell.acceptButton.tag = indexPath.row;
        [cell.acceptButton addTarget:self action:@selector(acceptButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.rejectButton.tag = indexPath.row;
        [cell.rejectButton addTarget:self action:@selector(rejectButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    } else if (indexPath.section == 1) {
        currentFriend = [self.myFriendRequests objectAtIndex:indexPath.row];
        
        MyRequestTableViewCell *cell = (MyRequestTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"myrequestidentifier" ];
        if (cell == nil) {
            cell = [[MyRequestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myrequestidentifier" ];
        }
        cell.name.text = currentFriend.displayName;
        return cell;
    } else if (indexPath.section == 2) {
        currentFriend = [self.myFriends objectAtIndex:indexPath.row];
        
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendidentifier" forIndexPath:indexPath];
        cell.textLabel.text = currentFriend.displayName;
        return cell;
    }
    return nil;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        alertIndexPath = indexPath;
        if (indexPath.section == 1) {
            Friend *editedFriend = [self.myFriendRequests objectAtIndex:indexPath.row];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deleting Friend Request" message:[NSString stringWithFormat:@"Are you sure you want to delete your friend request to %@?", editedFriend.displayName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alert show];
        } else if (indexPath.section == 2) {
            Friend *editedFriend = [self.myFriends objectAtIndex:indexPath.row];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Removing Friend" message:[NSString stringWithFormat:@"Are you sure you want to remove %@ from your friend list?", editedFriend.displayName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
            [alert show];
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.tableView setEditing:NO animated:YES];
    } else if (buttonIndex == 1) {
        if (alertIndexPath.section == 1) {
            Friend *myFriendRequest = [self.myFriendRequests objectAtIndex:alertIndexPath.row];
            PFUser *myFriendRequestUser = myFriendRequest.parseUser;
            [self removeFriendRequest:myFriendRequestUser];
            [self.myFriendRequests removeObjectAtIndex:alertIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[alertIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if (alertIndexPath.section == 2) {
            Friend *myFriend = [self.myFriends objectAtIndex:alertIndexPath.row];
            PFUser *myFriendUser = myFriend.parseUser;
            [self removeFriend:myFriendUser];
            [self.myFriends removeObjectAtIndex:alertIndexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[alertIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

#pragma mark - Button Actions

- (IBAction)acceptButtonClicked:(UIButton *)sender {
    NSLog(@"accept clicked");
    Friend *requestedFriendObject = [self.myPendingFriendRequestsFromOthers objectAtIndex:sender.tag];
    PFUser *requestedFriend = requestedFriendObject.parseUser;
    NSString *requestedFriendDisplayName = requestedFriendObject.displayName;
    NSString *requestedFriendFbId = requestedFriendObject.fbId;
    
    // Retrieve Friend relations
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"from" equalTo:requestedFriend];
    [query whereKey:@"to" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            NSLog(@"existing relation: %@", results);
            
            if ([results count]) {
                // Update existing friend relation status
                PFObject *existingRelation = [results objectAtIndex:0];
                existingRelation[@"status"] = ACCEPTED;
                [existingRelation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Add success");
                    } else {
                        NSLog(@"Add error: %@", error);
                    }
                }];
            }
        }
    }];
    
    // Retrieve reverse Friend relations
    PFQuery *reverseQuery = [PFQuery queryWithClassName:@"Friends"];
    [reverseQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    [reverseQuery whereKey:@"to" equalTo:requestedFriend];
    [reverseQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            NSLog(@"existing relation: %@", results);
            
            if ([results count]) {
                // Update existing friend relation status
                PFObject *existingRelation = [results objectAtIndex:0];
                existingRelation[@"status"] = ACCEPTED;
                [existingRelation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Add success");
                        [self initializeMyFriends];
                    } else {
                        NSLog(@"Add error: %@", error);
                    }
                }];
            } else {
                // Add reverse friend relation with status = accepted if current relationship does not exists yet
                PFObject *reverseFriendRelation = [PFObject objectWithClassName:@"Friends"];
                reverseFriendRelation[@"from"] = [PFUser currentUser];
                reverseFriendRelation[@"fromDisplayName"] = [PFUser currentUser][@"displayName"];
                reverseFriendRelation[@"fromFbId"] = [PFUser currentUser][@"fbId"];
                reverseFriendRelation[@"to"] = requestedFriend;
                reverseFriendRelation[@"toDisplayName"] = requestedFriendDisplayName;
                reverseFriendRelation[@"toFbId"] = requestedFriendFbId;
                reverseFriendRelation[@"status"] = ACCEPTED;
                [reverseFriendRelation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Reverse Add success");
                        [self initializeMyFriends];
                    } else {
                        NSLog(@"Reverse Add error: %@", error);
                    }
                }];
            }
            
        } else {
            NSLog(@"Reverse query error: %@", error);
        }
    }];
}

- (IBAction)rejectButtonClicked:(UIButton *)sender {
    NSLog(@"reject clicked");
    Friend *requestedFriendObject = [self.myPendingFriendRequestsFromOthers objectAtIndex:sender.tag];
    PFUser *requestedFriend = requestedFriendObject.parseUser;
    
    /// Retrieve Friend relations
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"from" equalTo:requestedFriend];
    [query whereKey:@"to" equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            NSLog(@"existing relation: %@", results);
            
            if ([results count]) {
                // Update existing friend relation status
                PFObject *existingRelation = [results objectAtIndex:0];
                existingRelation[@"status"] = REJECTED;
                [existingRelation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"Add success");
                        [self initializeMyFriends];
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

- (void)removeFriendRequest:(PFUser *)friend {
    // Delete friend request
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"from" equalTo:[PFUser currentUser]];
    [query whereKey:@"to" equalTo:friend];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            if ([results count]) {
                PFObject *existingRelation = [results objectAtIndex:0];
                [existingRelation deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"delete success");
                    } else {
                        NSLog(@"delete error: %@", error);
                    }
                }];
            }
        } else {
            NSLog(@"remove friend request error: %@", error);
        }
    }];
}

- (void)removeFriend:(PFUser *)friend {
    //Delete Friend relationship from both direction
    
    PFQuery *fromYou = [PFQuery queryWithClassName:@"Friends"];
    [fromYou whereKey:@"from" equalTo:[PFUser currentUser]];
    [fromYou whereKey:@"to" equalTo:friend];
    
    PFQuery *toYou = [PFQuery queryWithClassName:@"Friends"];
    [toYou whereKey:@"from" equalTo:friend];
    [toYou whereKey:@"to" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[fromYou,toYou]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            if (results.count == 2) {
                NSLog(@"Successfully deleted 2 Friends relations");
                PFObject *friendRelation1 = [results objectAtIndex:0];
                PFObject *friendRelation2 = [results objectAtIndex:1];
                [PFObject deleteAllInBackground:@[friendRelation1, friendRelation2]];
            } else {
                NSLog(@"did not find relationship from both direction");
            }
        } else {
            NSLog(@"remove friend error: %@", error);
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToFindFriends"]) {
        FindFriendsTableViewController *dest = [segue destinationViewController];
        dest.ignoreList = [[NSMutableArray alloc]init];
        
        // Add all fbIds to ignore list
        for (Friend *myFriend in self.myFriends) {
            [dest.ignoreList addObject:myFriend.fbId];
        }
        for (Friend *myFriend in self.myFriendRequests) {
            [dest.ignoreList addObject:myFriend.fbId];
        }
        for (Friend *myFriend in self.myPendingFriendRequestsFromOthers) {
            [dest.ignoreList addObject:myFriend.fbId];
        }
    }
}


@end
