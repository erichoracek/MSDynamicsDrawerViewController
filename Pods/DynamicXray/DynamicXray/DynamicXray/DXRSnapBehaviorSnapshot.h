//
//  DXRSnapBehaviorSnapshot.h
//  DynamicXray
//
//  Created by Chris Miles on 17/01/2014.
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

@interface DXRSnapBehaviorSnapshot : DXRBehaviorSnapshot

- (id)initWithAnchorPoint:(CGPoint)anchorPoint itemCenter:(CGPoint)itemCenter itemBounds:(CGRect)itemBounds itemTransform:(CGAffineTransform)itemTransform;

@property (assign, nonatomic, readonly) CGPoint anchorPoint;
@property (assign, nonatomic, readonly) CGPoint itemCenter;
@property (assign, nonatomic, readonly) CGRect itemBounds;
@property (assign, nonatomic, readonly) CGAffineTransform itemTransform;

@end
