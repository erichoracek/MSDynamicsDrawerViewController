//
//  MSDraggableView.m
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 9/4/12.
//  Copyright (c) 2012 Monospace Ltd. All rights reserved.
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

#import "MSDraggableView.h"
#import "MSNavigationPaneViewController.h"
#import <QuartzCore/QuartzCore.h>

const CGFloat MSDraggableViewXYMinimumThreshold = 5.0;
const CGFloat MSDraggableViewXVelocityThreshold = 8.0;
const CGFloat MSDraggableViewXVelocitySlide = 15.0;

typedef void (^ViewActionBlock)(UIView *view);

@interface UIView (ViewHierarchyAction)

- (void)superviewHierarchyAction:(ViewActionBlock)viewAction;

@end

@implementation UIView (ViewHierarchyAction)

- (void)superviewHierarchyAction:(ViewActionBlock)viewAction
{
    viewAction(self);
    [self.superview superviewHierarchyAction:viewAction];
}

@end

@interface MSDraggableView() <UIGestureRecognizerDelegate> {
    
    MSDraggableViewState _state;
}

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) CGPoint startLocation;
@property (nonatomic, assign) CGPoint startLocationInSuperview;
@property (nonatomic, assign) CGFloat xVelocity;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

- (void)setSubviewUserInteractionEnabled:(BOOL)interactionEnabled;

- (void)tapped:(UIPanGestureRecognizer *)gesureRecognizer;
- (void)panned:(UITapGestureRecognizer *)gesureRecognizer;

- (void)bounceToCompletionWithDuration:(CGFloat)duration velocty:(CGFloat)velocity;
- (void)bounceBackWithDuration:(CGFloat)duration velocty:(CGFloat)velocity;
- (void)slideToCompletionWithDuration:(CGFloat)duration;
- (void)slideBackWithDuration:(CGFloat)duration;

@end

@implementation MSDraggableView

@dynamic state;

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		self.backgroundColor = [UIColor clearColor];
        
        // Ensure that the shadow extends beyond the edges of the screen
        self.layer.shadowPath = [[UIBezierPath bezierPathWithRect:CGRectInset(frame, 0.0, -40.0)] CGPath];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 1.0;
        self.layer.shadowRadius = 10.0;
        self.layer.masksToBounds = NO;
        
        self.animating = NO;
        self.xVelocity = 0.0;
        
        _touchForwardingClasses = [NSMutableSet setWithObjects:UISlider.class, UISwitch.class, nil];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        _panGestureRecognizer.minimumNumberOfTouches = 1;
        _panGestureRecognizer.maximumNumberOfTouches = 1;
        _panGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_panGestureRecognizer];
        
        // Start at the "closed" state
        self.state = MSDraggableViewStateClosed;
        
        // Start with dragging enabled
        self.draggingEnabled = YES;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGFloat fraction = ((MSNavigationPaneOpenStateMasterDisplayWidth - self.frame.origin.x) / MSNavigationPaneOpenStateMasterDisplayWidth);
    
    // Clip to 0.0 < fraction < 1.0
    fraction = (fraction < 0.0) ? 0.0 : fraction;
    fraction = (fraction > 1.0) ? 1.0 : fraction;
    
    if ([self.delegate respondsToSelector:@selector(draggableView:wasDraggedToFraction:)]) {
        [self.delegate draggableView:self wasDraggedToFraction:fraction];
    }
    if ([self.navigationPaneViewController respondsToSelector:@selector(draggableView:wasDraggedToFraction:)]) {
        [self.navigationPaneViewController draggableView:self wasDraggedToFraction:fraction];
    }
}

#pragma mark - MSDraggableView

- (void)tapped:(UIPanGestureRecognizer *)gestureRecognizer
{
    [self slideToCompletionWithDuration:MSNavigationPaneAnimationDurationOpenToClosed];
}

- (void)panned:(UIPanGestureRecognizer *)gestureRecognizer
{
    if (!self.draggingEnabled) {
        return;
    }
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            
            self.startLocation = [gestureRecognizer locationInView:self];
            self.xVelocity = 0.0;
            break;
            
        } case UIGestureRecognizerStateChanged: {
            
            if (!self.animating) {
                
                CGPoint locationInSelf = [gestureRecognizer locationInView:self];
                self.xVelocity = self.startLocation.x - locationInSelf.x;
                
                CGRect newFrame = self.frame;
                newFrame.origin.x += (locationInSelf.x - self.startLocation.x);
                
                if ((newFrame.origin.x > 0.0) && (newFrame.origin.x < MSNavigationPaneOpenStateMasterDisplayWidth)) {
                    self.frame = newFrame;
                }
            }
            break;
            
        } case UIGestureRecognizerStateEnded: {
            
            CGFloat halfWay = (MSNavigationPaneOpenStateMasterDisplayWidth / 2.0);
            BOOL pastHalfWay = NO;
            if (self.state == MSDraggableViewStateClosed) {
                pastHalfWay = (self.frame.origin.x > halfWay);
            } else if (self.state == MSDraggableViewStateOpen) {
                pastHalfWay = (self.frame.origin.x < halfWay);
            }
            
            // We've reached the velocity threshold
            if (fabsf(_xVelocity) > MSDraggableViewXVelocityThreshold) {
                // Velocity is positive
                if (_xVelocity > 0) {
                    if (_state == MSDraggableViewStateOpen) {
                        [self bounceToCompletionWithDuration:MSNavigationPaneAnimationDurationSnap velocty:_xVelocity];
                    } else if (_state == MSDraggableViewStateClosed) {
                        if (self.frame.origin.x > 0.0) {
                            [self bounceBackWithDuration:MSNavigationPaneAnimationDurationSnap velocty:_xVelocity];
                        }
                    }
                }
                // Velocity is negative
                else if (_xVelocity < 0) {
                    if (_state == MSDraggableViewStateOpen) {
                        [self bounceBackWithDuration:MSNavigationPaneAnimationDurationSnap velocty:_xVelocity];
                    } else if (_state == MSDraggableViewStateClosed) {
                        [self bounceToCompletionWithDuration:MSNavigationPaneAnimationDurationSnap velocty:_xVelocity];
                    }
                }
            }
            // If we're released past half-way, snap to completion with no bounce
            else if (pastHalfWay) {
                [self bounceToCompletionWithDuration:MSNavigationPaneAnimationDurationSnap velocty:MSDraggableViewXVelocitySlide];
            }
            // Othwersie, snap to back to starting position with no bounce
            else {
                [self bounceBackWithDuration:MSNavigationPaneAnimationDurationSnap velocty:MSDraggableViewXVelocitySlide];
            }
            break;
            
        } default:
            break;
    }
}

