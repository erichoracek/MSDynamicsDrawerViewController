//
//  MSAppDelegate.h
//  Test App
//
//  Created by Eric Horacek on 4/6/14.
//
//

#import <UIKit/UIKit.h>

@class MSDynamicsDrawerViewController;

@interface MSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

@end
