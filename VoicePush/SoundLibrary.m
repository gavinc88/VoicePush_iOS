//
//  SoundLibrary.m
//  VoicePush
//
//  Created by Gavin Chu on 3/11/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "SoundLibrary.h"

@implementation SoundLibrary

- (id)initWithAllSounds {
    self = [super init];
    if (self) {
        Sound *sound1 = [[Sound alloc] initWithname:@"Applause" andFilename:@"audience_applause.aiff"];
        Sound *sound2 = [[Sound alloc] initWithname:@"Evil Laugh" andFilename:@"evil_laugh.aiff"];
        Sound *sound3 = [[Sound alloc] initWithname:@"Happy Halloween" andFilename:@"happy_halloween.aiff"];
        Sound *sound4 = [[Sound alloc] initWithname:@"Hey Bitch!" andFilename:@"heybitch.caf"];
        Sound *sound5 = [[Sound alloc] initWithname:@"Leave now while you still can" andFilename:@"leave_now_while_you_still_can.aiff"];
        Sound *sound6 = [[Sound alloc] initWithname:@"Moaning" andFilename:@"moaning.aiff"];
        Sound *sound7 = [[Sound alloc] initWithname:@"MP5 SMG" andFilename:@"MP5_SMG.aiff"];
        Sound *sound8 = [[Sound alloc] initWithname:@"Test" andFilename:@"test2.caf"];
        Sound *sound9 = [[Sound alloc] initWithname:@"Where are you?" andFilename:@"whereareyou.caf"];
        
        self.soundLibrary = [[NSArray alloc]initWithObjects:sound1,sound2,sound3,sound4,sound5,sound6,sound7,sound8,sound9, nil];
    }
    return self;
}

@end
