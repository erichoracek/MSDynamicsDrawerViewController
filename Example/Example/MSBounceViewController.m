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

@implementation MSBounceViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSBounceCellReuseIdentifier];
}

#pragma mark - UITableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    NSInteger possibleDrawerDirection = dynamicsDrawerViewController.possibleDrawerDirection;
    __block NSInteger possibleDirectionCount = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(possibleDrawerDirection, ^(MSDynamicsDrawerDirection maskedValue) {
        possibleDirectionCount++;
    });
    return possibleDirectionCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSBounceCellReuseIdentifier forIndexPath:indexPath];
    
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Bounce Open";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"Invoke the 'bouncePaneOpenInDirection:' method to bounce the pane view open to reveal the drawer view underneath.\n\nA bounce can be used to indicate that there's a drawer view controller underneath that can be accessed by swiping, similar to the iOS lock screen camera bounce.";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    __block NSInteger possibleDrawerDirectionRow = 0;
    MSDynamicsDrawerDirectionActionForMaskedValues(dynamicsDrawerViewController.possibleDrawerDirection, ^(MSDynamicsDrawerDirection drawerDirection) {
        if (indexPath.row == possibleDrawerDirectionRow) {
            [dynamicsDrawerViewController bouncePaneOpenInDirection:drawerDirection];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        possibleDrawerDirectionRow++;
    });
}

@end
