//
//  Friend.m
//  VoicePush
//
//  Created by Gavin Chu on 3/16/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "Friend.h"

@implementation Friend

- (instancetype) initWithPFUser:(PFUser *)user
                    displayName:(NSString *)name
                     facebookId:(NSString *)fbId {
    self = [super init];
    if(self){
        self.parseUser = user;
        self.displayName = name;
        self.fbId = fbId;
    }
    return self;
}

@end
