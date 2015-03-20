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
    // This should only be called if came from the home page
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

- (IBAction)sendButtonClicked:(UIBarButtonItem *)sender {
    // Build the actual push notification target query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey: @"user" equalTo:self.myFriend];
    
    NSString *message;
    if (self.messageBox.text) {
        message = [NSString stringWithFormat:@"%@: %@", [[PFUser currentUser] objectForKey:@"displayName"], self.messageBox.text];
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
    
    // Save push notification in History class
    PFObject *history = [PFObject objectWithClassName:@"History"];
    history[@"from"] = [PFUser currentUser];
    history[@"fromDisplayName"] = [[PFUser currentUser] objectForKey:@"displayName"];
    history[@"to"] = self.myFriend;
    history[@"message"] = self.messageBox.text ? self.messageBox.text : @"";;
    history[@"soundFilename"] = self.mySound.filename;
    history[@"soundFileType"] = self.mySound.fileType;
    [history saveInBackground];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
