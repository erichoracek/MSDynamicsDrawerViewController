# Introduction

**MSNavigationPaneViewController** was written by **Eric Horacek** for **[Monospace Ltd.](http://www.monospacecollective.com)**

`MSNavigationPaneViewController` is a container view controller that handles the presentation of two overlaid child view controllers. The "pane" view can moved with a swipe gesture to reveal the "master" view below. This interface paradigm easily enables the navigation seen in Facebook, Path, and many others. 

There are a number of great reasons to use `MSNavigationPaneViewController` over of the many other similar overlaid view controller classes:

* **Simplicity** – This class was written with an emphasis on simplicity. Its interface is about as simple as they come, and is easy to extend.
* **Pane Swiping** – You can swipe the pane to reveal the master view, and there's a nice bounce animation when the navigation pane finishes sliding.
* **Styling** – There are various appearance types, animations, and open directions available to customize the visual style.
* **Easy Integration** – It doesn't require for you to subclass your pane or master view controllers to add them as child view controllers. 
* **Animations** – When a new pane view controller is set using the `setPaneViewController:animated:completion:` method, it is first animated off to the right, replaced, and then animated back to the left. This prevents a jarring "pop-in" effect when a new pane view controller replaces the current view.
* **Containment APIs** – It uses the `UIViewController` containment APIs introduced in iOS 5, so you can rest assured that there's no hackiness going on to get nice overlaid view controllers.

To really get a good feel for it, you should run the `MSNavigationPaneViewController` example on device—otherwise it's difficult to get a decent idea of how the swiping gestures are implemented.

# Examples

Two examples for `MSNavigationPaneViewController` are included in the "Example" directory within `Examples.xcworkspace`:

* `Example.xcodeproj` – No Storyboards or Nibs
* `Storyboard Example.xcodeproj` – Use with Storyboards

The example projects depend on `PRTween`, which is included as a git submodule. To install, run the following:

```  bash
$ git submodule init
$ git submodule update
```

# Open Directions

* **Left** (`MSNavigationPaneOpenDirectionLeft`) – Default open direction. The navigation pane opens from the left. A left-right swipe can also reveal the master view.

* **Top** (`MSNavigationPaneOpenDirectionTop`) – The navigation pane opens from the top. A top-bottom swipe can also reveal the master view.

<img src="https://raw.github.com/monospacecollective/MSNavigationPaneViewController/master/Screenshots/Left.png" height="490" width="320" alt="Left Open Direction" /> &nbsp;
<img src="https://raw.github.com/monospacecollective/MSNavigationPaneViewController/master/Screenshots/Top.png" height="490" width="320" alt="Top Open Direction" />

# Appearance

There are a few types of appearance available for `MSNavigationPaneViewController`. They each change some aspect of the visual style of the pane view dragging. The appearance type of the navigation pane is set via the `navigationPaneViewController.appearanceType` accessor. The possible types are as follows:

* **Parallax** (`MSNavigationPaneAppearanceTypeParallax`) – Scrolls the master view in from the right as the pane view is dragged.
* **Zoom** (`MSNavigationPaneAppearanceTypeZoom`) – Zooms the master view in from an inset state as the pane view is dragged.
* **Fade** (`MSNavigationPaneAppearanceTypeFade`) – Fades the master view from an alpha of `1.0` to `0.0` as the pane view is dragged.

## Reveal Width

To change the distance that the pane view snaps open to, set:

```  objective-c
navigationPaneViewController.openStateRevealWidth = 100.0; // Or whatever width you'd like.
```

# Touches

## Forwarding Touches

To forward touches through views that require a swipe/pan gesture so that the `MSNavigationPaneViewController` doesn't intercept them, simply add their `Class` to `touchForwardingClasses`:

```  objective-c
[navigationPaneViewController.touchForwardingClasses addObject:UISwitch.class];
```

Both `UISlider` and `UISwitch` are included by default.

## Disabling Pane Dragging

To disable dragging of the pane and prevent `MSNavigationPaneViewController` from intercepting touches, set 

```  objective-c
navigationPaneViewController.draggingEnabled = NO;
```

# Requirements

Requires iOS 5.0, ARC, and the QuartzCore Framework.

# Contributing

Forks, patches and other feedback are welcome.

# License

*Copyright (c) 2012-2013 Monospace Ltd. All rights reserved.*

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
