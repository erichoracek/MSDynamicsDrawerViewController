//
//  MSControlsViewController.m
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

#import "MSControlsViewController.h"

NSString * const MSSliderControlCellReuseIdentifier = @"Slider Control Cell";
NSString * const MSSwitchControlCellReuseIdentifier = @"Switch Control Cell";

typedef NS_ENUM(NSInteger, MSControlCellType) {
    MSControlCellTypeSlider,
    MSControlCellTypeSwitch,
    MSControlCellTypeCount,
};

@implementation MSControlsViewController

#pragma mark - UIViewController

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSSliderControlCellReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSSwitchControlCellReuseIdentifier];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MSControlCellTypeCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case MSControlCellTypeSlider: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSSliderControlCellReuseIdentifier forIndexPath:indexPath];
            cell.accessoryView = [UISlider new];
            cell.textLabel.text = @"Slider";
            return cell;
        }
        case MSControlCellTypeSwitch: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSSwitchControlCellReuseIdentifier forIndexPath:indexPath];
            cell.accessoryView = [UISwitch new];
            cell.textLabel.text = @"Switch";
            return cell;
        }
        default:
            return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Control Types";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"Swiping on UISwitch and UISlider will not cause the pane view to be dragged because their classes have been added to the 'touchForwardingClasses' set on 'MSDynamicsDrawerViewController'.";
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
