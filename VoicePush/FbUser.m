//
//  FbUser.m
//  VoicePush
//
//  Created by Gavin Chu on 3/13/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "FBUser.h"

@implementation FBUser

- (instancetype) initWithId:(NSString *)fbId
                       name:(NSString *)name
                        url:(NSString *)url {
    self = [super init];
    if(self){
        self.fbId = fbId;
        self.name = name;
        self.url = url;
    }
    return self;
}

@end
