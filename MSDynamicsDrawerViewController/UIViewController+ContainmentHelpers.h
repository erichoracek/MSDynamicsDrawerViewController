//
//  UIViewController+ContainmentHelpers.h
//  Pods
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (Containment)

- (void)replaceViewController:(UIViewController *)existingViewController withViewController:(UIViewController *)newViewController inContainerView:(UIView *)containerView completion:(void (^)(void))completion;

@end
