//
//  SoundLibrary.h
//  VoicePush
//
//  Created by Gavin Chu on 3/11/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sound.h"

@interface SoundLibrary : NSObject

@property (strong) NSDictionary *soundLibrary;

+ (Sound *)getSoundWithKey:(NSString *)key andNumber:(int)number;

@end
