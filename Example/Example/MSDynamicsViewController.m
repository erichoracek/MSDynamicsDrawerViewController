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

#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import "MSDynamicsViewController.h"

static NSString * const MSCellTitleReuseIdentifier = @"MSCellTitleReuseIdentifier";
static NSString * const MSCellSliderReuseIdentifier = @"MSCellSliderReuseIdentifier";

typedef NS_ENUM(NSInteger, MSSectionSnap) {
    MSSectionSnapSelect,
    MSSectionThrowDamping,
    MSSectionSnapFrequency,
    MSSectionSnapThrowVelocityThreshold
};

typedef NS_ENUM(NSInteger, MSSectionGravity) {
    MSSectionGravitySelect,
    MSSectionGravityMagnitude,
    MSSectionGravityPaneElasticity,
};

@interface MSDynamicsViewController ()

@property (nonatomic) NSArray *panePositioningBehaviorClasses;
@property (nonatomic) NSArray *panePositioningBehaviorNames;
@property (nonatomic) NSDictionary *sectionValuesSnap;
@property (nonatomic) NSDictionary *sectionValuesGravity;
@property (nonatomic, readonly) NSDictionary *sectionValues;
@property (nonatomic, readonly) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

@end

@implementation MSDynamicsViewController

#pragma mark - UIViewController

- (void)loadView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSCellTitleReuseIdentifier];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:MSCellSliderReuseIdentifier];
}

#pragma mark - MSDynamicsViewController

- (NSArray *)panePositioningBehaviorClasses
{
    if (!_panePositioningBehaviorClasses) {
        self.panePositioningBehaviorClasses = @[
            [MSPaneSnapBehavior class],
            [MSPaneGravityBehavior class]
        ];
    }
    return _panePositioningBehaviorClasses;
}

- (NSArray *)panePositioningBehaviorNames
{
    if (!_panePositioningBehaviorNames) {
        self.panePositioningBehaviorNames = @[
            @"Snap",
            @"Gravity"
        ];
    }
    return _panePositioningBehaviorNames;
}

static NSString * const MSSectionValueKeyKeyPath = @"MSSectionValueKeyKeyPath";
static NSString * const MSSectionValueKeyHeaderText = @"MSSectionValueKeyHeaderText";
static NSString * const MSSectionValueKeyFooterText = @"MSSectionValueKeyFooterText";
static NSString * const MSSectionValueKeyMinimum = @"MSSectionValueKeyMinimum";
static NSString * const MSSectionValueKeyMaximum = @"MSSectionValueKeyMaximum";

- (NSDictionary *)sectionValuesSnap
{
    if (!_sectionValuesSnap) {
        self.sectionValuesSnap = @{
            @(MSSectionThrowDamping): @{
                MSSectionValueKeyHeaderText: @"Throw Damping",
                MSSectionValueKeyFooterText: @"The throw damping is the amount of oscillation the pane has when it's thrown to a position.",
                MSSectionValueKeyKeyPath: NSStringFromSelector(@selector(throwDamping)),
                MSSectionValueKeyMinimum: @0.0,
                MSSectionValueKeyMaximum: @1.0
            },
            @(MSSectionSnapFrequency): @{
                MSSectionValueKeyHeaderText: @"Frequency",
                MSSectionValueKeyFooterText: @"The frequency is the speed of the snap animation.",
                MSSectionValueKeyKeyPath: NSStringFromSelector(@selector(frequency)),
                MSSectionValueKeyMinimum: @0.0,
                MSSectionValueKeyMaximum: @10.0
            },
            @(MSSectionSnapThrowVelocityThreshold): @{
                MSSectionValueKeyHeaderText: @"Throw Velocity Threshold",
                MSSectionValueKeyFooterText: @"The velocity threshold at which the pane is considered to have been 'thrown'. When thrown, the pane 'rubber bands' ",
                MSSectionValueKeyKeyPath: NSStringFromSelector(@selector(throwVelocityThreshold)),
                MSSectionValueKeyMinimum: @0.0,
                MSSectionValueKeyMaximum: @1000.0
            }
        };
    }
    return _sectionValuesSnap;
}

