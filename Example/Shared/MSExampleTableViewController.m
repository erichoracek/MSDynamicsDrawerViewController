//
//  MSExampleTableViewController.m
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 2/23/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSExampleTableViewController.h"

NSString * const MSExampleTableViewControllerCellReuseIdentifier = @"MSExampleTableViewControllerCellReuseIdentifier";

@interface MSExampleTableViewController ()

@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

@end

@implementation MSExampleTableViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    self.numberFormatter = [NSNumberFormatter new];
    [self.numberFormatter setNumberStyle:NSNumberFormatterSpellOutStyle];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSExampleTableViewControllerCellReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MSExampleTableViewControllerCellReuseIdentifier];
    }
    cell.textLabel.text = [[self.numberFormatter stringFromNumber:@(indexPath.row + 1)] capitalizedString];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.numberFormatter stringFromNumber:@(section + 1)] capitalizedString];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
