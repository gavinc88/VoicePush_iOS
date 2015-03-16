//
//  AddFriendsTableViewController.h
//  VoicePush
//
//  Created by Gavin Chu on 3/12/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindFriendsTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *fbFriends;
@property (nonatomic, strong) NSMutableArray *ignoreList;
@property (nonatomic, strong) NSArray *searchResults;

@end
