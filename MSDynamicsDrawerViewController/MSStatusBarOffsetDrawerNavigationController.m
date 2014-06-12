//
//  MSStatusBarOffsetDrawerNavigationController.m
//  Pods
//
//  Created by Eric Horacek on 6/11/14.
//
//

#import "MSStatusBarOffsetDrawerNavigationController.h"

@implementation MSStatusBarOffsetDrawerNavigationController

#pragma mark - UIViewController

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    if (parent) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarDidChangeFrame:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [self.view setNeedsLayout];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self positionView];
}

#pragma mark - AUTSettingsNavigationController

static CGFloat const MSVerticalOffset = -0.1;
static CGFloat const MSStatusBarMaximumAdjustmentHeight = 20.0;

- (void)positionView
{
    // Move to a small negative y to prevent iOS from making the height of this navigation bar 64, but 44 instead.
    // http://blog.jaredsinclair.com/post/61507315630/wrestling-with-status-bars-and-navigation-bars-on-ios-7
    CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
    CGFloat viewFrameY = ((CGRectGetHeight(statusBarFrame) <= MSStatusBarMaximumAdjustmentHeight) ? MSVerticalOffset : 0.0);
    
    if (fabsf(CGRectGetMinY(self.view.frame) - viewFrameY) > 0.01) {
        self.view.frame = (CGRect){{CGRectGetMinX(self.view.frame), viewFrameY}, self.view.frame.size};
        [self.view setNeedsLayout];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)statusBarDidChangeFrame:(NSNotification *)notification
{
    [self positionView];
    [self setNavigationBarHidden:!self.navigationBarHidden];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNavigationBarHidden:!self.navigationBarHidden];
    });
}

@end
