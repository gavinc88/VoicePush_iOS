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
        Sound *sound1 = [[Sound alloc] initWithName:@"Applause" filename:@"audience_applause" type:@"caf"];
        Sound *sound2 = [[Sound alloc] initWithName:@"Countdown" filename:@"countdown" type:@"caf"];
        Sound *sound3 = [[Sound alloc] initWithName:@"Do it again" filename:@"do_it_again" type:@"caf"];
        Sound *sound4 = [[Sound alloc] initWithName:@"Dramatic" filename:@"dramatic" type:@"caf"];
        Sound *sound5 = [[Sound alloc] initWithName:@"Evil laugh" filename:@"evil_laugh" type:@"caf"];
        Sound *sound6 = [[Sound alloc] initWithName:@"Hello" filename:@"hello" type:@"caf"];
        Sound *sound7 = [[Sound alloc] initWithName:@"Hello? Hello? ...Hello?" filename:@"hello_hello_hello" type:@"caf"];
        Sound *sound8 = [[Sound alloc] initWithName:@"Hey bitch!" filename:@"heybitch" type:@"caf"];
        Sound *sound9 = [[Sound alloc] initWithName:@"Leave now while you still can" filename:@"leave_now_while_you_still_can" type:@"caf"];
        Sound *sound10 = [[Sound alloc] initWithName:@"Moaning" filename:@"moaning" type:@"caf"];
        Sound *sound11 = [[Sound alloc] initWithName:@"Moon space blaster" filename:@"moon_space_blaster" type:@"caf"];
        Sound *sound12 = [[Sound alloc] initWithName:@"MP5 SMG" filename:@"MP5_SMG" type:@"caf"];
        Sound *sound13 = [[Sound alloc] initWithName:@"Oh yeah!" filename:@"oh_yeah" type:@"caf"];
        Sound *sound14 = [[Sound alloc] initWithName:@"Scream!" filename:@"psycho_scream" type:@"caf"];
        Sound *sound15 = [[Sound alloc] initWithName:@"Suddenly..." filename:@"suddenly" type:@"caf"];
        Sound *sound16 = [[Sound alloc] initWithName:@"Test Music" filename:@"test2" type:@"caf"];
        Sound *sound17 = [[Sound alloc] initWithName:@"Warning" filename:@"warning" type:@"caf"];
        Sound *sound18 = [[Sound alloc] initWithName:@"Where are you?" filename:@"where_are_you" type:@"caf"];
        Sound *sound19 = [[Sound alloc] initWithName:@"Whistle" filename:@"whistle" type:@"caf"];
        
        //self.soundLibrary = [[NSArray alloc]initWithObjects:sound1,sound2,sound3,sound4,sound5,sound6,sound7,sound8,sound9,sound10,sound11,sound12,sound13,sound14,sound15,sound16,sound17,sound18,sound19,nil];
        
        self.soundLibrary = [[NSArray alloc]initWithObjects:sound1,sound2,sound4,sound5,sound6,sound7,sound9,sound11,sound12,sound14,sound15,sound16,sound17,sound18,sound19,nil];
    }
    return self;
}

@end
