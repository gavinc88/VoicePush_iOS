//
//  AddUserTableViewCell.h
//  VoicePush
//
//  Created by Gavin Chu on 3/13/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddUserTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UIButton *addButton;

@end
