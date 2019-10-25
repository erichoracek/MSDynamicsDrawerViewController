//
//  UIPushBehavior+DynamicXrayIntrospection.m
//  DynamicXray
//
//  Created by Chris Miles on 24/01/2014.
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

#import "UIPushBehavior+DynamicXrayIntrospection.h"
#import "JRSwizzle.h"


NSString * const DXRDynamicXrayInstantaneousPushBehaviorDidBecomeActiveNotification = @"DXRDynamicXrayInstantaneousPushBehaviorDidBecomeActiveNotification";


@implementation UIPushBehavior (DynamicXrayIntrospection)

+ (void)load
{
    //DLog(@"Swizzling UIPushBehavior method -setActive:");

    NSError *error = nil;
    if ([UIPushBehavior jr_swizzleMethod:NSSelectorFromString(@"setActive:")
                              withMethod:NSSelectorFromString(@"_xraySetActive:")
                                   error:&error] == NO) {
        DLog(@"Swizzle error: %@", error);
    }
}


- (void)_xraySetActive:(BOOL)active
{
    if (active && self.mode == UIPushBehaviorModeInstantaneous) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DXRDynamicXrayInstantaneousPushBehaviorDidBecomeActiveNotification object:self userInfo:nil];
    }

    // Pass to original method
    [self _xraySetActive:active];
}

@end
