//
//  DXRDynamicXrayItemSnapshot.m
//  DynamicXray
//
//  Created by Chris Miles on 7/11/2013.
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

#import "DXRDynamicXrayItemSnapshot.h"

@interface DXRDynamicXrayItemSnapshot ()

@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic, readwrite) CGRect bounds;
@property (nonatomic, readwrite) CGAffineTransform transform;
@property (nonatomic, readwrite) BOOL isContacted;

@end


@implementation DXRDynamicXrayItemSnapshot

+ (instancetype)snapshotWithBounds:(CGRect)bounds center:(CGPoint)center transform:(CGAffineTransform)transform contacted:(BOOL)isContacted
{
    DXRDynamicXrayItemSnapshot *snapshot = [[self alloc] init];
    snapshot.center = center;
    snapshot.bounds = bounds;
    snapshot.transform = transform;
    snapshot.isContacted = isContacted;

    return snapshot;
}

@end
