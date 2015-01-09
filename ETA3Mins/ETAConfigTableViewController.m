//
//  ETAConfigTableViewController.m
//  ETA3Mins
//
//  Created by Bobie Chen on 1/9/15.
//  Copyright (c) 2015 bobiechen. All rights reserved.
//

#import "ETAConfigTableViewController.h"

@interface ETAConfigTableViewController ()

@property (nonatomic, weak) NSArray* defaultConfigArray;

@end

@implementation ETAConfigTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self _prepareConfigDataAndTable];
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Select Config";
    
    UIBarButtonItem* stopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(btnCancelClicked)];
    self.navigationItem.leftBarButtonItem = stopBarButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_prepareConfigDataAndTable {
    if (self.delegate && [self.delegate respondsToSelector:@selector(provideDefaultConfigs)]) {
        self.defaultConfigArray = [self.delegate provideDefaultConfigs];
        if ([self.defaultConfigArray count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    }
}

#pragma mark - button functions
- (void)btnCancelClicked {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.defaultConfigArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString* cellId = @"ETADefaultConfigId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    // Configure the cell...
    if (indexPath.row < [self.defaultConfigArray count]) {
        NSDictionary* config = [self.defaultConfigArray objectAtIndex:indexPath.row];
        NSString* configName = config[@"name"];
        if ([configName length] < 1) {
            configName = @"";
        }
        
        cell.textLabel.text = configName;
        NSString* detailString = [NSString stringWithFormat:@"%@, %@", config[@"number"], config[@"message"]];
        cell.detailTextLabel.text = detailString;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (indexPath.row < [self.defaultConfigArray count]) {
            NSDictionary* config = [self.defaultConfigArray objectAtIndex:indexPath.row];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectDefaultConfid:)]) {
                [self.delegate didSelectDefaultConfid:config];
            }
        }
    }];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
