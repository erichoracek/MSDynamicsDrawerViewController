//
//  DynamicXray+XrayContacts.m
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

#import "DynamicXray+XrayContacts.h"
#import "DynamicXray_Internal.h"
#import "DXRDecayingLifetime.h"


@implementation DynamicXray (XrayContacts)

#pragma mark - Contact Notifications

- (void)dynamicXrayContactDidBeginNotification:(NSNotification *)notification
{
    id<UIDynamicItem> dynamicItem = notification.userInfo[@"dynamicItem"];
    if (dynamicItem) {
        //DLog(@"DynamicItem did begin contact: %@", dynamicItem);
        DXRDecayingLifetime *contactLifetime = [self.dynamicItemContactLifetimes objectForKey:dynamicItem];
        if (contactLifetime == nil) {
            contactLifetime = [[DXRDecayingLifetime alloc] init];
            [self.dynamicItemContactLifetimes setObject:contactLifetime forKey:dynamicItem];
        }
        [contactLifetime incrementReferenceCount];
    }

    CGPathRef path = CFBridgingRetain(notification.userInfo[@"path"]);
    if (path) {
        id key = CFBridgingRelease(path);
        DXRDecayingLifetime *contactLifetime = [self.pathContactLifetimes objectForKey:key];
        if (contactLifetime == nil) {
            contactLifetime = [[DXRDecayingLifetime alloc] init];
            [self.pathContactLifetimes setObject:contactLifetime forKey:key];
        }
        [contactLifetime incrementReferenceCount];
    }
}

- (void)dynamicXrayContactDidEndNotification:(NSNotification *)notification
{
    id<UIDynamicItem> dynamicItem = notification.userInfo[@"dynamicItem"];
    NSUInteger contactsCount = [notification.userInfo[@"contactsCount"] unsignedIntegerValue];
    if (dynamicItem) {
        DXRDecayingLifetime *contactLifetime = [self.dynamicItemContactLifetimes objectForKey:dynamicItem];

        if (contactsCount == 0) {
            [contactLifetime zeroReferenceCount];
        }
        else {
            [contactLifetime decrementReferenceCount];
        }

        if ([contactLifetime decay] <= 0) {
            [self.dynamicItemContactLifetimes removeObjectForKey:dynamicItem];
        }
    }

    CGPathRef path = CFBridgingRetain(notification.userInfo[@"path"]);
    if (path) {
        id key = CFBridgingRelease(path);
        DXRDecayingLifetime *contactLifetime = [self.pathContactLifetimes objectForKey:key];

        if (contactsCount == 0) {
            [contactLifetime zeroReferenceCount];
        }
        else {
            [contactLifetime decrementReferenceCount];
        }

        if ([contactLifetime decay] <= 0) {
            [self.pathContactLifetimes removeObjectForKey:key];
        }
    }
}

@end
