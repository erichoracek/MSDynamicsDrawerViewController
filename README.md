# MGNavigationPaneViewController

Created by **Eric Horacek** for **[Monospace Ltd.](http://www.monospacecollective.com)**

The *MGNavigationPaneViewController* is a view controller that handles the presentation of two overlaid children view controllers. The "pane" view controller can moved with a swipe gesture to reveal the "master" view controller below.

This class was written with an emphasis on simplicity. It features a nice "bounce" animation when the user swipes the navigation pane in either direction, and doesn't require for you to subclass your view controllers. Additionally, the swipe gesture to reveal the "master" view controller doesn't interfere with *UITableView*s (or other *UIScrollView*s) added to the "pane" view controller's views.

To forward touches through views that require a swipe gesture (so that the *MGNavigationPaneViewController* doesn't intercept them), simply add their *Class* to the *touchForwardingClasses* property on the *MSDraggableView* paneView property on your *MGNavigationPaneViewController*.

# Example

An example Xcode project that uses the *MGNavigationPaneViewController* in included in the "Example" directory.

# Requirements

Requires iOS 5.0.

# License

*Copyright (c) 2012 Monospace Ltd. All rights reserved.*

*This code is distributed under the terms and conditions of the MIT license.*

*Permission is hereby granted, free of charge, to any person obtaining a copy*
*of this software and associated documentation files (the "Software"), to deal*
*in the Software without restriction, including without limitation the rights*
*to use, copy, modify, merge, publish, distribute, sublicense, and/or sell*
*copies of the Software, and to permit persons to whom the Software is*
*furnished to do so, subject to the following conditions:*

*The above copyright notice and this permission notice shall be included in*
*all copies or substantial portions of the Software.*

*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR*
*IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,*
*FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE*
*AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER*
*LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,*
*OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN*
*THE SOFTWARE.*
