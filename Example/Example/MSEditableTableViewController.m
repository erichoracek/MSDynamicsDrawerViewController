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

#pragma mark - UIViewController

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    if ([parent isKindOfClass:[UINavigationController class]]) {
        self.navigationController.toolbarHidden = NO;
        self.toolbarItems = @[self.editButtonItem];
    }
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
}

#pragma mark - MSEditableTableViewController

- (NSMutableArray *)representedObjects
{
    if (!_representedObjects) {
        self.representedObjects = [@[[NSDate date]] mutableCopy];
    }
    return _representedObjects;
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
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
    case MSEditableTableSectionTypeRepresentedObjects: {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:MSEditableCellReuseIdentifier forIndexPath:indexPath];
        static NSDateFormatter* dateFormatter;
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
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:MSActionCellReuseIdentifier forIndexPath:indexPath];
        cell.textLabel.text = @"Record new time";
        cell.textLabel.textColor = self.view.window.tintColor;
        return cell;
    }
    }
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
    case MSEditableTableSectionTypeRepresentedObjects:
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ((NSInteger)editingStyle) {
    case UITableViewCellEditingStyleDelete:
        [self.representedObjects removeObjectAtIndex:indexPath.row];
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [tableView endUpdates];
        break;
    case UITableViewCellEditingStyleInsert:
        [self.representedObjects addObject:[NSDate date]];
        break;
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
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
    case MSEditableTableSectionTypeRepresentedObjects:
        return @"Times";
    case MSEditableTableSectionTypeActions:
        return @"Actions";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
    case MSEditableTableSectionTypeRepresentedObjects:
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
    case MSEditableTableSectionTypeActions:
        [self.tableView setEditing:NO animated:YES];
        [self.representedObjects addObject:[NSDate date]];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(self.representedObjects.count - 1) inSection:MSEditableTableSectionTypeRepresentedObjects]] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        break;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    switch (proposedDestinationIndexPath.section) {
    case MSEditableTableSectionTypeActions:
        return [NSIndexPath indexPathForItem:([tableView numberOfRowsInSection:MSEditableTableSectionTypeRepresentedObjects] - 1) inSection:MSEditableTableSectionTypeRepresentedObjects];
    }
    return proposedDestinationIndexPath;
}

@end
