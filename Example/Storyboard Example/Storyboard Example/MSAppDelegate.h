//
//  MSAppDelegate.h
//  MSNPVC
//
//  Created by Eric Horacek on 12/16/12.
//  Copyright (c) 2012 Monospace Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSNavigationPaneViewController;

@interface MSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSNavigationPaneViewController *navigationPaneViewController;

@end
