//
//  DXRGravityBehaviorSnapshot.h
//  DynamicXray
//
//  Created by Chris Miles on 14/10/13.
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

#import "DXRBehaviorSnapshot.h"
@import CoreGraphics;

@interface DXRGravityBehaviorSnapshot : DXRBehaviorSnapshot

- (id)initWithGravityMagnitude:(CGFloat)magnitude angle:(CGFloat)angle;

@property (assign, nonatomic) CGFloat magnitude;
@property (assign, nonatomic) CGFloat angle;

@end
