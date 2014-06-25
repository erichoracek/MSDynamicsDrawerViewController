//
//  UIViewController+Containment.m
//  Pods
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import "UIViewController+ContainmentHelpers.h"

@implementation UIViewController (Containment)

- (void)replaceViewController:(UIViewController *)existingViewController withViewController:(UIViewController *)newViewController inContainerView:(UIView *)containerView completion:(void (^)(void))completion
{
    // Add initial view controller
	if (!existingViewController && newViewController) {
        [newViewController willMoveToParentViewController:self];
        [newViewController beginAppearanceTransition:YES animated:NO];
		[self addChildViewController:newViewController];
        newViewController.view.frame = containerView.bounds;
		[containerView addSubview:newViewController.view];
        [containerView sendSubviewToBack:newViewController.view];
		[newViewController didMoveToParentViewController:self];
        [newViewController endAppearanceTransition];
        if (completion) completion();
	}
    // Remove existing view controller
    else if (existingViewController && !newViewController) {
        [existingViewController willMoveToParentViewController:nil];
        [existingViewController beginAppearanceTransition:NO animated:NO];
        [existingViewController.view removeFromSuperview];
        [existingViewController removeFromParentViewController];
        [existingViewController didMoveToParentViewController:nil];
        [existingViewController endAppearanceTransition];
        if (completion) completion();
    }
    // Replace existing view controller with new view controller
    else if ((existingViewController != newViewController) && newViewController) {
        [newViewController willMoveToParentViewController:self];
        [existingViewController willMoveToParentViewController:nil];
        [existingViewController beginAppearanceTransition:NO animated:NO];
        [existingViewController.view removeFromSuperview];
        [existingViewController removeFromParentViewController];
        [existingViewController didMoveToParentViewController:nil];
        [existingViewController endAppearanceTransition];
        [newViewController beginAppearanceTransition:YES animated:NO];
        newViewController.view.frame = containerView.bounds;
        [self addChildViewController:newViewController];
        [containerView addSubview:newViewController.view];
        [containerView sendSubviewToBack:newViewController.view];
        [newViewController didMoveToParentViewController:self];
        [newViewController endAppearanceTransition];
        if (completion) completion();
    }
}

@end
