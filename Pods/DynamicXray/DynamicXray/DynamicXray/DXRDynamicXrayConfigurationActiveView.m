//
//  DXRDynamicXrayConfigurationActiveView.m
//  DynamicXray
//
//  Created by Chris Miles on 5/03/2014.
//  Copyright (c) 2014 Chris Miles. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "DXRDynamicXrayConfigurationActiveView.h"

@interface DXRDynamicXrayConfigurationActiveView ()

@property (strong, nonatomic, readwrite) UISwitch *activeToggleSwitch;

@end


@implementation DXRDynamicXrayConfigurationActiveView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UISwitch *activeToggleSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        activeToggleSwitch.translatesAutoresizingMaskIntoConstraints = NO;

        UILabel *activeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        activeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        activeLabel.text = @"Xray";
        activeLabel.font = [UIFont fontWithName:@"Avenir Next Condensed" size:29.0f];
        activeLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.6f];

        [self addSubview:activeLabel];
        [self addSubview:activeToggleSwitch];

        NSDictionary *layoutViews = NSDictionaryOfVariableBindings(activeLabel, activeToggleSwitch);

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[activeLabel]-(5)-[activeToggleSwitch]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:layoutViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[activeLabel]-(>=0)-|" options:0 metrics:nil views:layoutViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[activeToggleSwitch]-(>=0)-|" options:0 metrics:nil views:layoutViews]];

        [activeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [activeToggleSwitch setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

        self.activeToggleSwitch = activeToggleSwitch;
    }
    return self;
}

@end
