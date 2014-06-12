//
//  DynamicXray+XrayVisualiseBehaviors.h
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

@interface DynamicXray (XrayVisualiseBehaviors)

- (void)visualiseAttachmentBehavior:(UIAttachmentBehavior *)attachmentBehavior;

- (void)visualiseCollisionBehavior:(UICollisionBehavior *)collisionBehavior;

- (void)visualiseGravityBehavior:(UIGravityBehavior *)gravityBehavior;

- (void)visualiseSnapBehavior:(UISnapBehavior *)snapBehavior;

- (void)visualisePushBehavior:(UIPushBehavior *)pushBehavior;
- (void)visualisePushBehavior:(UIPushBehavior *)pushBehavior withTransparency:(CGFloat)transparency;
- (void)visualiseInstantaneousPushBehavior:(UIPushBehavior *)pushBehavior atLocations:(NSArray *)pushLocations withTransparency:(CGFloat)transparency;

@end
