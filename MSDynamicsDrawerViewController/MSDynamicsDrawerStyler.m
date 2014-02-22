//
//  MSDynamicsDrawerStyler.m
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 10/19/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
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

#import "MSDynamicsDrawerStyler.h"

@implementation MSDynamicsDrawerParallaxStyler

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.parallaxOffsetFraction = 0.35;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyler

+ (instancetype)styler
{
    return [self new];
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    CGFloat paneRevealWidth = [dynamicsDrawerViewController revealWidthForDirection:direction];
    CGFloat translate = ((paneRevealWidth * paneClosedFraction) * self.parallaxOffsetFraction);
    if (direction & (MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft)) {
        translate = -translate;
    }
    CGAffineTransform drawerViewTransform = dynamicsDrawerViewController.drawerView.transform;
    if (direction & MSDynamicsDrawerDirectionHorizontal) {
        drawerViewTransform.tx = CGAffineTransformMakeTranslation(translate, 0.0).tx;
    } else if (direction & MSDynamicsDrawerDirectionVertical) {
        drawerViewTransform.ty = CGAffineTransformMakeTranslation(0.0, translate).ty;
    } else {
        CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(0.0, 0.0);
        drawerViewTransform.tx = translateTransform.tx;
        drawerViewTransform.ty = translateTransform.ty;
    }
    dynamicsDrawerViewController.drawerView.transform = drawerViewTransform;
}

- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 0.0);
    CGAffineTransform drawerViewTransform = dynamicsDrawerViewController.drawerView.transform;
    drawerViewTransform.tx = translate.tx;
    drawerViewTransform.ty = translate.ty;
    dynamicsDrawerViewController.drawerView.transform = drawerViewTransform;
}

@end

@implementation MSDynamicsDrawerFadeStyler

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.closedAlpha = 0.0;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyler

+ (instancetype)styler
{
    return [self new];
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    if (direction & MSDynamicsDrawerDirectionAll) {
        dynamicsDrawerViewController.drawerView.alpha = ((1.0 - self.closedAlpha) * (1.0  - paneClosedFraction));
    } else {
        dynamicsDrawerViewController.drawerView.alpha = 1.0;
    }
}

- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    dynamicsDrawerViewController.drawerView.alpha = 1.0;
}

@end

@implementation MSDynamicsDrawerScaleStyler

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.closedScale = 0.1;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyler

+ (instancetype)styler
{
    return [self new];
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    CGFloat scale;
    if (direction & MSDynamicsDrawerDirectionAll) {
        scale = (1.0 - (paneClosedFraction * self.closedScale));
    } else {
        scale = 1.0;
    }
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform drawerViewTransform = dynamicsDrawerViewController.drawerView.transform;
    drawerViewTransform.a = scaleTransform.a;
    drawerViewTransform.d = scaleTransform.d;
    dynamicsDrawerViewController.drawerView.transform = drawerViewTransform;
}

- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1.0, 1.0);
    CGAffineTransform drawerViewTransform = dynamicsDrawerViewController.drawerView.transform;
    drawerViewTransform.a = scaleTransform.a;
    drawerViewTransform.d = scaleTransform.d;
    dynamicsDrawerViewController.drawerView.transform = drawerViewTransform;
}

@end

@interface MSDynamicsDrawerResizeStyler ()

@property (nonatomic, assign) BOOL useRevealWidthAsMinimumResizeRevealWidth;

@end

@implementation MSDynamicsDrawerResizeStyler

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.useRevealWidthAsMinimumResizeRevealWidth = YES;
    }
    return self;
}

#pragma mark - MSDynamicsDrawerStyler

