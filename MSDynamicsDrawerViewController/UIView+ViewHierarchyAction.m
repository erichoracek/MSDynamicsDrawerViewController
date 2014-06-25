//
//  UIView+ViewHierarchyAction.m
//  Pods
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import "UIView+ViewHierarchyAction.h"

@implementation UIView (ViewHierarchyAction)

- (void)superviewHierarchyAction:(MSViewActionBlock)viewAction
{
    viewAction(self);
    [self.superview superviewHierarchyAction:viewAction];
}

@end
