//
//  MSBounceViewController.m
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 2/23/13.
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

#import "MSBounceViewController.h"

NSString * const MSBounceCellReuseIdentifier = @"Bounce Cell";
NSString * const MSBounceDynamicsCellReuseIdentifier = @"Bounce Dynamics Cell";

typedef NS_ENUM(NSInteger, MSBounceSectionType) {
    MSBounceSectionTypeBounce,
    MSBounceSectionTypeBounceMagnitude,
    MSBounceSectionTypeBounceElasticity,
    MSBounceSectionTypeCount,
};

@implementation MSBounceViewController

#pragma mark - UIViewController

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSBounceCellReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSBounceDynamicsCellReuseIdentifier];
}

#pragma mark - MSDynamicsViewController

- (void)sliderDidUpdateValue:(UISlider *)slider
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    switch (slider.tag) {
        case MSBounceSectionTypeBounceMagnitude:
            dynamicsDrawerViewController.bounceMagnitude = slider.value;
            break;
        case MSBounceSectionTypeBounceElasticity:
            dynamicsDrawerViewController.bounceElasticity = slider.value;
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MSBounceSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case MSBounceSectionTypeBounce: {
            MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
            NSInteger possibleDrawerDirection = dynamicsDrawerViewController.possibleDrawerDirection;
            __block NSInteger possibleDirectionCount = 0;
            MSDynamicsDrawerDirectionActionForMaskedValues(possibleDrawerDirection, ^(MSDynamicsDrawerDirection maskedValue) {
                possibleDirectionCount++;
            });
            return possibleDirectionCount;
        }
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case MSBounceSectionTypeBounce: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSBounceCellReuseIdentifier forIndexPath:indexPath];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = self.view.window.tintColor;
            
            MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
            NSInteger possibleDrawerDirection = dynamicsDrawerViewController.possibleDrawerDirection;
            __block NSInteger possibleDrawerDirectionRow = 0;
            MSDynamicsDrawerDirectionActionForMaskedValues(possibleDrawerDirection, ^(MSDynamicsDrawerDirection maskedValue) {
                if (indexPath.row == possibleDrawerDirectionRow) {
                    NSString *title;
                    switch (maskedValue) {
                        case MSDynamicsDrawerDirectionLeft:
                            title = @"→";
                            break;
                        case MSDynamicsDrawerDirectionRight:
                            title = @"←";
                            break;
                        case MSDynamicsDrawerDirectionTop:
                            title = @"↓";
                            break;
                        case MSDynamicsDrawerDirectionBottom:
                            title = @"↑";
                            break;
                        default:
                            break;
                    }
                    cell.textLabel.text = title;
                }
                possibleDrawerDirectionRow++;
            });
            return cell;
        }
        default: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSBounceDynamicsCellReuseIdentifier forIndexPath:indexPath];
            MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
            UISlider *slider = (UISlider *)cell.accessoryView;
            if (!slider || ![slider isKindOfClass:[UISlider class]]) {
                slider = [UISlider new];
                [slider addTarget:self action:@selector(sliderDidUpdateValue:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = slider;
            }
            slider.frame = (CGRect){slider.frame.origin, {200.0, slider.frame.size.height}};
            slider.tag = indexPath.section;
            switch (indexPath.section) {
                case MSBounceSectionTypeBounceMagnitude: {
                    slider.minimumValue = 0.0;
                    slider.maximumValue = 200.0;
                    slider.value = dynamicsDrawerViewController.bounceMagnitude;
                    break;
                }
                case MSBounceSectionTypeBounceElasticity: {
                    slider.minimumValue = 0.0;
                    slider.maximumValue = 1.0;
                    slider.value = dynamicsDrawerViewController.bounceElasticity;
                    break;
                }
            }
            cell.textLabel.text = [NSString stringWithFormat:@"%@", @(slider.value)];
            return cell;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case MSBounceSectionTypeBounce:
            return @"Bounce Open in Direction";
        case MSBounceSectionTypeBounceMagnitude:
            return @"Bounce Magnitude";
        case MSBounceSectionTypeBounceElasticity:
            return @"Bounce Elasticity";
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case MSBounceSectionTypeBounce:
            return @"Invoke the 'bouncePaneOpenInDirection:' method to bounce the pane view open to reveal the drawer view underneath.\n\nA bounce can be used to indicate that there's a drawer view controller underneath that can be accessed by swiping, similar to the iOS lock screen camera bounce.";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    __block NSInteger possibleDrawerDirectionRow = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(dynamicsDrawerViewController.possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        if (indexPath.row == possibleDrawerDirectionRow) {
            [dynamicsDrawerViewController bouncePaneOpenInDirection:drawerDirection allowUserInterruption:NO completion:nil];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        possibleDrawerDirectionRow++;
    });
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == MSBounceSectionTypeBounce);
}

@end
