//
//  UIView+ViewHierarchyAction.m
//  MSDynamicsDrawerViewController
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import "UIView+ViewHierarchyAction.h"

@implementation UIView (ViewHierarchyAction)

- (void)ms_superviewHierarchyAction:(MSViewActionBlock)viewAction
{
    viewAction(self);
    [self.superview ms_superviewHierarchyAction:viewAction];
}

@end
