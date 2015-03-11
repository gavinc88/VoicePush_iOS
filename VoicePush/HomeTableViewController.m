//
//  HomeTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/9/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "HomeTableViewController.h"
#import "SelectFriendsTableViewController.h"
#import "Sound.h"

@interface HomeTableViewController ()

@property (strong, nonatomic) Sound *selectedSound;

@end

@implementation HomeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeMySounds];
    self.selectedSound = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeMySounds {
    self.mySounds = [[NSMutableArray alloc] init];
    Sound *sound1 = [[Sound alloc] initWithname:@"Where are you?" andFilename:@"whereareyou.caf"];
    Sound *sound2 = [[Sound alloc] initWithname:@"Hey Bitch!" andFilename:@"heybitch.caf"];
    Sound *sound3 = [[Sound alloc] initWithname:@"test!" andFilename:@"test2.caf"];
    [self.mySounds addObject:sound1];
    [self.mySounds addObject:sound2];
    [self.mySounds addObject:sound3];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.mySounds count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"soundidentifier" forIndexPath:indexPath];
    
    Sound *currentSound = [self.mySounds objectAtIndex:indexPath.row];
    
    cell.textLabel.text = currentSound.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSound = [self.mySounds objectAtIndex:indexPath.row];
    if (self.selectedSound) {
        [self performSegueWithIdentifier:@"segueToSelectFriends" sender:self];
    }
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"segueToSelectFriends"]) {
        SelectFriendsTableViewController *dest = [segue destinationViewController];
        dest.mySound = self.selectedSound;
    }
}


@end
