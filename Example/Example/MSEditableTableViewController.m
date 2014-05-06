//
//  MSEditableTableViewController.m
//  Example
//
//  Created by Eric Horacek on 12/4/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSEditableTableViewController.h"

NSString * const MSEditableCellReuseIdentifier = @"Editable Cell";
NSString * const MSActionCellReuseIdentifier = @"Action Cell";

typedef NS_ENUM(NSInteger, MSEditableTableSectionType) {
    MSEditableTableSectionTypeRepresentedObjects,
    MSEditableTableSectionTypeActions,
    MSEditableTableSectionTypeCount,
};

@interface MSEditableTableViewController ()

@property (nonatomic, strong) NSMutableArray *representedObjects;

@end

@implementation MSEditableTableViewController

#pragma mark - NSObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSEditableCellReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSActionCellReuseIdentifier];
    self.toolbarItems = @[self.editButtonItem];
    [self.navigationController setToolbarHidden:NO];
}

#pragma mark - MSEditableTableViewController

- (void)initialize
{
    self.representedObjects = [@[[NSDate date]] mutableCopy];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MSEditableTableSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case MSEditableTableSectionTypeRepresentedObjects:
            return [self.representedObjects count];
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MSEditableTableSectionTypeRepresentedObjects: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSEditableCellReuseIdentifier forIndexPath:indexPath];
            static NSDateFormatter *dateFormatter;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dateFormatter = [NSDateFormatter new];
                [dateFormatter setDateStyle:NSDateFormatterNoStyle];
                [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
            });
            cell.textLabel.text = [dateFormatter stringFromDate:self.representedObjects[indexPath.row]];
            return cell;
        }
        case MSEditableTableSectionTypeActions: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSActionCellReuseIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"Record new time";
            cell.textLabel.textColor = self.view.window.tintColor;
            return cell;
        }
        default:
            return nil;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MSEditableTableSectionTypeRepresentedObjects:
            return YES;
        default:
            return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.representedObjects removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self.representedObjects addObject:[NSDate date]];
    }   
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.representedObjects exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MSEditableTableSectionTypeRepresentedObjects:
            return YES;
        default:
            return NO;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case MSEditableTableSectionTypeRepresentedObjects:
            return @"Times";
        case MSEditableTableSectionTypeActions:
            return @"Actions";
        default:
            return nil;
    }
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MSEditableTableSectionTypeRepresentedObjects:
            return NO;
        default:
            return YES;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MSEditableTableSectionTypeActions: {
            [self.tableView setEditing:NO animated:YES];
            [self.representedObjects addObject:[NSDate date]];
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.representedObjects.count - 1) inSection:MSEditableTableSectionTypeRepresentedObjects]] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView endUpdates];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            break;
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (proposedDestinationIndexPath.section == MSEditableTableSectionTypeActions) {
        return [NSIndexPath indexPathForItem:([tableView numberOfRowsInSection:MSEditableTableSectionTypeRepresentedObjects] - 1) inSection:MSEditableTableSectionTypeRepresentedObjects];
    }
    return proposedDestinationIndexPath;
}

@end
