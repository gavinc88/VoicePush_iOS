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
@property (nonatomic, strong) NSString *fileType;

- (instancetype) initWithName:(NSString *)name
                     filename:(NSString *)filename
                         type:(NSString *)type;

- (void) toString;

@end
