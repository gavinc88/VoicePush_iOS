//
//  AddMessageViewController.h
//  VoicePush
//
//  Created by Gavin Chu on 3/11/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sound.h"
#import <Parse/Parse.h>

@interface AddMessageViewController : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) Sound *mySound;
@property (strong, nonatomic) PFUser *myFriend;

@property (strong, nonatomic) IBOutlet UITextView *messageBox;
@property (strong, nonatomic) IBOutlet UILabel *charactersLeftMessage;

@end
