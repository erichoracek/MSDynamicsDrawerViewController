<img src="https://lh3.googleusercontent.com/-QtaTRcYLjro/U2xx_iY4GaI/AAAAAAAAAjQ/nHrsB6DfprI/s128/icon-website-128.png" height="32" />DynamicXray
===========

DynamicXray is a UIKit Dynamics runtime visualisation and introspection library for iOS.

Ever wanted to see under the hood of the UIKit Dynamics physics engine?
Now you can! With DynamicXray you can visualise your dynamic animator live at
runtime, exposing all dynamic behaviours and dynamic items.

The DynamicXray project includes a catalog of open source UIKit Dynamics demonstrations, all with DynamicXray already integrated. See <a href="#dynamicxraycatalog">DynamicXrayCatalog</a>.

<img src="https://lh4.googleusercontent.com/-dxUVFNprkmw/U2n8jHTS1jI/AAAAAAAAAiU/isgqsFLkv7g/s512/DynamicXrayUIKitPinball1.png" alt="DynamicXray + UIKit Pinball" height="480" />
<img src="https://lh3.googleusercontent.com/-YHqpnhXBKgE/U2n8u21qlQI/AAAAAAAAAic/X_Zm3_1CFMw/s512/DynamicXrayUIKitPinball2.png" alt="DynamicXray + UIKit Pinball" height="480" />
<img src="https://lh4.googleusercontent.com/-Ju24n7OG-14/U2n8xR5pvhI/AAAAAAAAAik/lRt_udRsD2U/s512/DynamicXrayUIKitPinball4.png" alt="DynamicXray + UIKit Pinball" height="480" />
<img src="https://lh5.googleusercontent.com/-dPCksSQFVv4/U2n8iYHel1I/AAAAAAAAAiM/o2lexHYurEw/s512/DynamicXrayLoadingPatty1.png" alt="DynamicXray + UIKit Pinball" height="480" />
<img src="https://lh6.googleusercontent.com/-Fgl4e0wa4ww/U2n8glJWs0I/AAAAAAAAAiE/7nuaM9hjL3o/s512/DynamicXrayCollisionsGravitySpring1.png" alt="DynamicXray + UIKit Pinball" height="480" />
<img src="https://lh3.googleusercontent.com/-DqGKvvee6ZI/U2x6pnJUb4I/AAAAAAAAAj0/EJGg3Wd3mKA/s512/DynamicXraySpringyRope1.png" alt="DynamicXray + Springy Rope" height="480" />


Quick Start
===========

Open `DynamicXray.xcworkspace`, select the Framework scheme, build the framework.

If successful, a Finder window should open at the location of `DynamicXray.framework`.

Add `DynamicXray.framework` to your iOS project.

Open your target's build settings, search for "Other Linker Flags" and add `-ObjC` if not already specified.

In your code, import the header and add an instance of DynamicXray to your dynamic animator.

```objc
#import <DynamicXray/DynamicXray.h>
...
DynamicXray *xray = [[DynamicXray alloc] init];
[self.dynamicAnimator addBehavior:xray];
```

### Dynamic Library

For advanced users, the Framework script also builds `DynamicXray.dylib`. The dylib
can be used for conditional loading at runtime, or injecting into other processes, etc.


Overview
========

DynamicXray is implemented as a UIDynamicBehavior. This means it can simply be added to any
UIDynamicAnimator to enable the introspection overlay. By default, all behaviours owned
by the animator will be visualised.

For more control, the DynamicXray behaviour exposes options such as temporarily disabling
the overlay, adjusting the cross fade between app and overlay, whether to draw dynamic
item outlines, and more. Refer to the [DynamicXray header][1].

DynamicXray includes a built-in configuration panel that slides up from the bottom of the
screen. The configuration panel provides access to some options at runtime. The configuration panel
can be presented by calling `-[DynamicXray presentConfigurationViewController]`.

For example:

```objc
DynamicXray *xray = [[DynamicXray alloc] init];
[self.dynamicAnimator addBehavior:xray];
[xray presentConfigurationViewController];
```

[1]: DynamicXray/DynamicXray/DynamicXray.h "DynamicXray.h"


Features
========

* Easy and controllable integration. Simply add the DynamicXray behavior to your dynamic animator.

* All UIKit Dynamic behaviours are visualised, including collision boundaries.

* All dynamic item bodies in the scene are visualised.

* Any contacts between dynamic items and other items or collision boundaries are highlighted.

* Configurable overlay cross fade control, between all of the application visible through to only the DynamicXray overlay visible.

* Built-in configuration panel for user to control run-time options.


DynamicXrayCatalog
==================

The included project DynamicXrayCatalog is a universal iOS app containing a suite
of various UIKit Dynamics demonstrations. The demos include DynamicXray pre-loaded
so introspection can be enabled on any demo to see the inner workings.

The demos in DynamicXrayCatalog were created by various authors and all are open
source.

Contributions are welcome! Submit a pull request if you would like to contribute a
demo to DynamicXrayCatalog. Please make sure that your demo includes an option to
enable DynamicXray.

<img src="https://lh3.googleusercontent.com/-Fnc1O28nYsg/U2x2QVwNU7I/AAAAAAAAAjo/U3jzC9DJi24/s512/DynamicXrayCatalogIndex.png" alt="DynamicXray Catalog Index" height="480" style="text-align:center" />


Videos
======

See DynamicXray demonstration [videos on YouTube][201].

[201]: https://www.youtube.com/playlist?list=PLijtl-wBLFKLtGN3go4zwrzzWMdRC4hmA "DynamicXray videos on YouTube"

<a href="https://www.youtube.com/watch?v=rcwK4zP_v_E&list=PLijtl-wBLFKLtGN3go4zwrzzWMdRC4hmA"><img src="https://lh5.googleusercontent.com/-cGJQx1LSpzA/U22WoX9ScUI/AAAAAAAAAkE/KVEaQRbq3F8/s720/DynamicXray%2520YouTube.png" alt="DynamicXray Videos" height="430" style="text-align:center" /></a>


Copyright and Licenses
======================

DynamicXray is Copyright (c) Chris Miles 2013-2014 and available for use under a [GPL-3.0 license][101].

The DynamicXray icon and any other included artwork is Copyright (c) Chris Miles 2013-2014 and available for use under a [Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License][103] (CC BY-NC-ND 4.0) only when used along with the DynamicXray library.

DynamicXrayCatalog is Copyright (c) Chris Miles 2013-2014 and others. DynamicXrayCatalog contains source code copyrighted by others and included within the terms of the respective licenses. See the included project sources for more details.

DynamicXrayCatalog is available for use under a [BSD (2-Clause) License][102], except for where included source code specifies alternative license details, then that code remains available under the original license terms. Refer to the source code for more details.

[101]: http://www.gnu.org/licenses/gpl.html "GPLv3 License"
[102]: http://opensource.org/licenses/BSD-2-Clause "BSD 2-Clause License"
[103]: http://creativecommons.org/licenses/by-nc-nd/4.0/ "Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License"
