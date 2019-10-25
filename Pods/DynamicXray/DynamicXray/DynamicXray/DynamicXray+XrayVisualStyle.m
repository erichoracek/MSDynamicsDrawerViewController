//
//  DynamicXray+XrayVisualStyle.m
//  DynamicXray
//
//  Created by Chris Miles on 16/01/2014.
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

#import "DynamicXray.h"
#import "DynamicXray_Internal.h"
#import "DynamicXray+XrayView.h"
#import "DXRDynamicXrayView.h"


@implementation DynamicXray (XrayVisualStyle)

#pragma mark - Cross Fade

- (void)setCrossFade:(CGFloat)crossFade
{
    _crossFade = crossFade;

    if (self.isActive) {
        [self updateDynamicsViewTransparencyLevels];
    }
}

- (CGFloat)crossFade
{
    return _crossFade;
}


#pragma mark - viewOffset

- (void)setViewOffset:(UIOffset)viewOffset
{
    [[self xrayView] setDrawOffset:viewOffset];
}

- (UIOffset)viewOffset
{
    return [[self xrayView] drawOffset];
}


#pragma mark - drawDynamicItemsEnabled

- (void)setDrawDynamicItemsEnabled:(BOOL)drawDynamicItemsEnabled
{
    _drawDynamicItemsEnabled = drawDynamicItemsEnabled;

    if (drawDynamicItemsEnabled) {
        if (self.dynamicItemsToDraw == nil) {
            self.dynamicItemsToDraw = [NSMutableSet set];
        }
    }
    else if (self.dynamicItemsToDraw)
    {
        self.dynamicItemsToDraw = nil;
    }
}

- (BOOL)drawDynamicItemsEnabled
{
    return _drawDynamicItemsEnabled;
}


#pragma mark - allowsAntialiasing

- (void)setAllowsAntialiasing:(BOOL)allowsAntialiasing
{
    [[self xrayView] setAllowsAntialiasing:allowsAntialiasing];
}

- (BOOL)allowsAntialiasing
{
    return [[self xrayView] allowsAntialiasing];
}

@end
