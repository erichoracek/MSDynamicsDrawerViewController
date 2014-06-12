//
//  DXRDynamicXrayView.h
//  DynamicXray
//
//  Created by Chris Miles on 4/08/13.
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

@import UIKit;

@interface DXRDynamicXrayView : UIView

- (void)drawAttachmentFromAnchor:(CGPoint)anchorPoint toPoint:(CGPoint)attachmentPoint length:(CGFloat)length isSpring:(BOOL)isSpring;

- (void)drawCollisionBoundaryWithPath:(UIBezierPath *)path;

- (void)drawGravityBehaviorWithMagnitude:(CGFloat)magnitude angle:(CGFloat)angle;

- (void)drawContactPaths:(NSMapTable *)contactedPaths;

- (void)drawSnapWithAnchorPoint:(CGPoint)anchorPoint forItem:(id<UIDynamicItem>)item;

- (void)drawPushWithAngle:(CGFloat)angle magnitude:(CGFloat)magnitude transparency:(CGFloat)transparency atLocation:(CGPoint)pushLocation;

- (void)drawDynamicItems:(NSSet *)dynamicItems contactedItems:(NSMapTable *)contactedItems;


- (CGPoint)convertPoint:(CGPoint)point fromReferenceView:(UIView *)referenceView;
- (void)convertPath:(UIBezierPath *)path fromReferenceView:(UIView *)referenceView;


@property (assign, nonatomic) UIOffset drawOffset;

@property (assign, nonatomic) BOOL allowsAntialiasing;

@property (weak, nonatomic) UIView *dynamicsReferenceView;

@end
