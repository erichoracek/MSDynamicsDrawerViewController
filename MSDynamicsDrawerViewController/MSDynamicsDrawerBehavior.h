//
//  MSDynamicsDrawerBehavior.h
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 5/3/14.
//  Copyright (c) 2014 Monospace Ltd. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MSDynamicsDrawerViewController.h"

/**
 The root behavior used to position the pane within a MSDynamicsDrawerViewController. All behaviors that wish to position the pane should inherit from this behavior.
 
 The included implementations of pane positioning behaviors that descend from this class are MSPaneGravityBehavior and MSPaneSnapBehavior.
 */
@interface MSPaneBehavior : UIDynamicBehavior

/**
 Initializes a pane positioning behavior with a drawer view controller.
 
 @param drawerViewController The drawer view controller whose pane you want to be subject to the positioning behavior.
 
 @return The initialized pane positioning behavior, or nil if there was a problem initializing the object.
 */
- (instancetype)initWithDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController;

/**
 The drawer view controller whose pane is positioned by this behavior.
 */
@property (nonatomic, weak, readonly) MSDynamicsDrawerViewController *drawerViewController;

/**
 The pane dynamic item that this behavior is used to position.
 */
@property (nonatomic, weak, readonly) id <UIDynamicItem> paneItem;

/**
 The behavior that is used to configure the behavior of the paneItem.
 
 This behavior's properties can be modified to create different effects when positioning the pane. It is created and associated with the behavior's paneItem on initialization.
 
 @see paneItem
 */
@property (nonatomic, strong, readonly) UIDynamicItemBehavior *paneBehavior;

@end

/**
 Behaviors that wish to be used to position a MSDynamicDrawerViewController's pane should conform to this protocol.
 */
@protocol MSPanePositioningBehavior <NSObject>

/**
 The state that the behavior is attempting to position the pane in.
 
 @see positionPaneInState:forDirection:
 */
@property (nonatomic, assign, readonly) MSDynamicsDrawerPaneState targetPaneState;

/**
 The direction that the behavior is attempting to position the pane in.
 
 @see positionPaneInState:forDirection:
 */
@property (nonatomic, assign, readonly) MSDynamicsDrawerDirection targetDirection;

/**
 Positions the pane dynamic item in the desired direction with the specified state. This method is only invoked internally by the associated MSDynamicsDrawerViewController. It should not be invoked otherwise. When subclassing MSPanePositioningBehavior, this method should be overridden to adjust child behaviors to create the desired effect.
 
 @param paneState The state that the pane should be positioned in. Represented as targetPaneState after this method is invoked and until this behavior is removed from its dynamic animator.
 @param direction The direction that the pane should be positioned in. Represented as targetDirection after this method is invoked and until this behavior is removed from its dynamic animator.
 
 @see targetPaneState
 @see targetDirection
 */
- (void)positionPaneInState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;

@end

/**
 Behaviors that wish to be used to bounce a MSDynamicDrawerViewController's pane open should conform to this protocol.
 */
@protocol MSPaneBounceBehavior <NSObject>

/**
 Bounces the pane dynamic item open in the desired direction from the closed position.
 
 The pane is expected to end the bounce in the closed state.
 
 @param direction The direction that the pane dynamic item should open in.
 */
- (void)bouncePaneOpenInDirection:(MSDynamicsDrawerDirection)direction;

@end

/**
 Uses a gravity effect to move the pane.
 
 When the pane arrives at its new state, it bounces against a boundary until it reaches a resting position. Internally, MSDynamicsDrawerGravityBehavior uses UIGravityBehavior and UICollisionBehavior child behaviors to position the pane. When bouncing the pane open, it uses a UIPushBehavior.
 */
@interface MSPaneGravityBehavior : MSPaneBehavior <MSPanePositioningBehavior, MSPaneBounceBehavior>

/**
 The child behavior that is used to create the gravity effect on the pane.
 
 Magnitude is the only property that should be modified on this behavior to change the positioning effect when using this behavior. This behavior's behavior is undefined if other properties are modified.
 */
@property (nonatomic, strong, readonly) UIGravityBehavior *gravity;

/**
 The child behavior that is used to bounce the pane when it is used as a MSPaneBounceBehavior.
 
 Magnitude is the only property that should be modified on this behavior to change the bounce effect when using this behavior. This behavior's behavior is undefined if other properties are modified.
 */
@property (nonatomic, strong, readonly) UIPushBehavior *bouncePush;

@end

/**
 Uses a snap effect to move the pane.
 */
@interface MSPaneSnapBehavior : MSPaneBehavior <MSPanePositioningBehavior>

/**
 The frequency of the snap animation.
 
 Default value of 3.0.
 */
@property (nonatomic, assign) CGFloat frequency;

/**
 The damping of the snap animation when the pane is thrown.
 
 Default value of 0.55. This is a best approximation for the spring damping that Apple uses for scroll views (0.55). See https://twitter.com/chpwn/status/291794740553338880
 */
@property (nonatomic, assign) CGFloat throwDamping;

/**
 The velocity threshold at which the snap behavior uses the throw damping when positioning the pane is a target position.
 
 Expressed in points per second. Default value of 500.0.
 */
@property (nonatomic, assign) CGFloat throwVelocityThreshold;

@end
