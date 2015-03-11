//
//  SoundTableViewCell.h
//  VoicePush
//
//  Created by Gavin Chu on 3/11/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *soundName;
@property (strong, nonatomic) IBOutlet UIButton *addMessageButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@end
