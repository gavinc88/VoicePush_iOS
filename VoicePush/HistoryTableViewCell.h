//
//  HistoryTableViewCell.h
//  VoicePush
//
//  Created by Gavin Chu on 3/19/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *date;
@property (strong, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) IBOutlet UIButton *replayButton;
@property (strong, nonatomic) IBOutlet UIButton *replyButton;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonBottomMarginConstraint;

@end
