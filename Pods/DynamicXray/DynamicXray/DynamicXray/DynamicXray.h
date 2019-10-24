//
//  DynamicXray
//
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

/*
    DynamicXray
    ===========

    DynamicXray is a UIKit Dynamics runtime visualisation and introspection library.

    Ever wanted to see under the hood of the UIKit Dynamics physics engine?
    Now you can! With DynamicXray you can visualise your dynamic animator live at
    runtime, exposing all dynamic behaviours and dynamic items.


    Quick Start
    ===========

    Open DynamicXray.xcworkspace, select the Framework scheme, build the framework.

    Add DynamicXray.framework to your iOS project.

    In your code, import the header and add an instance of DynamicXray to your dynamic animator.

        #import <DynamicXray/DynamicXray.h>
        ...
        DynamicXray *xray = [[DynamicXray alloc] init];
        [self.dynamicAnimator addBehavior:xray];


    Overview
    ========

    DynamicXray is built as a UIDynamicBehavior. This means it can be simply added to any
    UIDynamicAnimator to enable the introspection overlay. By default, all behaviours added
    to the animator will be visualised.

    For more control, the DynamicXray behaviour exposes options such as temporarily disabling
    the overlay, adjusting the cross fade between app and overlay, whether to draw dynamic
    item outlines, and more. Refer to the DynamicXray header.

    DynamicXray includes a built-in configuration panel that slides up from the bottom of the
    screen. The configuration panel provides access to some options at runtime. The configuration
    panel can be presented by calling -presentConfigurationViewController.

    For example:

        DynamicXray *xray = [[DynamicXray alloc] init];
        [self.dynamicAnimator addBehavior:xray];
        [xray presentConfigurationViewController];

 */


@import UIKit;

extern NSString *const DynamicXrayVersion;


/** DynamicXray provides real time UIKit Dynamics introspection and visualisation.
 
    DynamicXray is a UIDynamicBehavior. Add an instance of DynamicXray to
    a UIDynamicAnimator to enable the introspection overlay.
 */
@interface DynamicXray : UIDynamicBehavior

/** Toggles whether DynamicXray is active.
 
    Set to NO to temporarily disable overlay drawing.
 */
@property (assign, nonatomic, getter = isActive) BOOL active;

@end


@interface DynamicXray (XrayUserInterface)

/** Present the DynamicXray configuration panel.
 
    The configuration panel allows for options to be changed at
    run-time.
 */
- (void)presentConfigurationViewController;

@end


@interface DynamicXray (XrayVisualStyle)

/** Controls the opacity of both the Xray overlay and the application windows.
 
    CrossFade takes a value between -1.0 and 1.0. Negative values specify the
    level of transparency of the Xray overlay window. Positive values specify
    the level of transparency of the app window.

    At -1.0, the app window is visible while the Xray overlay window is not.
    At 1.0, the Xray overlay window is visible while the app window is not.
    At 0, both the app window and the XRay overlay windows are fully visible.

    * -1.0: App window opacity: 1.0; Xray overlay window opacity: 0
    *    0: App window opacity: 1.0; Xray overlay window opacity: 1.0
    *  1.0: App window opacity:   0; Xray overlay window opacity: 1.0
 */
@property (assign, nonatomic) CGFloat crossFade;


/** Offset the Xray view drawing.
 
    Specify an offset to adjust the position of the Xray overlay drawing.
 */
@property (assign, nonatomic) UIOffset viewOffset;


/** Toggles whether dynamic items in the scene are drawn.
 
    If set to NO, dynamic items are not drawn (behaviours will
    still be drawn).
 
    Defaults to YES.
 */
@property (assign, nonatomic) BOOL drawDynamicItemsEnabled;


/** Toggles whether antialiasing is allowed when drawing.
 
    Set to NO to improve drawing performance.
 
    Defaults to YES.
 */
@property (assign, nonatomic) BOOL allowsAntialiasing;

@end
