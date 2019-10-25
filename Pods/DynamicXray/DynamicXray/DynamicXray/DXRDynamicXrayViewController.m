//
//  DXRDynamicXrayViewController.m
//  DynamicXray
//
//  Created by Chris Miles on 16/10/13.
//  Copyright (c) 2013 Chris Miles. All rights reserved.
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

#import "DXRDynamicXrayViewController.h"
#import "DXRDynamicXrayView.h"


@implementation DXRDynamicXrayViewController

- (id)initDynamicXray:(DynamicXray *)dynamicXray
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _dynamicXray = dynamicXray;
    }
    return self;
}

- (void)loadView
{
    self.view = [[DXRDynamicXrayView alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 568.0f)];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
}

- (DXRDynamicXrayView *)xrayView
{
    return (DXRDynamicXrayView *)self.view;
}

@end
