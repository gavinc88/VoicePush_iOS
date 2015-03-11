//
//  HomeTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "HomeTableViewController.h"
#import "SelectFriendsTableViewController.h"
#import "AddMessageViewController.h"
#import "SoundTableViewCell.h"
#import "Sound.h"
#import "SoundLibrary.h"

@interface HomeTableViewController ()

@property (nonatomic,strong) Sound *selectedSound;
@property NSInteger selectedIndex;

@end

@implementation HomeTableViewController

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
        cell.addMessageButton.hidden = NO;
        cell.sendButton.hidden = NO;
        
        cell.addMessageButton.tag = indexPath.row;
        cell.sendButton.tag = indexPath.row;
        [cell.addMessageButton addTarget:self action:@selector(addMessageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        cell.addMessageButton.hidden = YES;
        cell.sendButton.hidden = YES;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Button Click Handler

- (IBAction)addMessageButtonClicked:(UIButton *)sender {
    self.selectedSound = [self.mySounds objectAtIndex:sender.tag];
    if (self.selectedSound) {
        [self performSegueWithIdentifier:@"segueToAddMessage" sender:self];
    }
}

- (IBAction)sendButtonClicked:(UIButton *)sender {
    self.selectedSound = [self.mySounds objectAtIndex:sender.tag];
    if (self.selectedSound) {
        [self performSegueWithIdentifier:@"segueToSelectFriends" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segueToSelectFriends"]) {
        SelectFriendsTableViewController *dest = [segue destinationViewController];
        dest.mySound = self.selectedSound;
        dest.myMessage = nil;
    } else if ([segue.identifier isEqualToString:@"segueToAddMessage"]) {
        AddMessageViewController *dest = [segue destinationViewController];
        dest.mySound = self.selectedSound;
    }
}


@end
