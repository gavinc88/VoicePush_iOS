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
#import "MyRequestTableViewCell.h"
#import "FriendRequestTableViewCell.h"
#import "FindFriendsTableViewController.h"

@interface FriendsTableViewController ()

@end

@implementation FriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeMyFriends];
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor blueColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(initializeMyFriends)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeMyFriends {
    self.myFriends = [[NSMutableArray alloc] init];
    self.myFriendRequests = [[NSMutableArray alloc] init];
    self.myPendingFriendRequests = [[NSMutableArray alloc] init];
    
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
                    NSLog(@"from %@   to %@  for user %@ ",fromDisplayName,toDisplayName,currentUserId);
                    
                    if ([fromId isEqualToString:currentUserId]) {
                        if ([relation[@"status"] isEqualToString:PENDING]) {
                            //NSLog(@"add toUser to pending: %@",@[toUser,toDisplayName]);
                            [self.myFriendRequests addObject:@[toUser,toDisplayName,toFbId]];
                        } else if ([relation[@"status"] isEqualToString:ACCEPTED]) {
                            //NSLog(@"add toUser to accepted: %@",@[toUser,toDisplayName]);
                            [self.myFriends addObject:@[toUser,toDisplayName,toFbId]];
                        }
                    } else if ([toId isEqualToString:currentUserId]) {
                        if ([relation[@"status"] isEqualToString:PENDING]) {
                            [self.myPendingFriendRequests addObject:@[fromUser,fromDisplayName,fromFbId]];
                        }                        
                    }
                }
            } else {
                NSLog(@"no result");
            }
            [self.tableView reloadData];
        } else {
            NSLog(@"error: %@", error);
        }
        
        [self.refreshControl endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.myPendingFriendRequests count];
    } else if (section == 1) {
        return [self.myFriendRequests count];
    } else if (section == 2) {
        return [self.myFriends count];
    }
    return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && [self.myPendingFriendRequests count]) {
        return @"Friend Requests";
    } else if (section == 1 && [self.myFriendRequests count]) {
        return @"Waiting for Response";
    } else if (section == 2) {
        return @"My Friends";
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *currentFriend = nil;
    if (indexPath.section == 0) {
        currentFriend = [self.myPendingFriendRequests objectAtIndex:indexPath.row];
        
        FriendRequestTableViewCell *cell = (FriendRequestTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"friendrequestidentifier" ];
        if (cell == nil) {
            cell = [[FriendRequestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"friendrequestidentifier" ];
        }
        cell.name.text = currentFriend[1];
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
        cell.name.text = currentFriend[1];
        return cell;
    } else if (indexPath.section == 2) {
        currentFriend = [self.myFriends objectAtIndex:indexPath.row];
        
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendidentifier" forIndexPath:indexPath];
        cell.textLabel.text = currentFriend[1];
        return cell;
    }
    return nil;
}

- (IBAction)acceptButtonClicked:(UIButton *)sender {
    NSLog(@"accept clicked");
    NSArray *requestedFriendArray = [self.myPendingFriendRequests objectAtIndex:sender.tag];
    PFUser *requestedFriend = requestedFriendArray[0];
    NSString *requestedFriendDisplayName = requestedFriendArray[1];
    NSString *requestedFriendFbId = requestedFriendArray[2];
    
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
                        
                        // Add reverse friend relation with status = accepted
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

                    } else {
                        NSLog(@"Add error: %@", error);
                    }
                }];
            }
        }
    }];
}

- (IBAction)rejectButtonClicked:(UIButton *)sender {
    NSLog(@"reject clicked");
    NSArray *requestedFriendArray = [self.myPendingFriendRequests objectAtIndex:sender.tag];
    PFUser *requestedFriend = requestedFriendArray[0];
    
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"segueToFindFriends"]) {
        FindFriendsTableViewController *dest = [segue destinationViewController];
        dest.ignoreList = [[NSMutableArray alloc]init];
        for (NSArray * myFriend in self.myFriends) {
            [dest.ignoreList addObject:myFriend[2]];
        }
        for (NSArray * myFriend in self.myFriendRequests) {
            [dest.ignoreList addObject:myFriend[2]];
        }
        for (NSArray * myFriend in self.myPendingFriendRequests) {
            [dest.ignoreList addObject:myFriend[2]];
        }
    }
}


@end
