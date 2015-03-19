//
//  AddMessageViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/11/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "AddMessageViewController.h"
#import "SelectFriendsTableViewController.h"

@implementation AddMessageViewController

int const MAX_MESSAGE_LENGTH = 52;

- (void)viewDidLoad {
    [super viewDidLoad];

    //self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.messageBox becomeFirstResponder];
    self.messageBox.delegate = self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the sound and message along
    if ([segue.identifier isEqualToString:@"segueToSelectFriends"]) {
        SelectFriendsTableViewController *dest = [segue destinationViewController];
        dest.mySound = self.mySound;
        dest.myMessage = self.messageBox.text;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    self.charactersLeftMessage.text = [NSString stringWithFormat:@"Characters left: %lu", MAX_MESSAGE_LENGTH - self.messageBox.text.length];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if(range.length + range.location > textView.text.length) {
        return NO;
    }
    
    // disable newline character and call next
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [text rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    if (location != NSNotFound) {
        [self performSegueWithIdentifier:@"segueToSelectFriends" sender:self];
        return NO;
    }
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    
    //NSLog(@"shouldChangeCharactersInRange %lu for %@",(unsigned long)newLength, text);
    return (newLength > MAX_MESSAGE_LENGTH) ? NO : YES;
}


@end
