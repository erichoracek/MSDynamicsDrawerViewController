//
//  DynamicXray_Internal.h
//  DynamicXray
//
//  Created by Chris Miles on 12/11/2013.
//  Copyright (c) 2013-2014 Chris Miles. All rights reserved.
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
#import "DXRDynamicXrayViewController.h"
@class DXRDynamicXrayWindowController;


@interface DynamicXray () {
    CGFloat _crossFade;
    BOOL _drawDynamicItemsEnabled;
}

@property (weak, nonatomic) UIView *referenceView;

@property (weak, nonatomic) UIView *previousReferenceView;
@property (weak, nonatomic) UIWindow *previousReferenceViewWindow;
@property (assign, nonatomic) CGRect previousReferenceViewFrame;

@property (strong, nonatomic) DXRDynamicXrayViewController *xrayViewController;
@property (strong, nonatomic) UIWindow *xrayWindow;

@property (strong, nonatomic) NSMutableSet *dynamicItemsToDraw;
@property (strong, nonatomic) NSMapTable *dynamicItemContactLifetimes;
@property (strong, nonatomic) NSMapTable *pathContactLifetimes;
@property (strong, nonatomic) NSMapTable *instantaneousPushBehaviorLifetimes;

- (void)redraw;
- (DXRDynamicXrayWindowController *)xrayWindowController;
- (DXRDynamicXrayView *)xrayView;

@end
