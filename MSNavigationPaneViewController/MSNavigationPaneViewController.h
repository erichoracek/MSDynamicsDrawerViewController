//
//  MSNavigationPaneViewController.h
//  MSNavigationPaneViewController
//
//  Created by Eric Horacek on 9/4/12.
//  Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.
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

// Sizes
extern const CGFloat MSNavigationPaneDefaultOpenStateRevealWidthLeft;
extern const CGFloat MSNavigationPaneDefaultOpenStateRevealWidthRight;
extern const CGFloat MSNavigationPaneDefaultOpenStateRevealWidthTop;

typedef NS_ENUM(NSUInteger, MSNavigationPaneOpenDirection) {
    MSNavigationPaneOpenDirectionLeft,
    MSNavigationPaneOpenDirectionTop,
};

typedef NS_ENUM(NSUInteger, MSNavigationPaneState) {
    MSNavigationPaneStateOpen,
    MSNavigationPaneStateClosed,
};

typedef NS_ENUM(NSUInteger, MSNavigationPaneAppearanceType) {
    MSNavigationPaneAppearanceTypeNone,
    MSNavigationPaneAppearanceTypeZoom,
    MSNavigationPaneAppearanceTypeParallax,
    MSNavigationPaneAppearanceTypeFade,
};

@protocol MSNavigationPaneViewControllerDelegate;

@interface MSNavigationPaneViewController : UIViewController

@property (nonatomic, assign) id<MSNavigationPaneViewControllerDelegate> delegate;

@property (nonatomic, assign) MSNavigationPaneOpenDirection openDirection;
@property (nonatomic, assign) MSNavigationPaneState paneState;
@property (nonatomic, assign) MSNavigationPaneAppearanceType appearanceType;

@property (nonatomic, strong) UIViewController *paneViewController;
@property (nonatomic, strong) UIViewController *masterViewController;

@property (nonatomic, readonly) UIView *masterView;
@property (nonatomic, readonly) UIView *paneView;

// The width that the pane should open to reveal the master
@property (nonatomic, assign) CGFloat openStateRevealWidth;

// If a pan gesture on the pane view should slide the pane view
@property (nonatomic, assign) BOOL paneDraggingEnabled;

// If setting a new pane view controller should cause an animation that slides off the old view controller before animating the new one back on
@property (nonatomic, assign) BOOL paneViewSlideOffAnimationEnabled;

// Classes that the pane view should forward dragging through to (UISlider, UISwitch by default)
@property (nonatomic, readonly) NSMutableSet *touchForwardingClasses;

- (void)setPaneViewController:(UIViewController *)paneViewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)setPaneState:(MSNavigationPaneState)paneState animated:(BOOL)animated completion:(void (^)(void))completion;

@end

@protocol MSNavigationPaneViewControllerDelegate <NSObject>

@optional

- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController willAnimateToPane:(UIViewController *)paneViewController;
- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didAnimateToPane:(UIViewController *)paneViewController;
- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController didUpdateToPaneState:(MSNavigationPaneState)state;
- (void)navigationPaneViewController:(MSNavigationPaneViewController *)navigationPaneViewController willUpdateToPaneState:(MSNavigationPaneState)state;

@end
