//
//  Helper.m
//  VoicePush
//
//  Created by Gavin Chu on 3/10/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "Helper.h"

@implementation Helper

+(void)getUsernameForUser: (PFUser *)user WithCompletionBlock:(void(^)(NSString *username))handler {
    // Send request to Facebook
    if([PFFacebookUtils isLinkedWithUser:user]){
        FBRequest *request = [FBRequest requestForMe];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // result is a dictionary with the user's Facebook data
                NSDictionary *userData = (NSDictionary *)result;
                NSString *name = userData[@"name"];
                NSLog(@"Facebook name: %@", name);
                handler(name);
            } else {
                NSLog(@"error getting name from facebook");
            }
        }];
    } else {
        handler(user.username);
    }
}

@end
