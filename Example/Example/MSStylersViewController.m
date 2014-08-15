//
//  MSStylersViewController.m
//  Example
//
//  Created by Eric Horacek on 10/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
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

#import "MSStylersViewController.h"
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerHelperFunctions.h>

NSString * const MSStylerDirectionCellReuseIdentifier = @"Styler Direction Cell";

@interface MSStylersViewController ()

@property (nonatomic, strong) NSArray *stylerClasses;
@property (nonatomic, strong) NSDictionary *stylerNames;
@property (nonatomic, strong) NSDictionary *stylerDescriptions;
@property (nonatomic, strong) NSDictionary *directionNames;

@end

@implementation MSStylersViewController

#pragma mark - UIViewController

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSStylerDirectionCellReuseIdentifier];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - MSStylersViewController

- (NSArray *)stylerClasses
{
    if (!_stylerClasses) {
        self.stylerClasses = @[
            [MSDynamicsDrawerParallaxStyler class],
            [MSDynamicsDrawerFadeStyler class],
            [MSDynamicsDrawerShadowStyler class],
            [MSDynamicsDrawerResizeStyler class],
            [MSDynamicsDrawerScaleStyler class]
        ];
    }
    return _stylerClasses;
}

- (NSDictionary *)stylerNames
{
    if (!_stylerNames) {
        self.stylerNames = @{
            NSStringFromClass([MSDynamicsDrawerScaleStyler class]) : @"Scale",
            NSStringFromClass([MSDynamicsDrawerFadeStyler class]) : @"Fade",
            NSStringFromClass([MSDynamicsDrawerParallaxStyler class]) : @"Parallax",
            NSStringFromClass([MSDynamicsDrawerShadowStyler class]) : @"Shadow",
            NSStringFromClass([MSDynamicsDrawerResizeStyler class]) : @"Drawer Resize"
        };
    }
    return _stylerNames;
}

- (NSDictionary *)stylerDescriptions
{
    if (!_stylerDescriptions) {
        self.stylerDescriptions = @{
            NSStringFromClass([MSDynamicsDrawerScaleStyler class]) :
                @"The 'Scale' styler scales the drawer view to create a zoom-in effect as the pane view is opened",
            NSStringFromClass([MSDynamicsDrawerFadeStyler class]) :
                @"The 'Fade' styler fades the drawer view as the pane view is opened",
            NSStringFromClass([MSDynamicsDrawerParallaxStyler class]) :
                @"The 'Parallax' styler translates the drawer view inwards from an initial offset as the pane view is opened",
            NSStringFromClass([MSDynamicsDrawerShadowStyler class]) :
                @"The 'Shadow' styler causes the pane view to cast a shadow on the drawer view",
            NSStringFromClass([MSDynamicsDrawerResizeStyler class]) :
                @"The 'Drawer Resize' styler resizes the drawer view controller's view to fit within drawer's reveal distance"
        };
    }
    return _stylerDescriptions;
}

- (NSDictionary *)directionNames
{
    if (!_directionNames) {
        self.directionNames = @{
            @(MSDynamicsDrawerDirectionLeft) : @"Left",
            @(MSDynamicsDrawerDirectionRight) : @"Right",
            @(MSDynamicsDrawerDirectionTop) : @"Top",
            @(MSDynamicsDrawerDirectionBottom) : @"Bottom"
        };
    }
    return _directionNames;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.stylerClasses.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    NSInteger possibleDrawerDirection = dynamicsDrawerViewController.possibleDrawerDirection;
    __block NSInteger possibleDirectionCount = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        possibleDirectionCount++;
    });
    return possibleDirectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSStylerDirectionCellReuseIdentifier forIndexPath:indexPath];
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    NSInteger possibleDrawerDirection = dynamicsDrawerViewController.possibleDrawerDirection;
    __block NSInteger possibleDrawerDirectionRow = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        if (indexPath.row == possibleDrawerDirectionRow) {
            NSString *title = self.directionNames[@(drawerDirection)];
            BOOL stylerEnabled = NO;
            Class stylerClass = self.stylerClasses[indexPath.section];
            for (id <MSDynamicsDrawerStyler> styler in [dynamicsDrawerViewController stylersForDirection:drawerDirection]) {
                if ([styler isKindOfClass:stylerClass]) {
                    stylerEnabled = YES;
                    break;
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:(stylerEnabled ? @"✔︎ %@" : @"✘ %@"), title];
        }
        possibleDrawerDirectionRow++;
    });
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@ Styler", self.stylerNames[NSStringFromClass(self.stylerClasses[section])]];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.stylerDescriptions[NSStringFromClass(self.stylerClasses[section])];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    __block NSInteger possibleDrawerDirectionRow = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(dynamicsDrawerViewController.possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        if (indexPath.row == possibleDrawerDirectionRow) {
            id <MSDynamicsDrawerStyler> existingStyler;
            Class stylerClass = self.stylerClasses[indexPath.section];
            for (id <MSDynamicsDrawerStyler> styler in [dynamicsDrawerViewController stylersForDirection:drawerDirection]) {
                if ([styler isKindOfClass:stylerClass]) {
                    existingStyler = styler;
                    break;
                }
            }
            if (existingStyler) {
                [dynamicsDrawerViewController removeStyler:existingStyler forDirection:drawerDirection];
            } else {
                [dynamicsDrawerViewController addStyler:[stylerClass new] forDirection:drawerDirection];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
        possibleDrawerDirectionRow++;
    });
}

@end
