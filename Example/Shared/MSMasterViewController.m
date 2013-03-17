//
//  MSMasterViewController.m
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 11/20/12.
//  Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.
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
#import "MSExampleTableViewController.h"
#import "MSExampleControlsViewController.h"

NSString * const MSMasterViewControllerCellReuseIdentifier = @"MSMasterViewControllerCellReuseIdentifier";

typedef NS_ENUM(NSUInteger, MSMasterViewControllerTableViewSectionType) {
    MSMasterViewControllerTableViewSectionTypeAppearanceTypes,
    MSMasterViewControllerTableViewSectionTypeControls,
    MSMasterViewControllerTableViewSectionTypeAbout,
    MSMasterViewControllerTableViewSectionTypeCount
};

@interface MSMasterViewController () <MSNavigationPaneViewControllerDelegate>

@property (nonatomic, strong) NSDictionary *paneViewControllerTitles;
#if defined(STORYBOARD)
@property (nonatomic, strong) NSDictionary *paneViewControllerIdentifiers;
#else
@property (nonatomic, strong) NSDictionary *paneViewControllerClasses;
#endif
@property (nonatomic, strong) NSDictionary *paneViewControllerAppearanceTypes;
@property (nonatomic, strong) NSDictionary *sectionTitles;
@property (nonatomic, strong) NSArray *tableViewSectionBreaks;

@property (nonatomic, strong) UIBarButtonItem *paneStateBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *paneRevealBarButtonItem;

- (void)updateNavigationPaneForOpenDirection:(MSNavigationPaneOpenDirection)openDirection;
- (void)navigationPaneRevealBarButtonItemTapped:(id)sender;
- (void)navigationPaneStateBarButtonItemTapped:(id)sender;

@end

@implementation MSMasterViewController

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationPaneViewController.delegate = self;
    
    // Default to the "None" appearance type
    [self transitionToViewController:MSPaneViewControllerTypeAppearanceNone];
}

#pragma mark - MSMasterViewController

- (void)initialize
{
    self.paneViewControllerType = NSUIntegerMax;
    self.paneViewControllerTitles = @{
        @(MSPaneViewControllerTypeAppearanceNone) : @"None",
        @(MSPaneViewControllerTypeAppearanceParallax) : @"Parallax",
        @(MSPaneViewControllerTypeAppearanceZoom) : @"Zoom",
        @(MSPaneViewControllerTypeAppearanceFade) : @"Fade",
        @(MSPaneViewControllerTypeControls) : @"Controls",
        @(MSPaneViewControllerTypeMonospace) : @"Monospace Ltd."
    };
    
#if defined(STORYBOARD)
    self.paneViewControllerIdentifiers = @{
        @(MSPaneViewControllerTypeAppearanceNone) : @"PaneViewControllerAppearanceNone",
        @(MSPaneViewControllerTypeAppearanceParallax) : @"PaneViewControllerAppearanceParallax",
        @(MSPaneViewControllerTypeAppearanceZoom) : @"PaneViewControllerAppearanceZoom",
        @(MSPaneViewControllerTypeAppearanceFade) : @"PaneViewControllerAppearanceFade",
        @(MSPaneViewControllerTypeControls) : @"PaneViewControllerControls",
        @(MSPaneViewControllerTypeMonospace) : @"PaneViewControllerMonospace",
    };
#else
    self.paneViewControllerClasses = @{
        @(MSPaneViewControllerTypeAppearanceNone) : MSExampleTableViewController.class,
        @(MSPaneViewControllerTypeAppearanceParallax) : MSExampleTableViewController.class,
        @(MSPaneViewControllerTypeAppearanceZoom) : MSExampleTableViewController.class,
        @(MSPaneViewControllerTypeAppearanceFade) : MSExampleTableViewController.class,
        @(MSPaneViewControllerTypeControls) : MSExampleControlsViewController.class,
        @(MSPaneViewControllerTypeMonospace) : MSMonospaceViewController.class
    };
#endif
    
    self.paneViewControllerAppearanceTypes = @{
        @(MSPaneViewControllerTypeAppearanceNone) : @(MSNavigationPaneAppearanceTypeNone),
        @(MSPaneViewControllerTypeAppearanceParallax) : @(MSNavigationPaneAppearanceTypeParallax),
        @(MSPaneViewControllerTypeAppearanceZoom) : @(MSNavigationPaneAppearanceTypeZoom),
        @(MSPaneViewControllerTypeAppearanceFade) : @(MSNavigationPaneAppearanceTypeFade),
    };
    
    self.sectionTitles = @{
        @(MSMasterViewControllerTableViewSectionTypeAppearanceTypes) : @"Appearance Types",
        @(MSMasterViewControllerTableViewSectionTypeControls) : @"Controls",
        @(MSMasterViewControllerTableViewSectionTypeAbout) : @"About",
    };
    
    self.tableViewSectionBreaks = @[
        @(MSPaneViewControllerTypeControls),
        @(MSPaneViewControllerTypeMonospace),
        @(MSPaneViewControllerTypeCount)
    ];
}

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
        [self.navigationPaneViewController setPaneState:MSNavigationPaneStateClosed animated:YES completion:nil];
        return;
    }
    
    BOOL animateTransition = self.navigationPaneViewController.paneViewController != nil;
    
