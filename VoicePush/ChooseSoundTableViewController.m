//
//  ChooseSoundTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/19/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "ChooseSoundTableViewController.h"
#import "AddMessageViewController.h"
#import "SoundTableViewCell.h"
#import "SoundLibrary.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ChooseSoundTableViewController ()

@property (strong, nonatomic) NSMutableArray *mySounds;
@property (nonatomic,strong) Sound *selectedSound;
@property NSInteger selectedIndex;

@end

@implementation ChooseSoundTableViewController

SystemSoundID mySoundID; //used to play selected sound

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeMySounds];
    self.selectedIndex = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeMySounds {
    SoundLibrary *allsounds = [[SoundLibrary alloc]initWithAllSounds];
    self.mySounds = [[NSMutableArray alloc] initWithArray:allsounds.soundLibrary];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mySounds count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SoundTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"soundidentifier" forIndexPath:indexPath];
    
    Sound *currentSound = [self.mySounds objectAtIndex:indexPath.row];
    
    cell.soundName.text = currentSound.name;
    
    // toggle button visibility
    if (indexPath.row == self.selectedIndex) {
        cell.sendButton.hidden = NO;
        cell.previewButton.hidden = NO;
        
        cell.sendButton.tag = indexPath.row;
        cell.previewButton.tag = indexPath.row;
        [cell.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.previewButton addTarget:self action:@selector(previewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.sendButton.hidden = YES;
        cell.previewButton.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Dispose of the sound
    AudioServicesDisposeSystemSoundID(mySoundID);
    
    // close expanded cell reclicked
    if (self.selectedIndex == indexPath.row) {
        self.selectedIndex = -1;
    } else {
        self.selectedIndex = indexPath.row;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.selectedIndex) {
        return 88;
    }
    return 44;
}

#pragma mark - Button Click Handler

- (IBAction)sendButtonClicked:(UIButton *)sender {
    self.selectedSound = [self.mySounds objectAtIndex:sender.tag];
    if (self.selectedSound) {
        [self performSegueWithIdentifier:@"segueToAddMessage" sender:self];
    }
}

- (IBAction)previewButtonClicked:(UIButton *)sender {
    // Dispose of the sound
    AudioServicesDisposeSystemSoundID(mySoundID);
    
    // Create the sound ID
    Sound *currentSound = [self.mySounds objectAtIndex:sender.tag];
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:currentSound.filename ofType:currentSound.fileType];
    NSURL *pewPewURL = [NSURL fileURLWithPath:soundPath];
    
    // Play the sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &mySoundID);
    AudioServicesPlaySystemSound(mySoundID);
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Dispose of the sound
    AudioServicesDisposeSystemSoundID(mySoundID);
    
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segueToAddMessage"]) {
        AddMessageViewController *dest = [segue destinationViewController];
        dest.mySound = self.selectedSound;
        dest.myFriend = self.myFriend;
    }
}


@end