- (NSDictionary *)sectionValuesGravity
{
    if (!_sectionValuesGravity) {
        self.sectionValuesGravity = @{
            @(MSSectionGravityMagnitude): @{
                MSSectionValueKeyHeaderText: @"Gravity Magnitude",
                MSSectionValueKeyFooterText: @"The magnitude of the gravity that affects the pane when it's being positioned.",
                MSSectionValueKeyKeyPath: @"gravity.magnitude",
                MSSectionValueKeyMinimum: @0.0,
                MSSectionValueKeyMaximum: @10.0
            },
            @(MSSectionGravityPaneElasticity): @{
                MSSectionValueKeyHeaderText: @"Pane Elasticity",
                MSSectionValueKeyFooterText: @"The elasticity of the pane when it collides with an edge.",
                MSSectionValueKeyKeyPath: @"paneBehavior.elasticity",
                MSSectionValueKeyMinimum: @0.0,
                MSSectionValueKeyMaximum: @1.0
            }
        };
    }
    return _sectionValuesGravity;
}

- (NSDictionary *)sectionValues
{
    if ([self.dynamicsDrawerViewController.panePositioningBehavior isKindOfClass:[MSPaneSnapBehavior class]]) {
        return self.sectionValuesSnap;
    } else if ([self.dynamicsDrawerViewController.panePositioningBehavior isKindOfClass:[MSPaneGravityBehavior class]]) {
        return self.sectionValuesGravity;
    }
    return nil;
}

- (MSDynamicsDrawerViewController *)dynamicsDrawerViewController
{
    return (MSDynamicsDrawerViewController *)self.navigationController.parentViewController;
}

- (void)sliderDidUpdateValue:(UISlider *)slider
{
    NSString *keyPath = self.sectionValues[@(slider.tag)][MSSectionValueKeyKeyPath];
    [(id)self.dynamicsDrawerViewController.panePositioningBehavior setValue:@(slider.value) forKeyPath:keyPath];
    [self.tableView reloadData];
}

- (void)configureSlider:(UISlider *)slider forIndexPath:(NSIndexPath *)indexPath
{
    slider.frame = (CGRect){slider.frame.origin, {225.0, CGRectGetHeight(slider.frame)}};
    slider.tag = indexPath.section;
    slider.minimumValue = [self.sectionValues[@(indexPath.section)][MSSectionValueKeyMinimum] floatValue];
    slider.maximumValue = [self.sectionValues[@(indexPath.section)][MSSectionValueKeyMaximum] floatValue];
    NSString *keyPath = self.sectionValues[@(indexPath.section)][MSSectionValueKeyKeyPath];
    slider.value = [[(id)self.dynamicsDrawerViewController.panePositioningBehavior valueForKeyPath:keyPath] floatValue];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return ([self.sectionValues count] + 1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.panePositioningBehaviorClasses count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Selection
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSCellTitleReuseIdentifier forIndexPath:indexPath];
        cell.textLabel.text = self.panePositioningBehaviorNames[indexPath.row];
        if ([self.dynamicsDrawerViewController.panePositioningBehavior isKindOfClass:self.panePositioningBehaviorClasses[indexPath.row]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"✔︎ %@", cell.textLabel.text];
        }
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSCellSliderReuseIdentifier forIndexPath:indexPath];
    UISlider *slider = (UISlider *)cell.accessoryView;
    if (!slider || ![slider isKindOfClass:[UISlider class]]) {
        slider = [UISlider new];
        [slider addTarget:self action:@selector(sliderDidUpdateValue:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = slider;
    }
    [self configureSlider:slider forIndexPath:indexPath];
    static NSNumberFormatter *numberFormatter;
    if (!numberFormatter) {
        numberFormatter = [NSNumberFormatter new];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [numberFormatter stringFromNumber:@(slider.value)]];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Pane Positioning Behavior";
    }
    return self.sectionValues[@(section)][MSSectionValueKeyHeaderText];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Pane Positioning Behaviors are used to create different effects when moving the pane. A gravity and a snap effect are included by default. You can also create your own.";
    }
    return self.sectionValues[@(section)][MSSectionValueKeyFooterText];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (![self.dynamicsDrawerViewController.panePositioningBehavior isKindOfClass:self.panePositioningBehaviorClasses[indexPath.row]]) {
            self.dynamicsDrawerViewController.panePositioningBehavior = [[self.panePositioningBehaviorClasses[indexPath.row] alloc] initWithDrawerViewController:self.dynamicsDrawerViewController];
            [tableView reloadData];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0);
}

@end
