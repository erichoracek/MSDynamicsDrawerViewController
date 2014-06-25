//
//  UIView+ViewHierarchyAction.h
//  Pods
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import <UIKit/UIKit.h>

typedef void (^MSViewActionBlock)(UIView *view);

@interface UIView (ViewHierarchyAction)

- (void)superviewHierarchyAction:(MSViewActionBlock)viewAction;

@end