#if defined(STORYBOARD)
    UIViewController *paneViewController = [self.navigationPaneViewController.storyboard instantiateViewControllerWithIdentifier:self.paneViewControllerIdentifiers[@(paneViewControllerType)]];
#else
    Class paneViewControllerClass = self.paneViewControllerClasses[@(paneViewControllerType)];
    NSParameterAssert([paneViewControllerClass isSubclassOfClass:UIViewController.class]);
    UIViewController *paneViewController = (UIViewController *)[[paneViewControllerClass alloc] init];
#endif
    
    paneViewController.navigationItem.title = self.paneViewControllerTitles[@(paneViewControllerType)];
    
    self.paneRevealBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"MSBarButtonIconNavigationPane.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(navigationPaneRevealBarButtonItemTapped:)];
    paneViewController.navigationItem.leftBarButtonItem = self.paneRevealBarButtonItem;
    
    self.paneStateBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStyleBordered target:self action:@selector(navigationPaneStateBarButtonItemTapped:)];
    paneViewController.navigationItem.rightBarButtonItem = self.paneStateBarButtonItem;

    // Update pane state button titles
    [self updateNavigationPaneForOpenDirection:self.navigationPaneViewController.openDirection];
    
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [self.navigationPaneViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
}

- (void)updateNavigationPaneForOpenDirection:(MSNavigationPaneOpenDirection)openDirection
{
    if (openDirection == MSNavigationPaneOpenDirectionLeft) {
        self.paneStateBarButtonItem.title = @"Top Reveal";
        self.navigationPaneViewController.openStateRevealWidth = 265.0;
        self.navigationPaneViewController.paneViewSlideOffAnimationEnabled = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    } else {
        self.paneStateBarButtonItem.title = @"Left Reveal";
        self.navigationPaneViewController.openStateRevealWidth = self.tableView.contentSize.height;
        self.navigationPaneViewController.paneViewSlideOffAnimationEnabled = NO;
    }
}

- (void)navigationPaneRevealBarButtonItemTapped:(id)sender
{
    [self.navigationPaneViewController setPaneState:MSNavigationPaneStateOpen animated:YES completion:nil];
}

- (void)navigationPaneStateBarButtonItemTapped:(id)sender
{
    if (self.navigationPaneViewController.openDirection == MSNavigationPaneOpenDirectionLeft) {
        self.navigationPaneViewController.openDirection = MSNavigationPaneOpenDirectionTop;
    } else {
        self.navigationPaneViewController.openDirection =  MSNavigationPaneOpenDirectionLeft;
    }
    [self updateNavigationPaneForOpenDirection:self.navigationPaneViewController.openDirection];
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
    return self.sectionTitles[@(section)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSMasterViewControllerCellReuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MSMasterViewControllerCellReuseIdentifier];
    }
    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    cell.textLabel.text = self.paneViewControllerTitles[@(paneViewControllerType)];
    
    // Add a checkmark to the current pane type
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

#pragma mark - MSNavigationPaneViewControllerDelegate

- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didUpdateToPaneState:(MSNavigationPaneState)state
{
    // Ensure that the pane's table view can scroll to top correctly
    self.tableView.scrollsToTop = (state == MSNavigationPaneStateOpen);
}

@end
