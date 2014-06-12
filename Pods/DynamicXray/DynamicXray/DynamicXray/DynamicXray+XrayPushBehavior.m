//
//  DynamicXray+XrayPushBehavior.m
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

#import "DynamicXray+XrayPushBehavior.h"
#import "DynamicXray_Internal.h"
#import "DynamicXray+XrayVisualiseBehaviors.h"
#import "DXRDecayingLifetime.h"


static NSString * const DXRXrayPushBehaviorPushPointsKey = @"pushPoints";


@implementation DynamicXray (XrayPushBehavior)

- (void)instantaneousPushBehaviorDidBecomeActiveNotification:(NSNotification *)notification
{
    UIPushBehavior *pushBehavior = notification.object;

    DXRDecayingLifetime *pushLifetime = [self.instantaneousPushBehaviorLifetimes objectForKey:pushBehavior];
    if (pushLifetime == nil) {
        pushLifetime = [[DXRDecayingLifetime alloc] init];
        pushLifetime.decayTime = 0.5;

        [self.instantaneousPushBehaviorLifetimes setObject:pushLifetime forKey:pushBehavior];
    }

    NSMutableArray *pushPoints = [NSMutableArray array];
    for (id<UIDynamicItem> item in pushBehavior.items) {
        CGPoint pushPoint = item.center;

        UIOffset offset = [pushBehavior targetOffsetFromCenterForItem:item];
        pushPoint.x += offset.horizontal;
        pushPoint.y += offset.vertical;

        [pushPoints addObject:[NSValue valueWithCGPoint:pushPoint]];
    }
    pushLifetime.userInfo = @{DXRXrayPushBehaviorPushPointsKey: pushPoints};

    [pushLifetime incrementReferenceCount];
}


- (void)introspectInstantaneousPushBehaviors
{
    NSMutableArray *snuffedLifetimes = [NSMutableArray array];
    for (UIPushBehavior *instantaneousPushBehavior in self.instantaneousPushBehaviorLifetimes) {
        DXRDecayingLifetime *pushLifetime = [self.instantaneousPushBehaviorLifetimes objectForKey:instantaneousPushBehavior];
        [pushLifetime decrementReferenceCount];
        if (pushLifetime.decay > 0) {
            CGFloat transparency = 1.0f - pushLifetime.decay;
            NSArray *pushPoints = pushLifetime.userInfo[DXRXrayPushBehaviorPushPointsKey];
            [self visualiseInstantaneousPushBehavior:instantaneousPushBehavior atLocations:pushPoints withTransparency:transparency];
        }
        else {
            [snuffedLifetimes addObject:instantaneousPushBehavior];
        }
    }
    for (UIPushBehavior *instantaneousPushBehavior in snuffedLifetimes) {
        [self.instantaneousPushBehaviorLifetimes removeObjectForKey:instantaneousPushBehavior];
    }
}

@end
