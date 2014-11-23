//
//  MSDynamicsDrawerStyle.h
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
 `MSDynamicsDrawerStyle` is a protocol that defines the interface for an object that can style a `MSDynamicsDrawerViewController`. Instances of `MSDynamicsDrawerStyle` are added to `MSDynamicsDrawerViewController` via the `addStyle:forDirection:` or `addStyles:forDirection:` method.
 
 ## Creating a Custom Style
 
 As user interacts with the instance of `MSDynamicsDrawerViewController`, the style class is messaged via the method `dynamicsDrawerViewController:didUpdatePaneClosedFraction:forDirection:`, which allows the style to changes attributes of the `drawerView` or `paneView` relative to the paneClosedFraction.
 
 It's recommended that custom styles don't change the `frame` attribute of the `paneView` or the `drawerView` on the `MSDynamicsDrawerViewController` instance. These are constantly modified both by the user's gestures and the internal dynamic animator within `MSDynamicsDrawerViewController`. The behavior of `MSDynamicsDrawerViewController` when the frame is externally modified is undefined.
 */
@protocol MSDynamicsDrawerStyle <NSObject>

@optional

/**
 Invoked when the MSDynamicsDrawerViewController has an update to its pane closed fraction.
 
 @param dynamicsDrawerViewController The `MSDynamicsDrawerViewController` that is being styled by the `MSDynamicsDrawerStyle` instance.
 @param paneClosedFraction The fraction that `MSDynamicsDrawerViewController` instance's pane is closed. `1.0` when closed, `0.0` when opened.
 @param direction The direction that the `MSDynamicsDrawerViewController` instance is opening in. Will not be masked.
 */
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Informs the style that the drawer view controller did update to a pane state in the specified direction.
 
 @param drawerViewController The drawer view controller that the delegate is registered with.
 @param paneState The pane state that the view controller did update to.
 @param direction When the pane state is updating to `MSDynamicsDrawerPaneStateClosed`: the direction that the drawer view controller is transitioning from. When the pane state is updating to `MSDynamicsDrawerPaneStateOpen` or `MSDynamicsDrawerPaneStateOpenWide`: the direction that the drawer view controller is transitioning to.
 */
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Informs the style that the drawer view controller may update to a pane state in a specified direction.
 
 It is important to note that the user can interrupt this state change, and therefore is it not guaranteed that this update will occur..
 
 @param drawerViewController The drawer view controller that the delegate is registered with.
 @param paneState The pane state that the view controller may update to.
 @param direction The direction that the view controller may update in.
 */
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction;

/**
 Called just before the style is added or removed from a drawer view controller.
 
 @param dynamicsDrawerViewController The `MSDynamicsDrawerViewController` that is now being styled by the `MSDynamicsDrawerStyle` instance. Can be nil.
 @param direction The direction that the style is being added for. Can be a masked value.
 */
- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction;

@end

/**
 Creates a parallax effect on the `drawerView` while sliding the `paneView` within a `MSDynamicsDrawerViewController`.
 */
@interface MSDynamicsDrawerParallaxStyle : NSObject <MSDynamicsDrawerStyle>

/**
 The amount that the parallax should offset the `drawerView` when the `paneView` is closed, as a fraction of the visible reveal distance.
 
 `0.35` by default.
 */
@property (nonatomic) CGFloat parallaxOffsetFraction;

@end

/**
 Creates a fade effect on the `drawerView` while sliding the `paneView` within a `MSDynamicsDrawerViewController`.
 */
@interface MSDynamicsDrawerFadeStyle : NSObject <MSDynamicsDrawerStyle>

/**
 The amount that the `drawerView` is faded when the `paneView` is closed.
 
 The `drawerView` is faded from the `closedAlpha` when closed to 1.0 when open. `0.0` by default.
 */
@property (nonatomic) CGFloat closedAlpha;

@end

/**
 Creates a zoom-in scaling effect on the `drawerView` while sliding the `paneView` within a `MSDynamicsDrawerViewController`.
 */
@interface MSDynamicsDrawerScaleStyle : NSObject <MSDynamicsDrawerStyle>

/**
 The amount that the `drawerView` is scaled when the `paneView` is closed. The `drawerView` is transformed from the `closedScale` when closed to 1.0 when open. `0.1` by default.
 */
@property (nonatomic) CGFloat closedScale;

