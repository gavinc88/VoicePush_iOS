//
//  SelectFriendsTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "SelectFriendsTableViewController.h"
#import <Parse/Parse.h>
#import "Constants.h"

@interface SelectFriendsTableViewController ()

@end

@implementation SelectFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeMyFriends];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeMyFriends {
    self.myFriends = [[NSMutableArray alloc] init];
    
    PFQuery *myFriendRelationsQuery = [PFQuery queryWithClassName:@"Friends"];
    [myFriendRelationsQuery whereKey:@"from" equalTo:[PFUser currentUser]];
    [myFriendRelationsQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if (!error) {
            NSMutableArray *myFriendRelations = [[NSMutableArray alloc] initWithCapacity:[results count]];
            for (PFObject *relation in results) {
                PFUser *toFriend = relation[@"to"];
                NSString *status = relation[@"status"];
                if ([status isEqualToString:ACCEPTED]) {
                    [myFriendRelations addObject:toFriend.objectId];
                }
            }
            NSLog(@"myFriendRelations: %@", myFriendRelations);
            
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"objectId" containedIn:myFriendRelations];
            [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    NSLog(@"Successfully retrieved %lu users.", (unsigned long)objects.count);
                    if (objects.count) {
                        for (PFUser *object in objects) {
                            if (![object.objectId isEqualToString:[PFUser currentUser].objectId]) {
                                [self.myFriends addObject:object];
                            }
                        }
                    }
                    
                    // Handle empty friend list
                    if ([self.myFriends count]) {
                        self.tableView.backgroundView = nil;
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                    } else {
                        // Display a message when the table is empty
                        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
                        
                        messageLabel.text = @"You have no friends yet. \nPlease go to the \"Friends\" tab on the home page to add friends";
                        messageLabel.textColor = [UIColor blackColor];
                        messageLabel.numberOfLines = 3;
                        messageLabel.textAlignment = NSTextAlignmentCenter;
                        messageLabel.font = [UIFont fontWithName:@"System" size:20];
                        [messageLabel sizeToFit];
                        
                        self.tableView.backgroundView = messageLabel;
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
                    }
                    
                    [self.tableView reloadData];
                } else {
                    NSLog(@"get friend users error: %@", error);
                }
            }];
        } else {
            NSLog(@"get friend relations error: %@", error);
        }
    }];
    
    self.selectedFriends = [[NSMutableArray alloc] init];
}

#pragma mark - Send Push

- (IBAction)sendPush:(UIBarButtonItem *)sender {
    
    // Build the actual push notification target query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey: @"user" containedIn: self.selectedFriends];
    
    NSString *message;
    if (self.myMessage) {
        message = [NSString stringWithFormat:@"%@: %@", [[PFUser currentUser] objectForKey:@"displayName"], self.myMessage];
    } else {
        message = [NSString stringWithFormat: @"New Message from %@", [[PFUser currentUser] objectForKey:@"displayName"]];
    }
    
    NSString *filePath = [NSString stringWithFormat:@"%@.%@", self.mySound.filename, self.mySound.fileType];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          message, @"alert",
                          filePath, @"sound",
                          nil];
    
    // Send the notification.
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:data];
    [push sendPushInBackground];
    
    
    NSMutableArray *historyObjects = [[NSMutableArray alloc] init];
    for (NSString *friend in self.selectedFriends) {
        // Save push notification in History class
        PFObject *history = [PFObject objectWithClassName:@"History"];
        history[@"from"] = [PFUser currentUser];
        history[@"fromDisplayName"] = [[PFUser currentUser] objectForKey:@"displayName"];
        history[@"to"] = friend;
        history[@"message"] = self.myMessage ? self.myMessage : @"";
        history[@"soundFilename"] = self.mySound.filename;
        history[@"soundFileType"] = self.mySound.fileType;
        [historyObjects addObject:history];
    }
    
    [PFObject saveAllInBackground:historyObjects];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.myFriends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"friendidentifier" forIndexPath:indexPath];
    
    PFUser *currentFriend = [self.myFriends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentFriend[@"displayName"];
    
    if([self.selectedFriends containsObject:[self.myFriends objectAtIndex:indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedFriends addObject:[self.myFriends objectAtIndex:indexPath.row]];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.selectedFriends removeObject:[self.myFriends objectAtIndex:indexPath.row]];
    }
    
    //toggle enable/disable send button
    if ([self.selectedFriends count]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
