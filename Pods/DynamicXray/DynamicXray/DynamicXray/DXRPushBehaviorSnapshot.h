//
//  DXRPushBehaviorSnapshot.h
//  DynamicXray
//
//  Created by Chris Miles on 21/01/2014.
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

#import "DXRBehaviorSnapshot.h"
@import UIKit;


@interface DXRPushBehaviorSnapshot : DXRBehaviorSnapshot

- (id)initWithAngle:(CGFloat)angle magnitude:(CGFloat)magnitude location:(CGPoint)pushLocation;

@property (assign, nonatomic, readonly) CGFloat angle;
@property (assign, nonatomic, readonly) CGFloat magnitude;
@property (assign, nonatomic, readonly) CGPoint pushLocation;

@end
