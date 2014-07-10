//
//  MSDynamcsDrawerHelperFunctions.c
//  Docs
//
//  Created by Eric Horacek on 7/6/14.
//  Copyright (c) 2014 Monospace Ltd. All rights reserved.
//

#import "MSDynamicsDrawerHelperFunctions.h"

BOOL __attribute__((const)) MSDynamicsDrawerDirectionIsMasked(MSDynamicsDrawerDirection drawerDirection)
{
    // Check if a single bit is set or if there's no bits set via http://aggregate.org/MAGIC/#Is%20Power%20of%202
    return (drawerDirection & (drawerDirection - 1));
}

BOOL __attribute__((const)) MSDynamicsDrawerDirectionIsCardinal(MSDynamicsDrawerDirection drawerDirection)
{
    return (!MSDynamicsDrawerDirectionIsMasked(drawerDirection) && (drawerDirection != MSDynamicsDrawerDirectionNone));
}

BOOL __attribute__((const)) MSDynamicsDrawerDirectionIsValid(MSDynamicsDrawerDirection drawerDirection)
{
    return (drawerDirection <= MSDynamicsDrawerDirectionAll);
}

CGFloat * const MSPointComponentForDrawerDirection(CGPoint * const point, MSDynamicsDrawerDirection drawerDirection)
{
    if (drawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        return &(point->x);
    }
    if (drawerDirection & MSDynamicsDrawerDirectionVertical) {
        return &(point->y);
    }
    return NULL;
}

CGFloat * const MSSizeComponentForDrawerDirection(CGSize * const size, MSDynamicsDrawerDirection drawerDirection)
{
    if (drawerDirection & MSDynamicsDrawerDirectionHorizontal) {
        return &(size->width);
    }
    if (drawerDirection & MSDynamicsDrawerDirectionVertical) {
        return &(size->height);
    }
    return NULL;
}

void MSDynamicsDrawerDirectionActionForMaskedValues(NSInteger direction, MSDynamicsDrawerActionBlock action)
{
    for (MSDynamicsDrawerDirection currentDirection = MSDynamicsDrawerDirectionTop; currentDirection <= MSDynamicsDrawerDirectionRight; currentDirection <<= 1) {
        if (currentDirection & direction) {
            action(currentDirection);
        }
    }
}
