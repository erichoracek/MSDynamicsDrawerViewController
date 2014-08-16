//
//  MSStylesViewController.m
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

#import "MSStylesViewController.h"
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerHelperFunctions.h>

NSString * const MSStyleDirectionCellReuseIdentifier = @"Style Direction Cell";

@interface MSStylesViewController ()

@property (nonatomic, strong) NSArray *styleClasses;
@property (nonatomic, strong) NSDictionary *styleNames;
@property (nonatomic, strong) NSDictionary *styleDescriptions;
@property (nonatomic, strong) NSDictionary *directionNames;

@end

@implementation MSStylesViewController

#pragma mark - UIViewController

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSStyleDirectionCellReuseIdentifier];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark - MSStylesViewController

- (NSArray *)styleClasses
{
    if (!_styleClasses) {
        self.styleClasses = @[
            [MSDynamicsDrawerParallaxStyle class],
            [MSDynamicsDrawerFadeStyle class],
            [MSDynamicsDrawerShadowStyle class],
            [MSDynamicsDrawerResizeStyle class],
            [MSDynamicsDrawerScaleStyle class]
        ];
    }
    return _styleClasses;
}

- (NSDictionary *)styleNames
{
    if (!_styleNames) {
        self.styleNames = @{
            NSStringFromClass([MSDynamicsDrawerScaleStyle class]) : @"Scale",
            NSStringFromClass([MSDynamicsDrawerFadeStyle class]) : @"Fade",
            NSStringFromClass([MSDynamicsDrawerParallaxStyle class]) : @"Parallax",
            NSStringFromClass([MSDynamicsDrawerShadowStyle class]) : @"Shadow",
            NSStringFromClass([MSDynamicsDrawerResizeStyle class]) : @"Drawer Resize"
        };
    }
    return _styleNames;
}

- (NSDictionary *)styleDescriptions
{
    if (!_styleDescriptions) {
        self.styleDescriptions = @{
            NSStringFromClass([MSDynamicsDrawerScaleStyle class]) :
                @"The 'Scale' style scales the drawer view to create a zoom-in effect as the pane view is opened",
            NSStringFromClass([MSDynamicsDrawerFadeStyle class]) :
                @"The 'Fade' style fades the drawer view as the pane view is opened",
            NSStringFromClass([MSDynamicsDrawerParallaxStyle class]) :
                @"The 'Parallax' style translates the drawer view inwards from an initial offset as the pane view is opened",
            NSStringFromClass([MSDynamicsDrawerShadowStyle class]) :
                @"The 'Shadow' style causes the pane view to cast a shadow on the drawer view",
            NSStringFromClass([MSDynamicsDrawerResizeStyle class]) :
                @"The 'Drawer Resize' style resizes the drawer view controller's view to fit within drawer's reveal distance"
        };
    }
    return _styleDescriptions;
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
    return self.styleClasses.count;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSStyleDirectionCellReuseIdentifier forIndexPath:indexPath];
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    NSInteger possibleDrawerDirection = dynamicsDrawerViewController.possibleDrawerDirection;
    __block NSInteger possibleDrawerDirectionRow = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        if (indexPath.row == possibleDrawerDirectionRow) {
            NSString *title = self.directionNames[@(drawerDirection)];
            BOOL styleEnabled = NO;
            Class styleClass = self.styleClasses[indexPath.section];
            for (id <MSDynamicsDrawerStyle> style in [dynamicsDrawerViewController stylesForDirection:drawerDirection]) {
                if ([style isKindOfClass:styleClass]) {
                    styleEnabled = YES;
                    break;
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:(styleEnabled ? @"✔︎ %@" : @"✘ %@"), title];
        }
        possibleDrawerDirectionRow++;
    });
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"%@ Style", self.styleNames[NSStringFromClass(self.styleClasses[section])]];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.styleDescriptions[NSStringFromClass(self.styleClasses[section])];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    __block NSInteger possibleDrawerDirectionRow = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(dynamicsDrawerViewController.possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        if (indexPath.row == possibleDrawerDirectionRow) {
            id <MSDynamicsDrawerStyle> existingStyle;
            Class styleClass = self.styleClasses[indexPath.section];
            for (id <MSDynamicsDrawerStyle> style in [dynamicsDrawerViewController stylesForDirection:drawerDirection]) {
                if ([style isKindOfClass:styleClass]) {
                    existingStyle = style;
                    break;
                }
            }
            if (existingStyle) {
                [dynamicsDrawerViewController removeStyle:existingStyle forDirection:drawerDirection];
            } else {
                [dynamicsDrawerViewController addStyle:[styleClass new] forDirection:drawerDirection];
            }
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
        }
        possibleDrawerDirectionRow++;
    });
}

@end