- (MSDraggableViewState)state
{
    return _state;
}

- (void)setState:(MSDraggableViewState)aState
{
    _state = aState;
    if (_state == MSDraggableViewStateOpen) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        _tapGestureRecognizer.numberOfTouchesRequired = 1;
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:_tapGestureRecognizer];
    } else if (_state == MSDraggableViewStateClosed) {
        [self removeGestureRecognizer:self.tapGestureRecognizer];
    }
    
    [self setSubviewUserInteractionEnabled:(self.state == MSDraggableViewStateClosed)];
}

- (void)setSubviewUserInteractionEnabled:(BOOL)interactionEnabled
{
    for (UIView *subview in self.subviews) {
        subview.userInteractionEnabled = interactionEnabled;
    }
}

- (void)bounceToCompletionWithDuration:(CGFloat)duration velocty:(CGFloat)velocity;
{
    CGFloat xLocation = ((self.state == MSDraggableViewStateClosed) ? MSNavigationPaneOpenStateMasterDisplayWidth : 0.0);
    CGFloat velocityOvershot = sqrtf(fabsf(velocity * 1.5));
    xLocation = ((self.state == MSDraggableViewStateClosed) ? (xLocation + velocityOvershot) : (xLocation - velocityOvershot));
    CGRect newFrame = self.frame;
    newFrame.origin.x = xLocation;
    
    // Bounce over the location, and then slide to completion
    _animating = YES;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.frame = newFrame;
                     } completion:^(BOOL finished) {
                         [self slideToCompletionWithDuration:MSNavigationPaneAnimationDurationSnapBack];
                     }];
}

- (void)bounceBackWithDuration:(CGFloat)duration velocty:(CGFloat)velocity;
{
    CGFloat xLocation = ((self.state == MSDraggableViewStateClosed) ? 0.0 : MSNavigationPaneOpenStateMasterDisplayWidth);
    CGFloat velocityOvershot = sqrtf(fabsf(velocity * 1.5));
    xLocation = ((self.state == MSDraggableViewStateClosed) ? (xLocation - velocityOvershot) : (xLocation + velocityOvershot));
    CGRect newFrame = self.frame;
    newFrame.origin.x = xLocation;
    
    // Bounce over the location, and then slide to completion
    _animating = YES;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.frame = newFrame;
                     } completion:^(BOOL finished) {
                         [self slideBackWithDuration:MSNavigationPaneAnimationDurationSnapBack];
                     }];
}

- (void)slideToCompletionWithDuration:(CGFloat)duration
{
    CGFloat xLocation = ((self.state == MSDraggableViewStateClosed) ? MSNavigationPaneOpenStateMasterDisplayWidth : 0.0);
    CGRect newFrame = self.frame;
    newFrame.origin.x = xLocation;
    
    _animating = YES;
    [UIView animateWithDuration:duration
                     animations:^{
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished) {
                         _animating = NO;
                         self.state = !self.state;
                         if ([self.delegate respondsToSelector:@selector(draggableView:wasDraggedToState:)]) {
                             [self.delegate draggableView:self wasDraggedToState:_state];
                         }
                         if ([self.navigationPaneViewController respondsToSelector:@selector(draggableView:wasDraggedToState:)]) {
                             [self.navigationPaneViewController draggableView:self wasDraggedToState:_state];
                         }
                     }];
}

- (void)slideBackWithDuration:(CGFloat)duration
{   
    CGFloat xLocation = ((self.state == MSDraggableViewStateClosed) ? 0.0 : MSNavigationPaneOpenStateMasterDisplayWidth);
    CGRect newFrame = self.frame;
    newFrame.origin.x = xLocation;
    
    _animating = YES;
    [UIView animateWithDuration:duration
                     animations:^{
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished) {
                         _animating = NO;
                     }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!self.draggingEnabled) {
        return NO;
    }
    
    // If the touch was in a touch forwarding view, don't handle the gesture
    __block BOOL shouldReceiveTouch = YES;
    
    // Enumerate the view's superviews, checking for a touch-forwarding class
    [touch.view superviewHierarchyAction:^(UIView *view) {
        // Only enumerate while still receiving the touch
        if (shouldReceiveTouch) {
            [self.touchForwardingClasses enumerateObjectsUsingBlock:^(Class touchForwardingClass, BOOL *stop) {
                if ([view isKindOfClass:touchForwardingClass]) {
                    shouldReceiveTouch = NO;
                    *stop = YES;
                }
            }];
        }
    }];
    
    return shouldReceiveTouch;
}

@end
