//
//  FbUser.h
//  VoicePush
//
//  Created by Gavin Chu on 3/13/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBUser : NSObject

@property (strong, nonatomic) NSString *fbId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *url;

- (instancetype) initWithId:(NSString *)fbId
                       name:(NSString *)name
                        url:(NSString *)url;

@end
