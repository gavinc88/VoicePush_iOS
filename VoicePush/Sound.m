//
//  Sound.m
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "Sound.h"

@implementation Sound

- (instancetype) initWithname:(NSString *)name
                  andFilename:(NSString *)filename {
    self = [super init];
    if(self){
        self.name = name;
        self.filename = filename;
    }
    return self;
}

- (void) toString{
    NSLog(@"Sound Object:\n\tname:%@\n\filename:%@\n",
          self.name, self.filename);
}

@end