+ (instancetype)styler
{
    return [self new];
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
    if (direction == MSDynamicsDrawerDirectionNone) {
        return;
    }
    
    CGRect drawerViewFrame = [[dynamicsDrawerViewController drawerViewControllerForDirection:direction] view].frame;
    
    CGFloat minimumResizeRevealWidth = (self.useRevealWidthAsMinimumResizeRevealWidth ? [dynamicsDrawerViewController revealWidthForDirection:direction] : self.minimumResizeRevealWidth);
    if (dynamicsDrawerViewController.currentRevealWidth < minimumResizeRevealWidth) {
        drawerViewFrame.size.width = [dynamicsDrawerViewController revealWidthForDirection:direction];
    } else {
        if (direction & MSDynamicsDrawerDirectionHorizontal) {
            drawerViewFrame.size.width = dynamicsDrawerViewController.currentRevealWidth;
        } else if (direction & MSDynamicsDrawerDirectionVertical) {
            drawerViewFrame.size.height = dynamicsDrawerViewController.currentRevealWidth;
        }
    }
    
    CGRect paneViewFrame = dynamicsDrawerViewController.paneView.frame;
    switch (direction) {
        case MSDynamicsDrawerDirectionRight:
            drawerViewFrame.origin.x = CGRectGetMaxX(paneViewFrame);
            break;
        case MSDynamicsDrawerDirectionBottom:
            drawerViewFrame.origin.x = CGRectGetMaxY(paneViewFrame);
            break;
        default:
            break;
    }
    
    [[dynamicsDrawerViewController drawerViewControllerForDirection:direction] view].frame = drawerViewFrame;
}

- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
    // Reset the drawer view controller's view to be the size of the drawerView (before the styler was added)
    CGRect drawerViewFrame = [[dynamicsDrawerViewController drawerViewControllerForDirection:direction] view].frame;
    drawerViewFrame.size = dynamicsDrawerViewController.drawerView.frame.size;
    [[dynamicsDrawerViewController drawerViewControllerForDirection:direction] view].frame = drawerViewFrame;
}

#pragma mark - MSDynamicsDrawerResizeStyler

- (void)setMinimumResizeRevealWidth:(CGFloat)minimumResizeRevealWidth
{
    self.useRevealWidthAsMinimumResizeRevealWidth = NO;
    _minimumResizeRevealWidth = minimumResizeRevealWidth;
}

@end

@interface MSDynamicsDrawerShadowStyler ()

@property (nonatomic, strong) CALayer *shadowLayer;

@end

@implementation MSDynamicsDrawerShadowStyler

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (self) {
		self.shadowColor = [UIColor blackColor];
        self.shadowRadius = 10.0;
		self.shadowOpacity = 1.0;
        self.shadowOffset = CGSizeZero;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)notification
{
    [self.shadowLayer removeFromSuperlayer];
}

#pragma mark - MSDynamicsDrawerStyler

+ (instancetype)styler
{
    return [self new];
}

- (void)stylerWasAddedToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
	self.shadowLayer = [CALayer layer];
	self.shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:dynamicsDrawerViewController.paneView.frame] CGPath];
    self.shadowLayer.shadowColor = self.shadowColor.CGColor;
    self.shadowLayer.shadowOpacity = self.shadowOpacity;
    self.shadowLayer.shadowRadius = self.shadowRadius;
    self.shadowLayer.shadowOffset = self.shadowOffset;
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{    
    if (direction & MSDynamicsDrawerDirectionAll) {
        if (!self.shadowLayer.superlayer) {
            CGRect shadowRect = (CGRect){CGPointZero, dynamicsDrawerViewController.paneView.frame.size};
            if (direction & MSDynamicsDrawerDirectionHorizontal) {
                shadowRect = CGRectInset(shadowRect, 0.0, -self.shadowRadius);
            } else if (direction & MSDynamicsDrawerDirectionVertical) {
                shadowRect = CGRectInset(shadowRect, -self.shadowRadius, 0.0);
            }
            self.shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:shadowRect] CGPath];
            [dynamicsDrawerViewController.paneView.layer insertSublayer:self.shadowLayer atIndex:0];
        }
    } else {
        [self.shadowLayer removeFromSuperlayer];
    }
}

- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
	[self.shadowLayer removeFromSuperlayer];
    self.shadowLayer = nil;
}

#pragma mark - MSDynamicsDrawerShadowStyler

- (void)setShadowColor:(UIColor *)shadowColor
{
    if (_shadowColor != shadowColor) {
        _shadowColor = shadowColor;
        self.shadowLayer.shadowColor = [shadowColor CGColor];
    }
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity
{
    if (_shadowOpacity != shadowOpacity) {
        _shadowOpacity = shadowOpacity;
        self.shadowLayer.shadowOpacity = shadowOpacity;
    }
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    if (_shadowRadius != shadowRadius) {
        _shadowRadius = shadowRadius;
        self.shadowLayer.shadowRadius = shadowRadius;
    }
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
    if (!CGSizeEqualToSize(_shadowOffset, shadowOffset)) {
        _shadowOffset = shadowOffset;
        self.shadowLayer.shadowOffset = shadowOffset;
    }
}

@end
