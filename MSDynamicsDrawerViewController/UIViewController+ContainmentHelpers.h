//
//  UIViewController+ContainmentHelpers.h
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (Containment)

- (void)ms_replaceViewController:(UIViewController *)existingViewController withViewController:(UIViewController *)newViewController inContainerView:(UIView *)containerView completion:(void (^)(void))completion;

@end
