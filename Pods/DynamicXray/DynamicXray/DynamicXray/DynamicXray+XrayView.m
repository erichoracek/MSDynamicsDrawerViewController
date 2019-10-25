//
//  DynamicXray+XrayView.m
//  DynamicXray
//
//  Created by Chris Miles on 9/05/2014.
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

#import "DynamicXray+XrayView.h"
#import "DynamicXray_Internal.h"
#import "DXRDynamicXrayView.h"


@implementation DynamicXray (XrayView)


#pragma mark - Color

+ (UIColor *)xrayStrokeColor
{
    return [UIColor colorWithRed:0 green:0.639216f blue:0.85098f alpha:1.0f];
}

+ (UIColor *)xrayFillColor
{
    return [self xrayStrokeColor];
}

+ (UIColor *)xrayContactColor
{
    return [UIColor colorWithRed:1.0f green:0.478431f blue:0.0941176f alpha:1.0f];
}


#pragma mark - Transparency Levels

- (void)updateDynamicsViewTransparencyLevels
{
    CGFloat xrayViewAlpha = 1.0f;
    UIColor *backgroundColor;

    if (self.crossFade > 0) {
        backgroundColor = [UIColor colorWithWhite:0 alpha:(CGFloat)fabs(self.crossFade)];
    }
    else {
        backgroundColor = [UIColor clearColor];
        xrayViewAlpha = 1.0f + self.crossFade;
    }

    self.xrayViewController.view.alpha = xrayViewAlpha;
    self.xrayWindow.backgroundColor = backgroundColor;
}

- (void)resetDynamicsViewTransparencyLevels
{
    self.xrayViewController.view.alpha = 1.0f;
    self.xrayWindow.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
}

@end
