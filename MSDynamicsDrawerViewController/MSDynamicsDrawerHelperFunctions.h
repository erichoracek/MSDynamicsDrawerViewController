//
//  MSDynamicsDrawerHelperFunctions.h
//  Docs
//
//  Created by Eric Horacek on 7/6/14.
//  Copyright (c) 2014 Monospace Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDynamicsDrawerViewController.h"

/**
 The action block used in MSDynamicsDrawerDirectionActionForMaskedValues.
 */
typedef void (^MSDynamicsDrawerActionBlock)(MSDynamicsDrawerDirection maskedDirection);

/**
 Performs an action on all values within a `MSDynamicsDrawerDirection` direction bitmask.
 
 @param drawerDirection The direction bitmask.
 @param action The action block that should be performed on each of the directions contained within the direction bitmask.
 
 @see MSDynamicsDrawerActionBlock
 */
void MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirection direction, MSDynamicsDrawerActionBlock action);

/**
 Returns YES if the specified direction is one of the cardinal directions (top, left, bottom, right).
 
 @param drawerDirection The direction that should be evaluated.
 
 @return Whether the direction is one of the cardinal directions.
 */
BOOL MSDynamicsDrawerDirectionIsCardinal(MSDynamicsDrawerDirection drawerDirection);

/**
 Returns YES if the specified direciton is a masked direction value.
 
 @param drawerDirection The direction that should be evaluated.
 
 @return Whether the direction is a masked value.
 */
BOOL MSDynamicsDrawerDirectionIsMasked(MSDynamicsDrawerDirection drawerDirection);

/**
 Returns a reference to the relevant point component (x or y) for a specified drawer direction.
 
 @param point           The point whose component should be returned
 @param drawerDirection The direction that the component should be returned for.
 
 @return A reference to the component of the point parameter that is relevant to the specified direction.
 */
CGFloat * const MSPointComponentForDrawerDirection(CGPoint * const point, MSDynamicsDrawerDirection drawerDirection);

/**
 Returns a reference to the relevant size component (width or height) for a specified drawer direction.
 
 @param size            The size whose component should be returned
 @param drawerDirection The direction that the component should be returned for.
 
 @return A reference to the component of the size parameter that is relevant to the specified direction.
 */
CGFloat * const MSSizeComponentForDrawerDirection(CGSize * const size, MSDynamicsDrawerDirection drawerDirection);

/**
 Returns YES if a drawer direction has a valid value.
 
 @param drawerDirection The drawer direction to check value validity on.
 
 @return Whether the drawer direction parameter is valid.
 */
BOOL MSDynamicsDrawerDirectionIsValid(MSDynamicsDrawerDirection drawerDirection);
