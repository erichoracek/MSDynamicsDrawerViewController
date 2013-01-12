//
//  MSAppDelegate.m
//  MSNPVC
//
//  Created by Eric Horacek on 12/16/12.
//  Copyright (c) 2012 Monospace Ltd. All rights reserved.
//

#import "MSAppDelegate.h"
#import "MSNavigationPaneViewController.h"
#import "MSMasterViewController.h"

@implementation MSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.navigationPaneViewController = (MSNavigationPaneViewController *)self.window.rootViewController;

    MSMasterViewController *masterViewController = (MSMasterViewController *)[self.navigationPaneViewController.storyboard instantiateViewControllerWithIdentifier:@"MasterViewController"];
    masterViewController.navigationPaneViewController = self.navigationPaneViewController;

    self.navigationPaneViewController.masterViewController = masterViewController;
    
    [masterViewController transitionToViewController:MSPaneViewControllerTypeAppearanceNone];
    
    return YES;
}

@end
