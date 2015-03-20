//
//  HistoryTableViewController.m
//  VoicePush
//
//  Created by Gavin Chu on 3/18/15.
//  Copyright (c) 2015 Gavin Chu. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "HistoryTableViewCell.h"
#import "SoundLibrary.h"
#import <AudioToolbox/AudioToolbox.h>

@interface HistoryTableViewController ()

@property NSInteger selectedIndex;

@end

@implementation HistoryTableViewController

SystemSoundID mySoundID; //used to play selected sound

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithClassName:@"History"];
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This table displays items in the History class
        self.parseClassName = @"History";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedIndex = -1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}


// Override to customize what kind of query to perform on the class. The default is to query for all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    [query whereKey:@"to" equalTo:[PFUser currentUser]];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}


#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *cellIdentifier = @"historyidentifier";
    
    HistoryTableViewCell *cell = (HistoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[HistoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Configure the cell
    cell.name.text = [object objectForKey:@"fromDisplayName"];
    
    NSDate *date = object.createdAt;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *relativeDateString = [self relativeDateStringForDate:date];
    NSString *dateString;
    if ([relativeDateString isEqualToString:@"date"]) {
        [df setDateFormat:@"MM/dd/yy"];
        dateString = [df stringFromDate:date];
    } else if ([relativeDateString isEqualToString:@"time"]) {
        [df setDateFormat:@"hh:mm a"];
        dateString = [df stringFromDate:date];
    } else {
        dateString = relativeDateString;
    }
    cell.date.text = dateString;
    
    cell.message.text = [object objectForKey:@"message"];
    
    // toggle button visibility
    if (indexPath.row == self.selectedIndex) {
        // show buttons
        cell.replayButton.hidden = NO;
        cell.replyButton.hidden = NO;
        
        cell.replayButton.tag = indexPath.row;
        cell.replyButton.tag = indexPath.row;
        [cell.replayButton addTarget:self action:@selector(replayButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.replyButton addTarget:self action:@selector(replyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.buttonHeightConstraint.constant = 30;
        cell.buttonBottomMarginConstraint.constant = 10;
    } else {
        // hide buttons
        cell.replayButton.hidden = YES;
        cell.replyButton.hidden = YES;
        cell.buttonHeightConstraint.constant = 0;
        cell.buttonBottomMarginConstraint.constant = 0;
    }
    
    return cell;
}

// return "date" if format desired is date
// return "time" if format desired is time
// else return # of days ago
- (NSString *)relativeDateStringForDate:(NSDate *)date {
    NSCalendarUnit units = NSDayCalendarUnit | NSWeekOfYearCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    
    // if `date` is before "now" (i.e. in the past) then the components will be positive
    NSDateComponents *components = [[NSCalendar currentCalendar] components:units fromDate:date toDate:[NSDate date] options:0];
    if (components.year > 0) {
        return @"date";
    } else if (components.month > 0) {
        return @"date";
    } else if (components.weekOfYear > 0) {
        return @"date";
    } else if (components.day > 0) {
        if (components.day > 1) {
            return [NSString stringWithFormat:@"%ld days ago", (long)components.day];
        } else {
            return @"Yesterday";
        }
    } else {
        return @"time";
    }
}

/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [self.objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - UITableViewDataSource

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
 // Delete the object from Parse and reload the table view
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, and save it to Parse
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
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

#pragma mark - Actions

- (IBAction)replyButtonClicked:(UIButton *)sender {
//    self.selectedSound = [self.mySounds objectAtIndex:sender.tag];
//    if (self.selectedSound) {
//        [self performSegueWithIdentifier:@"segueToSelectFriends" sender:self];
//    }
}

- (IBAction)replayButtonClicked:(UIButton *)sender {
    // Dispose of the sound
    AudioServicesDisposeSystemSoundID(mySoundID);
    
    // Create the sound ID
    PFObject *notificationObject = [self.objects objectAtIndex:sender.tag];
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:notificationObject[@"soundFilename"] ofType:notificationObject[@"soundFileType"]];
    NSURL *pewPewURL = [NSURL fileURLWithPath:soundPath];
    
    // Play the sound
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)pewPewURL, &mySoundID);
    AudioServicesPlaySystemSound(mySoundID);
}

@end
