//
//  UIPanGestureRecognizer+StartEdge.h
//  Pods
//
//  Created by Eric Horacek on 6/21/14.
//
//

#import <UIKit/UIKit.h>

@interface UIPanGestureRecognizer (StartEdge)

- (UIRectEdge)startedAtEdgesOfView:(UIView *)view;

@end
