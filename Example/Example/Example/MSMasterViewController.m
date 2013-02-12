//
//  MSMasterViewController.m
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 11/20/12.
//  Copyright (c) 2012 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MSMasterViewController.h"
#import "MSMonospaceViewController.h"

NSString * const MSMasterViewControllerCellReuseIdentifier = @"MSMasterViewControllerCellReuseIdentifier";

typedef NS_ENUM(NSUInteger, MSMasterViewControllerTableViewSectionType) {
    MSMasterViewControllerTableViewSectionTypeAppearanceTypes,
    MSMasterViewControllerTableViewSectionTypeAbout,
    MSMasterViewControllerTableViewSectionTypeCount
};

@interface MSMasterViewController ()

@property (nonatomic, strong) NSDictionary *paneViewControllerTitles;
@property (nonatomic, strong) NSDictionary *paneViewControllerClasses;
@property (nonatomic, strong) NSDictionary *paneViewControllerAppearanceTypes;
@property (nonatomic, strong) NSArray *tableViewSectionBreaks;

@end

@implementation MSMasterViewController

#pragma mark - UIViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.paneViewControllerType = NSUIntegerMax;
        self.paneViewControllerTitles = @{
            @(MSPaneViewControllerTypeAppearanceNone) : @"None",
            @(MSPaneViewControllerTypeAppearanceParallax) : @"Parallax",
            @(MSPaneViewControllerTypeAppearanceZoom) : @"Zoom",
            @(MSPaneViewControllerTypeAppearanceFade) : @"Fade",
            @(MSPaneViewControllerTypeMonospace) : @"Monospace Ltd."
        };
        self.paneViewControllerClasses = @{
            @(MSPaneViewControllerTypeAppearanceNone) : UITableViewController.class,
            @(MSPaneViewControllerTypeAppearanceParallax) : UITableViewController.class,
            @(MSPaneViewControllerTypeAppearanceZoom) : UITableViewController.class,
            @(MSPaneViewControllerTypeAppearanceFade) : UITableViewController.class,
            @(MSPaneViewControllerTypeMonospace) : MSMonospaceViewController.class
        };
        self.paneViewControllerAppearanceTypes = @{
            @(MSPaneViewControllerTypeAppearanceNone) : @(MSNavigationPaneAppearanceTypeNone),
            @(MSPaneViewControllerTypeAppearanceParallax) : @(MSNavigationPaneAppearanceTypeParallax),
            @(MSPaneViewControllerTypeAppearanceZoom) : @(MSNavigationPaneAppearanceTypeZoom),
            @(MSPaneViewControllerTypeAppearanceFade) : @(MSNavigationPaneAppearanceTypeFade),
        };
        self.tableViewSectionBreaks = @[
            @(MSPaneViewControllerTypeMonospace),
            @(MSPaneViewControllerTypeCount)
        ];
    }
    return self;
}

#pragma mark - MSMasterViewController

- (MSPaneViewControllerType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType;
    if (indexPath.section == 0) {
        paneViewControllerType = indexPath.row;
    } else {
        paneViewControllerType = ([self.tableViewSectionBreaks[(indexPath.section - 1)] integerValue] + indexPath.row);
    }
    NSAssert(paneViewControllerType < MSPaneViewControllerTypeCount, @"Invalid Index Path");
    return paneViewControllerType;
}

- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType
{
    if (paneViewControllerType == self.paneViewControllerType) {
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES];
        return;
    }
    
    BOOL animateTransition = self.navigationPaneViewController.paneViewController != nil;
    
    Class paneViewControllerClass = self.paneViewControllerClasses[@(paneViewControllerType)];
    NSParameterAssert([paneViewControllerClass isSubclassOfClass:UIViewController.class]);
    UIViewController *paneViewController = (UIViewController *)[[paneViewControllerClass alloc] init];
    paneViewController.navigationItem.title = self.paneViewControllerTitles[@(paneViewControllerType)];
    paneViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MSBarButtonIconNavigationPane.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(navigationPaneBarButtonItemTapped:)];
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [self.navigationPaneViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
}

- (void)navigationPaneBarButtonItemTapped:(id)sender;
{
    [self.navigationPaneViewController setPaneState:MSNavigationPaneStateOpen animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MSMasterViewControllerTableViewSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.tableViewSectionBreaks[section] integerValue];
    } else {
        return ([self.tableViewSectionBreaks[section] integerValue] - [self.tableViewSectionBreaks[(section - 1)] integerValue]);
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case MSMasterViewControllerTableViewSectionTypeAppearanceTypes:
            return @"Appearance Types";
        case MSMasterViewControllerTableViewSectionTypeAbout:
            return @"About";
        default:
            return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSMasterViewControllerCellReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MSMasterViewControllerCellReuseIdentifier];
    }
    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    cell.textLabel.text = self.paneViewControllerTitles[@(paneViewControllerType)];
    if (self.paneViewControllerAppearanceTypes[@(paneViewControllerType)] && (self.navigationPaneViewController.appearanceType == [self.paneViewControllerAppearanceTypes[@(paneViewControllerType)] unsignedIntegerValue])) {
        cell.textLabel.text = [NSString stringWithFormat:@"✓ %@", cell.textLabel.text];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    [self transitionToViewController:paneViewControllerType];
    if (self.paneViewControllerAppearanceTypes[@(paneViewControllerType)]) {
        self.navigationPaneViewController.appearanceType = [self.paneViewControllerAppearanceTypes[@(paneViewControllerType)] unsignedIntegerValue];
        // Update row titles
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
