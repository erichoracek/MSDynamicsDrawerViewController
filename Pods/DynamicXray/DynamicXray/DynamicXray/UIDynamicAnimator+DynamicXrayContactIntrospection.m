//
//  UIDynamicAnimator+DynamicXrayContactIntrospection.m
//  DynamicXray
//
//  Created by Chris Miles on 9/01/2014.
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

#import "UIDynamicAnimator+DynamicXrayContactIntrospection.h"

#import "DXRContactHandler.h"
#import "JRSwizzle.h"



@implementation UIDynamicAnimator (DynamicXrayContactIntrospection)

+ (void)load
{
    //DLog(@"Swizzling UIDynamicAnimator methods -didBeginContact: and didEndContact:");

    NSError *error = nil;
    if ([UIDynamicAnimator jr_swizzleMethod:NSSelectorFromString(@"didBeginContact:")
                                 withMethod:NSSelectorFromString(@"_xrayDidBeginContact:")
                                      error:&error] == NO) {
        DLog(@"Swizzle error: %@", error);
    }
    if ([UIDynamicAnimator jr_swizzleMethod:NSSelectorFromString(@"didEndContact:")
                                 withMethod:NSSelectorFromString(@"_xrayDidEndContact:")
                                      error:&error] == NO) {
        DLog(@"Swizzle error: %@", error);
    }
}


- (void)_xrayDidBeginContact:(PKPhysicsContact *)physicsContact
{
    NSString *contactClassName = [[physicsContact class] description];
    if ([contactClassName isEqualToString:@"PKPhysicsContact"]) {
        [DXRContactHandler handleBeginContactWithPhysicsContact:physicsContact];
    }

    // Pass to original method
    [self _xrayDidBeginContact:physicsContact];
}

- (void)_xrayDidEndContact:(PKPhysicsContact *)physicsContact
{
    NSString *contactClassName = [[physicsContact class] description];
    if ([contactClassName isEqualToString:@"PKPhysicsContact"]) {
        [DXRContactHandler handleEndContactWithPhysicsContact:physicsContact];
    }

    // Pass to original method
    [self _xrayDidEndContact:physicsContact];
}

@end
