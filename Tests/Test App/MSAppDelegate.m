//
//  MSAppDelegate.m
//  Test App
//
//  Created by Eric Horacek on 4/6/14.
//
//

#import "MSAppDelegate.h"
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import <QuartzCore/QuartzCore.h>
#import <Fingertips/MBFingerTipWindow.h>

@implementation MSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[MBFingerTipWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setValue:@YES forKey:@"active"];
    
    UIViewController *paneViewController = [UIViewController new];
    paneViewController.view.backgroundColor = [UIColor colorWithRed:0.99 green:0.50 blue:0.47 alpha:1.0];
    paneViewController.view.layer.borderColor = [UIColor colorWithRed:0.98 green:0.24 blue:0.22 alpha:1.0].CGColor;
    paneViewController.view.layer.borderWidth = 2.0;

    UIViewController *topDrawerViewController = [UIViewController new];
    topDrawerViewController.view.backgroundColor = [UIColor colorWithRed:1.00 green:0.72 blue:0.43 alpha:1.0];
    topDrawerViewController.view.layer.borderColor = [UIColor colorWithRed:0.99 green:0.58 blue:0.15 alpha:1.0].CGColor;
    topDrawerViewController.view.layer.borderWidth = 2.0;
    
    UIViewController *leftDrawerViewController = [UIViewController new];
    leftDrawerViewController.view.backgroundColor = [UIColor colorWithRed:0.51 green:0.80 blue:0.95 alpha:1.0];
    leftDrawerViewController.view.layer.borderColor = [UIColor colorWithRed:0.31 green:0.71 blue:0.93 alpha:1.0].CGColor;
    leftDrawerViewController.view.layer.borderWidth = 2.0;
    
    UIViewController *bottomDrawerViewController = [UIViewController new];
    bottomDrawerViewController.view.backgroundColor = [UIColor colorWithRed:0.98 green:0.85 blue:0.45 alpha:1.0];
    bottomDrawerViewController.view.layer.borderColor = [UIColor colorWithRed:0.93 green:0.72 blue:0.05 alpha:1.0].CGColor;
    bottomDrawerViewController.view.layer.borderWidth = 2.0;
 
    UIViewController *rightDrawerViewController = [UIViewController new];
    rightDrawerViewController.view.backgroundColor = [UIColor colorWithRed:0.59 green:0.93 blue:0.42 alpha:1.0];
    rightDrawerViewController.view.layer.borderColor = [UIColor colorWithRed:0.29 green:0.71 blue:0.08 alpha:1.0].CGColor;
    rightDrawerViewController.view.layer.borderWidth = 2.0;
    
    self.dynamicsDrawerViewController = [MSDynamicsDrawerViewController new];
    self.dynamicsDrawerViewController.paneViewController = paneViewController;
    [self.dynamicsDrawerViewController setDrawerViewController:topDrawerViewController forDirection:MSDynamicsDrawerDirectionTop];
    [self.dynamicsDrawerViewController setDrawerViewController:leftDrawerViewController forDirection:MSDynamicsDrawerDirectionLeft];
    [self.dynamicsDrawerViewController setDrawerViewController:rightDrawerViewController forDirection:MSDynamicsDrawerDirectionRight];
    [self.dynamicsDrawerViewController setDrawerViewController:bottomDrawerViewController forDirection:MSDynamicsDrawerDirectionBottom];
    
    self.window.rootViewController = self.dynamicsDrawerViewController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
