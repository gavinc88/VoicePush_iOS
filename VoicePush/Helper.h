//
//  Helper.h
//  VoicePush
//
//  Created by Gavin Chu on 3/10/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface Helper : NSObject

//Used to get username from normal user or FB user
+(void)getUsernameForUser: (PFUser *)user WithCompletionBlock:(void(^)(NSString *username))handler;

@end
