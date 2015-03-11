//
//  SelectFriendsTableViewController.h
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectFriendsTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableArray *myFriends;
@property (strong, nonatomic) NSMutableArray *selectedFriends;

@end
