//
//  Sound.h
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sound : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *filename;

- (instancetype) initWithname:(NSString *)name
                  andFilename:(NSString *)filename;

- (void) toString;

@end
