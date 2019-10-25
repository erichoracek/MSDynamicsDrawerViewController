//
//  DynamicXray+XrayVisualiseBehaviors.m
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

#import "DynamicXray+XrayVisualiseBehaviors.h"
#import "DynamicXray_Internal.h"

#import "DXRDynamicXrayView.h"


@implementation DynamicXray (XrayVisualiseBehaviors)

#pragma mark - Attachment Behavior

- (void)visualiseAttachmentBehavior:(UIAttachmentBehavior *)attachmentBehavior
{
    NSValue *anchorPointAValue = [attachmentBehavior valueForKey:@"anchorPointA"];

    CGPoint anchorPointA = CGPointZero;
    if (anchorPointAValue) anchorPointA = [anchorPointAValue CGPointValue];

    id<UIDynamicItem> itemA = nil;
    id<UIDynamicItem> itemB = nil;

    itemA = attachmentBehavior.items[0];

    if ([attachmentBehavior.items  count] > 1) {
        itemB = attachmentBehavior.items[1];
    }

    CGPoint anchorPoint, attachmentPoint;
    DXRDynamicXrayView *xrayView = [self xrayView];
    UIView *referenceView = self.referenceView;

    if (itemB) {
        // Item to Item

        CGPoint anchorPointB = CGPointZero;
        NSValue *anchorPointBValue = [attachmentBehavior valueForKey:@"anchorPointB"];
        if (anchorPointBValue) anchorPointB = [anchorPointBValue CGPointValue];

        anchorPoint = itemA.center;
        anchorPointA = CGPointApplyAffineTransform(anchorPointA, itemA.transform);
        anchorPoint.x += anchorPointA.x;
        anchorPoint.y += anchorPointA.y;
        anchorPoint = [xrayView convertPoint:anchorPoint fromReferenceView:referenceView];

        attachmentPoint = itemB.center;
        anchorPointB = CGPointApplyAffineTransform(anchorPointB, itemB.transform);
        attachmentPoint.x += anchorPointB.x;
        attachmentPoint.y += anchorPointB.y;
        attachmentPoint = [xrayView convertPoint:attachmentPoint fromReferenceView:referenceView];
    }
    else {
        // Anchor to Item

        anchorPoint = [xrayView convertPoint:attachmentBehavior.anchorPoint fromReferenceView:referenceView];

        attachmentPoint = itemA.center;
        anchorPointA = CGPointApplyAffineTransform(anchorPointA, itemA.transform);
        attachmentPoint.x += anchorPointA.x;
        attachmentPoint.y += anchorPointA.y;
        attachmentPoint = [xrayView convertPoint:attachmentPoint fromReferenceView:referenceView];
    }

    BOOL isSpring = (attachmentBehavior.frequency > 0.0);

    [xrayView drawAttachmentFromAnchor:anchorPoint toPoint:attachmentPoint length:attachmentBehavior.length isSpring:isSpring];

    [self.dynamicItemsToDraw addObjectsFromArray:attachmentBehavior.items];
}


#pragma mark - Collision Behavior

- (void)visualiseCollisionBehavior:(UICollisionBehavior *)collisionBehavior
{
    DXRDynamicXrayView *xrayView = [self xrayView];
    UIView *referenceView = collisionBehavior.dynamicAnimator.referenceView;
    CGRect referenceBoundaryFrame = referenceView.frame;

    if (collisionBehavior.translatesReferenceBoundsIntoBoundary) {
        CGRect boundaryRect = [[self xrayView] convertRect:referenceBoundaryFrame fromView:referenceView.superview];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:boundaryRect];
        [xrayView drawCollisionBoundaryWithPath:path];
    }

    for (id boundaryIdentifier in collisionBehavior.boundaryIdentifiers) {
        UIBezierPath *boundaryPath = [[collisionBehavior boundaryWithIdentifier:boundaryIdentifier] copy];
        [xrayView convertPath:boundaryPath fromReferenceView:referenceView];

        [xrayView drawCollisionBoundaryWithPath:boundaryPath];
    }

    [self.dynamicItemsToDraw addObjectsFromArray:collisionBehavior.items];
}


#pragma mark - Gravity Behavior

- (void)visualiseGravityBehavior:(UIGravityBehavior *)gravityBehavior
{
    [self.xrayView drawGravityBehaviorWithMagnitude:gravityBehavior.magnitude angle:gravityBehavior.angle];

    [self.dynamicItemsToDraw addObjectsFromArray:gravityBehavior.items];
}


#pragma mark - Snap Behavior

- (void)visualiseSnapBehavior:(UISnapBehavior *)snapBehavior
{
    NSArray *items = [snapBehavior valueForKey:@"_items"];
    if ([items count] > 0) {
        id<UIDynamicItem> item = items[0];
        NSValue *anchorPointValue = [snapBehavior valueForKey:@"_anchorPoint"];

        if (anchorPointValue) {
            CGPoint anchorPoint = [anchorPointValue CGPointValue];

            //CGPoint itemCenterPoint = item.center;
            //DLog(@"SNAP: (%f, %f) --> (%f, %f)  item: %@", itemCenterPoint.x, itemCenterPoint.y, anchorPoint.x, anchorPoint.y, item);

            [[self xrayView] drawSnapWithAnchorPoint:anchorPoint forItem:item];
        }

        [self.dynamicItemsToDraw addObjectsFromArray:items];
    }
}


#pragma mark - Push Behavior

- (void)visualisePushBehavior:(UIPushBehavior *)pushBehavior
{
    [self visualisePushBehavior:pushBehavior withTransparency:0];
}

- (void)visualisePushBehavior:(UIPushBehavior *)pushBehavior withTransparency:(CGFloat)transparency
{
    DXRDynamicXrayView *xrayView = [self xrayView];

    NSArray *items = pushBehavior.items;
    if ([items count] > 0) {

        for (id<UIDynamicItem> item in items) {
            if (pushBehavior.mode == UIPushBehaviorModeInstantaneous || pushBehavior.active) {
                CGPoint pushLocation = [xrayView convertPoint:item.center fromReferenceView:self.referenceView];

                UIOffset offset = [pushBehavior targetOffsetFromCenterForItem:item];
                pushLocation.x += offset.horizontal;
                pushLocation.y += offset.vertical;

                [xrayView drawPushWithAngle:pushBehavior.angle
                                  magnitude:pushBehavior.magnitude
                               transparency:transparency
                                 atLocation:pushLocation];
            }
        }

        [self.dynamicItemsToDraw addObjectsFromArray:items];
    }
}

- (void)visualiseInstantaneousPushBehavior:(UIPushBehavior *)pushBehavior atLocations:(NSArray *)pushLocations withTransparency:(CGFloat)transparency
{
    DXRDynamicXrayView *xrayView = [self xrayView];

    for (NSValue *value in pushLocations) {
        CGPoint pushLocation = [xrayView convertPoint:[value CGPointValue] fromReferenceView:self.referenceView];

        [xrayView drawPushWithAngle:pushBehavior.angle
                          magnitude:pushBehavior.magnitude
                       transparency:transparency
                         atLocation:pushLocation];
    }

    [self.dynamicItemsToDraw addObjectsFromArray:pushBehavior.items];
}

@end
