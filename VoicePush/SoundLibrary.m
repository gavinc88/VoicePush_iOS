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
        Sound *sound1 = [[Sound alloc] initWithname:@"Applause" andFilename:@"audience_applause.caf"];
        Sound *sound2 = [[Sound alloc] initWithname:@"Countdown" andFilename:@"countdown.caf"];
        Sound *sound3 = [[Sound alloc] initWithname:@"Do it again" andFilename:@"do_it_again.caf"];
        Sound *sound4 = [[Sound alloc] initWithname:@"Dramatic" andFilename:@"dramatic.caf"];
        Sound *sound5 = [[Sound alloc] initWithname:@"Evil laugh" andFilename:@"evil_laugh.caf"];
        Sound *sound6 = [[Sound alloc] initWithname:@"Hello" andFilename:@"hello.caf"];
        Sound *sound7 = [[Sound alloc] initWithname:@"Hello? Hello? ...Hello?" andFilename:@"hello_hello_hello.caf"];
        Sound *sound8 = [[Sound alloc] initWithname:@"Hey bitch!" andFilename:@"heybitch.caf"];
        Sound *sound9 = [[Sound alloc] initWithname:@"Leave now while you still can" andFilename:@"leave_now_while_you_still_can.caf"];
        Sound *sound10 = [[Sound alloc] initWithname:@"Moaning" andFilename:@"moaning.caf"];
        Sound *sound11 = [[Sound alloc] initWithname:@"Moon space blaster" andFilename:@"moon_space_blaster.caf"];
        Sound *sound12 = [[Sound alloc] initWithname:@"MP5 SMG" andFilename:@"MP5_SMG.caf"];
        Sound *sound13 = [[Sound alloc] initWithname:@"Oh yeah!" andFilename:@"oh_yeah.caf"];
        Sound *sound14 = [[Sound alloc] initWithname:@"Scream!" andFilename:@"psycho_scream.caf"];
        Sound *sound15 = [[Sound alloc] initWithname:@"Suddenly..." andFilename:@"suddenly.caf"];
        Sound *sound16 = [[Sound alloc] initWithname:@"Test Music" andFilename:@"test2.caf"];
        Sound *sound17 = [[Sound alloc] initWithname:@"Warning" andFilename:@"warning.caf"];
        Sound *sound18 = [[Sound alloc] initWithname:@"Where are you?" andFilename:@"where_are_you.caf"];
        Sound *sound19 = [[Sound alloc] initWithname:@"Whistle" andFilename:@"whistle.caf"];
        
        self.soundLibrary = [[NSArray alloc]initWithObjects:sound1,sound2,sound3,sound4,sound5,sound6,sound7,sound8,sound9,sound10,sound11,sound12,sound13,sound14,sound15,sound16,sound17,sound18,sound19,nil];
    }
    return self;
}

@end
