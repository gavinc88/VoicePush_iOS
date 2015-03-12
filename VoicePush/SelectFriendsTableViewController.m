//
//  SelectFriendsTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "SelectFriendsTableViewController.h"
#import <Parse/Parse.h>

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
    
    PFQuery *query = [PFUser query];
    //[query whereKey:@"username" equalTo:@"theUsernameString"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            NSLog(@"Successfully retrieved %lu users.", (unsigned long)objects.count);
            if (objects.count) {
                for (PFUser *object in objects) {
                    if (![object.objectId isEqualToString:[PFUser currentUser].objectId]) {
                        [self.myFriends addObject:object];
                    }
                }
            }
            [self.tableView reloadData];
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
