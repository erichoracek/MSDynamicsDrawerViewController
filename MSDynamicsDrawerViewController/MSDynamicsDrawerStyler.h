//
//  MSDynamicsDrawerStyler.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MSDynamicsDrawerViewController.h"

/**
 `MSDynamicsDrawerStyler` is a protocol that defines the interface for an object that can style a `MSDynamicsDrawerViewController`. Instances of `MSDynamicsDrawerStyler` are added to `MSDynamicsDrawerViewController` via the `addStyler:forDirection:` method.
 
 ## Creating a Custom Styler
 
 As user interacts with the instance of `MSDynamicsDrawerViewController`, the styler class is messaged via the method `dynamicsDrawerViewController:didUpdatePaneClosedFraction:forDirection:`, which allows the styler to changes attributes of the `drawerView` or `paneView` relative to the `paneClosedFraction`.
 
 It's recommended that custom stylers don't change the `frame` attribute of the `paneView` or the `drawerView` on the `MSDynamicsDrawerViewController` instance. These are constantly modified both by the user's gestures and the internal UIKit Dynamics within `MSDynamicsDrawerViewController`. The behavior of `MSDynamicsDrawerViewController` when the frame is externally modified is undefined.
 */
@protocol MSDynamicsDrawerStyler <NSObject>

/**
 Creates and returns a styler with default configuration.
 */
+ (instancetype)styler;

/**
 Invoked when the `MSDynamicsDrawerViewController` has an update to its pane closed fraction.
 
 @param dynamicsDrawerViewController The `MSDynamicsDrawerViewController` that is being styled by the `MSDynamicsDrawerStyler` instance.
 @param paneClosedFraction The fraction that `MSDynamicsDrawerViewController` instance's pane is closed. `1.0` when closed, `0.0` when opened.
 @param direction The direction that the `MSDynamicsDrawerViewController` instance is opening in. Will not be masked.
 */
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction;

@optional

/**
 Used to set up the appearance of the styler when it is added to a `MSDynamicsDrawerViewController` instance.
 
 @param dynamicsDrawerViewController The `MSDynamicsDrawerViewController` that is now being styled by the `MSDynamicsDrawerStyler` instance.
 @param direction The direction that the styler is being added for. Can be a masked value.
 */
- (void)stylerWasAddedToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Used to tear down the appearance of the styler when it is removed from a `MSDynamicsDrawerViewController` instance.
 
 @param dynamicsDrawerViewController The `MSDynamicsDrawerViewController` that was being styled by the `MSDynamicsDrawerStyler` instance.
 @param direction The direction that the styler is being removed for. Can be a masked value.
 */
- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController forDirection:(MSDynamicsDrawerDirection)direction;

- (void)stylerWasAddedToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController DEPRECATED_ATTRIBUTE;
- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController DEPRECATED_ATTRIBUTE;

@end

/**
 Creates a parallax effect on the `drawerView` while sliding the `paneView` within a `MSDynamicsDrawerViewController`.
 */
@interface MSDynamicsDrawerParallaxStyler : NSObject <MSDynamicsDrawerStyler>

/**
 The amount that the parallax should offset the `drawerView` when the `paneView` is closed, as a fraction of the visible reveal width.
 
 `0.35` by default.
 */
@property (nonatomic, assign) CGFloat parallaxOffsetFraction;

@end

/**
 Creates a fade effect on the `drawerView` while sliding the `paneView` within a `MSDynamicsDrawerViewController`.
 */
@interface MSDynamicsDrawerFadeStyler : NSObject <MSDynamicsDrawerStyler>

/**
 The amount that the `drawerView` is faded when the `paneView` is closed.
 
 The `drawerView` is faded from the `closedAlpha` when closed to 1.0 when open. `0.0` by default.
 */
@property (nonatomic, assign) CGFloat closedAlpha;

@end

/**
 Creates a zoom-in scaling effect on the `drawerView` while sliding the `paneView` within a `MSDynamicsDrawerViewController`.
 */
@interface MSDynamicsDrawerScaleStyler : NSObject <MSDynamicsDrawerStyler>

/**
 The amount that the `drawerView` is scaled when the `paneView` is closed. The `drawerView` is transformed from the `closedScale` when closed to 1.0 when open. `0.1` by default.
 */
@property (nonatomic, assign) CGFloat closedScale;

@end

/**
 Resizes the drawer view controller's view to fit within the visible space that a drawer is opened to as derived from the `currentRevealWidth` property.
 */
@interface MSDynamicsDrawerResizeStyler : NSObject <MSDynamicsDrawerStyler>

/**
 The minimum reveal width that the drawer view controller's view should be resized to equal the `currentRevealWidth` at.
 
 The default behavior is to use the `MSDynamicsDrawerViewController` instance's `revealWidthForDirection:` in the direction that the drawer is opened in as the value for the minimum resize reveal width. When set to a specific value, the drawer view controller's view is resized to fit the `currentRevealWidth` once the drawer is opened to the `minimumResizeRevealWidth`. If this value is set to `0`, then the drawer view controller's view will always be resized to fit within the visible area of the drawer.
 */
@property (nonatomic, assign) CGFloat minimumResizeRevealWidth;

@end

/**
 Adds a shadow to the `paneView` within a `MSDynamicsDrawerViewController` to create an effect of the `paneView` casting a shadow over the `drawerView`.
 */
@interface MSDynamicsDrawerShadowStyler : NSObject <MSDynamicsDrawerStyler>

/**
 The color of the shadow.
 
 Default value of `[UIColor blackColor]`.
 */
@property (nonatomic, strong) UIColor *shadowColor;

/**
 The blur radius (in points) used to render the shadow.
 
 Default value of `10.0`.
 */
@property (nonatomic, assign) CGFloat shadowRadius;

/**
 The opacity of the shadow.
 
 The value in this property must be in the range `0.0` (transparent) to `1.0` (opaque). The default value of this property is `1.0`.
 */
@property (nonatomic, assign) CGFloat shadowOpacity;

/**
 The offset (in points) of the layer’s shadow.
 
 The default value of this property is `(0.0, 0.0)`.
 */
@property (nonatomic, assign) CGSize shadowOffset;

@end
