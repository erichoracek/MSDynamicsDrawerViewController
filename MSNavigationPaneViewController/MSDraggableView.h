//
//  MSDraggableView.h
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

typedef NS_ENUM(NSUInteger, MSDraggableViewState) {
    MSDraggableViewStateOpen,
    MSDraggableViewStateClosed,
};

@class MSNavigationPaneViewController;
@protocol MSDraggableViewDelegate;

@interface MSDraggableView : UIView

@property (nonatomic, weak) MSNavigationPaneViewController <MSDraggableViewDelegate> * navigationPaneViewController;
@property (nonatomic, weak) id <MSDraggableViewDelegate> delegate;

@property (nonatomic, assign) MSDraggableViewState state;
@property (nonatomic, assign) BOOL draggingEnabled;

// Classes that the draggable view should forward dragging through to (UISlider by default)
@property (nonatomic, readonly) NSMutableSet *touchForwardingClasses;

@end

@protocol MSDraggableViewDelegate <NSObject>

@optional

- (void)draggableView:(MSDraggableView *)draggableView wasDraggedToState:(MSDraggableViewState)state;
- (void)draggableView:(MSDraggableView *)draggableView wasDraggedToFraction:(CGFloat)fraction;

@end