@end

/**
 Resizes the drawer view controller's view to fit within the visible space that a drawer is opened to as derived from the `currentRevealDistance` property.
 */
@interface MSDynamicsDrawerResizeStyle : NSObject <MSDynamicsDrawerStyle>

/**
 The minimum reveal distance that the drawer view controller's view should be resized to equal the `currentRevealDistance` at.
 
 The default behavior is to use the `MSDynamicsDrawerViewController` instance's reveal distance for the open state in the direction that the drawer is opened in as the value for the minimum resize reveal distance. When set to a specific value, the drawer view controller's view is resized to fit the `currentRevealDistance` once the drawer is opened to the `minimumResizeRevealDistance`. If this value is set to `0`, then the drawer view controller's view will always be resized to fit within the visible area of the drawer.
 */
@property (nonatomic) CGFloat minimumResizeRevealDistance;

/**
 The maxium reveal distance that the drawer view controller's view should be resized to equal the `currentRevealDistance` at.
 
 The default behavior is to use the `MSDynamicsDrawerViewController` instance's reveal distance for the open wide state in the direction that the drawer is opened in as the value for the minimum resize reveal distance. When set to a specific value, the drawer view controller's view is resized to fit the `currentRevealDistance` until the drawer is opened to the `maximumResizeRevealDistance`.
 */
@property (nonatomic) CGFloat maximumResizeRevealDistance;

@end

/**
 Adds a shadow to the `paneView` within a `MSDynamicsDrawerViewController` to create an effect of the `paneView` casting a shadow over the `drawerView`.
 */
@interface MSDynamicsDrawerShadowStyle : NSObject <MSDynamicsDrawerStyle>

/**
 The color of the shadow.
 
 Default value of `blackColor`.
 */
@property (nonatomic) UIColor *shadowColor;

/**
 The blur radius (in points) used to render the shadow.
 
 Default value of `10.0`.
 */
@property (nonatomic) CGFloat shadowRadius;

/**
 The opacity of the shadow.
 
 The value in this property must be in the range `0.0` (transparent) to `1.0` (opaque). The default value of this property is `1.0`.
 */
@property (nonatomic) CGFloat shadowOpacity;

/**
 The offset (in points) of the layer’s shadow.
 
 The default value of this property is `(0.0, 0.0)`.
 */
@property (nonatomic) CGSize shadowOffset;

@end

/**
 Horizontally adjusts the status bar relative to the offset of the pane view controller.
 
 This is accomplished by the following steps:
 - A snapshot view of the -[UIScreen snapshotViewAfterScreenUpdates:] is taken
 - This snapshot view is added as a subview to the -[MSDynamicsDrawerViewController paneView]
 - This snapshot view is masked to just display the -[UIApplication statusBarFrame]
 - The UIWindow instance that the -[MSDynamicsDrawerViewController view] instance is contained within is lifted to the -[UIWindow windowLevel] of (UIWindowLevelStatusBar + 1.0)
 - This snapshot is taken added whenever the pane is about to open, and removed when it closes
 
 When the in-call status bar is present, the above logic is not followed, and no status bar offset occurs.
 
 To manually invalidate the snapshot view, invoke invalidateStatusBarSnapshot on this style instance.
 */
@interface MSDynamicsDrawerStatusBarOffsetStyle : NSObject <MSDynamicsDrawerStyle>

/**
 Should be invoked when the status bar snapshot is stale, and should be regenerated when next possible.
 */
- (void)invalidateStatusBarSnapshot;

/**
 Whether this status bar offset style is "lifting" the window that its containing MSDynamicsDrawerViewController's view is in.
 
 The window is lifted to (UIWindowLevelStatusBar + 1.0) while the status bar snapshot is added to the corresponding MSDynamicsDrawerViewController instance's paneView. When the snapshot is removed, the pane is lowered again.
 */
@property (nonatomic, readonly, getter=isWindowLited) BOOL windowLifted;

@end

/**
 Whether the specified status bar frame would be offset by a MSDynamicsDrawerStatusBarOffsetStyle
 
 In the case of the in-call status bar being present, returns NO. Otherwise, returns YES.
 
 @param statusBarFrame Expecting the value from -[UIApplication statusBarFrame] or corresponding notifications.
 */
BOOL MSStatusBarOffsetStyleWillOffset(CGRect statusBarFrame);
