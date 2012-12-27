# Introduction

**MSNavigationPaneViewController** was written by **Eric Horacek** for **[Monospace Ltd.](http://www.monospacecollective.com)**

`MSNavigationPaneViewController` is a view controller that handles the presentation of two overlaid child view controllers. The "pane" view can moved with a swipe gesture to reveal the "master" view below. This interface paradigm easily enables the navigation seen in Facebook, Path, and many others.

There are a number of great reasons to use `MSNavigationPaneViewController` over of the many other similar overlaid view controller classes:

* This class was written with an emphasis on simplicity. Its interface is about as simple as they come, and is easy to extend.
* It features a smooth bounce animation when the navigation pane is flicked in either direction based on the velocity of the swipe gesture.
* It doesn't require for you to subclass your pane or master view controllers to add them as child view controllers. 
* The swipe gesture to reveal the master view controller doesn't interfere with `UITableViews` or other `UIScrollViews` added to the pane view controller's view.
* When a new pane view controller is set using the `setPaneViewController:animated:completion:` method, it is first animated off to the right, replaced, and then animated back to the left. This prevents a jarring "pop-in" effect when a new pane view controller replaces the current view.

# Touches

## Forwarding Touches

To forward touches through views that require a swipe/pan gesture (e.g. `UISlider`, `UISwitch`, etc.) so that your `MSNavigationPaneViewController` doesn't intercept them, simply add their `Class` to `navigationPaneViewController.paneView.touchForwardingClasses`. Both `UISlider` and `UISwitch` are included by default.

## Disabling Pane Dragging

To disable dragging of the pane and prevent `MSNavigationPaneViewController` from intercepting touches, set `navigationPaneViewController.paneView.draggingEnabled` to `NO`.

# Example

Two example Xcode projects that uses `MSNavigationPaneViewController` are included in the "Example" directory and in the `Examples.xcworkspace`:

* `Example.xcodeproj` – Basic Use (No Storyboards or Nibs)
* `Storyboard Example.xcodeproj` – Use with Storyboards

![Open](https://raw.github.com/monospacecollective/MSNavigationPaneViewController/master/Screenshots/Open.png)

![Closed](https://raw.github.com/monospacecollective/MSNavigationPaneViewController/master/Screenshots/Closed.png)

![Opening with animation of MasterView](https://raw.github.com/monospacecollective/MSNavigationPaneViewController/master/Screenshots/Closed.png)

# Requirements

Requires iOS 5.0, ARC, and the QuartzCore Framework.

# Contributing

Forks, patches and other feedback are welcome.

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
