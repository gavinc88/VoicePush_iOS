//
//  Friend.h
//  VoicePush
//
//  Created by Gavin Chu on 3/16/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Friend : NSObject

@property (nonatomic, strong) PFUser *parseUser;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *fbId;

- (instancetype) initWithPFUser:(PFUser *)user
                    displayName:(NSString *)name
                     facebookId:(NSString *)fbId;

@end
