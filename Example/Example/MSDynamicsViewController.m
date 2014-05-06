//
//  MSDynamicsViewController.m
//  Example
//
//  Created by Eric Horacek on 11/9/13.
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

#import "MSDynamicsViewController.h"

NSString * const MSDynamicsCellReuseIdentifier = @"Dynamics Cell";

typedef NS_ENUM(NSInteger, MSDynamicsSectionType) {
    MSDynamicsSectionTypeGravityMagnitude,
    MSDynamicsSectionTypeElasticity,
    MSDynamicsSectionTypeCount,
};

@implementation MSDynamicsViewController

#pragma mark - UIViewController

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSDynamicsCellReuseIdentifier];
}

#pragma mark - MSDynamicsViewController

- (void)sliderDidUpdateValue:(UISlider *)slider
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    switch (slider.tag) {
        case MSDynamicsSectionTypeGravityMagnitude:
            dynamicsDrawerViewController.gravityMagnitude = slider.value;
            break;
        case MSDynamicsSectionTypeElasticity:
            dynamicsDrawerViewController.elasticity = slider.value;
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MSDynamicsSectionTypeCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSDynamicsDrawerViewController *dynamicsDrawerViewController = (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSDynamicsCellReuseIdentifier forIndexPath:indexPath];
    UISlider *slider = (UISlider *)cell.accessoryView;
    if (!slider || ![slider isKindOfClass:[UISlider class]]) {
        slider = [UISlider new];
        [slider addTarget:self action:@selector(sliderDidUpdateValue:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = slider;
    }
    slider.frame = (CGRect){slider.frame.origin, {200.0, slider.frame.size.height}};
    slider.tag = indexPath.section;
    switch (indexPath.section) {
        case MSDynamicsSectionTypeGravityMagnitude: {
            slider.minimumValue = 0.0;
            slider.maximumValue = 10.0;
            slider.value = dynamicsDrawerViewController.gravityMagnitude;
            break;
        }
        case MSDynamicsSectionTypeElasticity: {
            slider.minimumValue = 0.0;
            slider.maximumValue = 1.0;
            slider.value = dynamicsDrawerViewController.elasticity;
            break;
        }
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", @(slider.value)];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case MSDynamicsSectionTypeGravityMagnitude:
            return @"Gravity Magnitude";
        case MSDynamicsSectionTypeElasticity:
            return @"Elasticity";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
