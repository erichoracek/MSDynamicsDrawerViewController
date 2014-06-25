//
//  Tests.m
//  Tests
//
//  Created by Eric Horacek on 4/6/14.
//
//

#import <KIF/KIF.h>
#import <KIF/CGGeometry-KIFAdditions.h>
#import <libextobjc/EXTScope.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import <Stubbilino/Stubbilino.h>

@interface Tests : KIFTestCase

@property (nonatomic, strong) MSDynamicsDrawerViewController *drawerViewController;

@end

@interface MSDynamicsDrawerViewController (PrivateTestMethods)

@property (nonatomic, strong, setter = _setPanePanGestureRecognizer:) UIPanGestureRecognizer *_panePanGestureRecognizer;

@end

@implementation Tests

- (void)setUp
{
    self.drawerViewController = (MSDynamicsDrawerViewController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

- (CGRect)paneOnScreenBoundsRect
{
    // Convert to the paneView's window's coordinate system
    CGRect frame = [self.drawerViewController.paneView convertRect:self.drawerViewController.paneView.bounds toView:nil];
    // Determine the visible rect of the pane within the window's bounds
    CGRect visibleRect = CGRectIntersection(self.drawerViewController.paneView.window.bounds, frame);
    // Convert back to paneView coordinates
    CGRect converedVisibleRect = [self.drawerViewController.paneView.window convertRect:visibleRect toView:self.drawerViewController.paneView];
    return converedVisibleRect;
}

static CGFloat const MSSwipeEdgeInset = 10.0;
static UIEdgeInsets const MSSwipeEdgeInsets = (UIEdgeInsets){
    .top = MSSwipeEdgeInset,
    .left = MSSwipeEdgeInset,
    .bottom = MSSwipeEdgeInset,
    .right = MSSwipeEdgeInset
};

- (void)swipePaneInDirection:(KIFSwipeDirection)direction
{
    CGRect swipeRect = [self paneOnScreenBoundsRect];
    
    switch (direction) {
    case KIFSwipeDirectionLeft:
    case KIFSwipeDirectionRight: {
        do {
            swipeRect = UIEdgeInsetsInsetRect(swipeRect, MSSwipeEdgeInsets);
        } while (CGRectGetWidth(swipeRect) >= 70.0 && CGRectGetHeight(swipeRect) > 40.0);
        break;
    }
    case KIFSwipeDirectionUp:
    case KIFSwipeDirectionDown: {
        do {
            swipeRect = UIEdgeInsetsInsetRect(swipeRect, MSSwipeEdgeInsets);
        } while (CGRectGetHeight(swipeRect) >= 70.0 && CGRectGetWidth(swipeRect) > 40.0);
        break;
    }
    }
    
    CGPoint swipeStart;
    CGPoint swipeEnd;
    switch (direction) {
    case KIFSwipeDirectionLeft:
        swipeStart = CGPointMake(CGRectGetMinX(swipeRect), CGRectGetMidY(swipeRect));
        swipeEnd = CGPointMake(CGRectGetMaxX(swipeRect), CGRectGetMidY(swipeRect));
        break;
    case KIFSwipeDirectionRight:
        swipeStart = CGPointMake(CGRectGetMaxX(swipeRect), CGRectGetMidY(swipeRect));
        swipeEnd = CGPointMake(CGRectGetMinX(swipeRect), CGRectGetMidY(swipeRect));
        break;
    case KIFSwipeDirectionDown:
        swipeStart = CGPointMake(CGRectGetMidX(swipeRect), CGRectGetMinY(swipeRect));
        swipeEnd = CGPointMake(CGRectGetMidX(swipeRect), CGRectGetMaxY(swipeRect));
        break;
    case KIFSwipeDirectionUp:
        swipeStart = CGPointMake(CGRectGetMidX(swipeRect), CGRectGetMaxY(swipeRect));
        swipeEnd = CGPointMake(CGRectGetMidX(swipeRect), CGRectGetMinY(swipeRect));
        break;
    default:
        XCTFail(@"Invalid direction value %@", @(direction));
        break;
    }
    
    KIFDisplacement swipeDisplacement = CGPointMake((swipeEnd.x - swipeStart.x), (swipeEnd.y - swipeStart.y));
    NSUInteger steps = nearbyint(CGRectGetWidth(swipeRect) / 5.0);
    [self stubVelocityForDisplacement:swipeDisplacement steps:steps];
    [self.drawerViewController.paneView dragFromPoint:swipeStart displacement:swipeDisplacement steps:steps];
}

- (void)stubVelocityForDisplacement:(KIFDisplacement)displacement steps:(NSUInteger)steps
{
    // UIPanGestureRecognizer returns 0.0 for velocityInView: when using KIF, this stubs it for testing
    UIPanGestureRecognizer <SBStub> *stub = (id)[Stubbilino stubObject:self.drawerViewController._panePanGestureRecognizer];
    [stub stubMethod:@selector(velocityInView:) withBlock:^{
        return CGPointMake((displacement.x * steps), (displacement.y * steps));
    }];
}

- (void)tapPane
{
    [self.drawerViewController.paneView tapAtPoint:CGPointCenteredInRect([self paneOnScreenBoundsRect])];
}

- (KIFSwipeDirection)closeSwipeDirectionForDrawerDirection:(MSDynamicsDrawerDirection)direction
{
    switch ((NSInteger)direction) {
    case MSDynamicsDrawerDirectionLeft:
        return KIFSwipeDirectionRight;
    case MSDynamicsDrawerDirectionTop:
        return KIFSwipeDirectionUp;
    case MSDynamicsDrawerDirectionRight:
        return KIFSwipeDirectionLeft;
    case MSDynamicsDrawerDirectionBottom:
        return KIFSwipeDirectionDown;
    }
    return -1;
}

- (KIFSwipeDirection)openSwipeDirectionForDrawerDirection:(MSDynamicsDrawerDirection)direction
{
    switch ((NSInteger)direction) {
    case MSDynamicsDrawerDirectionLeft:
        return KIFSwipeDirectionLeft;
    case MSDynamicsDrawerDirectionTop:
        return KIFSwipeDirectionDown;
    case MSDynamicsDrawerDirectionRight:
        return KIFSwipeDirectionRight;
    case MSDynamicsDrawerDirectionBottom:
        return KIFSwipeDirectionUp;
    }
    return -1;
}

#pragma mark - Tests

- (void)testTogglePaneStateNonAnimated
{
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
    
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedValue) {
 
        MSDynamicsDrawerPaneState paneState;
        
        // Set closed
        self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
        [tester waitForTimeInterval:0.1];
        XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
        XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateClosed);
        XCTAssertTrue(self.drawerViewController.currentDrawerDirection == MSDynamicsDrawerDirectionNone);
        
        // Set opened left
        [self.drawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:maskedValue];
        [tester waitForTimeInterval:0.1];
        XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
        XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateOpen);
        XCTAssertTrue(self.drawerViewController.currentDrawerDirection == maskedValue);
    });
}

- (void)testTogglePaneStateAnimated
{
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
    
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedValue) {
    
        @weakify(self);
        __block MSDynamicsDrawerPaneState paneState;
        
        // Set opened
        [self.drawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:maskedValue animated:YES allowUserInterruption:YES completion:^{
            @strongify(self);
            XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
            XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateOpen);
            XCTAssertTrue(self.drawerViewController.currentDrawerDirection == maskedValue);
        }];
        [tester waitForTimeInterval:2.0];
        
        // Set closed
        [self.drawerViewController setPaneState:MSDynamicsDrawerPaneStateClosed animated:YES allowUserInterruption:YES completion:^{
            @strongify(self);
            XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
            XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateClosed);
            XCTAssertTrue(self.drawerViewController.currentDrawerDirection == MSDynamicsDrawerDirectionNone);
        }];
        [tester waitForTimeInterval:2.0];
    });
}

- (void)testSwipeToOpenDrawer
{
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
    
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedValue) {
        self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
        [tester waitForTimeInterval:0.1];
        [self swipePaneInDirection:[self openSwipeDirectionForDrawerDirection:maskedValue]];
        [tester waitForTimeInterval:2.0];
        MSDynamicsDrawerPaneState paneState;
        XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
        XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateOpen);
    });
}

- (void)testSwipeOpenDrawerThenTapPaneToClose
{
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
    
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedValue) {
        self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
        [tester waitForTimeInterval:0.1];
        [self swipePaneInDirection:[self openSwipeDirectionForDrawerDirection:maskedValue]];
        [tester waitForTimeInterval:1.0];
        MSDynamicsDrawerPaneState paneState;
        XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
        XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateOpen);
        [self tapPane];
        [tester waitForTimeInterval:2.0];
        XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
        XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateClosed);
    });
}

- (void)testSwipeOpenDrawerThenSwipePaneToClose
{
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
    
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedValue) {
        self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
        [tester waitForTimeInterval:0.1];
        [self swipePaneInDirection:[self openSwipeDirectionForDrawerDirection:maskedValue]];
        [tester waitForTimeInterval:0.7];
        [self swipePaneInDirection:[self closeSwipeDirectionForDrawerDirection:maskedValue]];
        [tester waitForTimeInterval:2.0];
        MSDynamicsDrawerPaneState paneState;
        XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
        XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateClosed);
    });
}

- (void)testBouncePaneOpen
{
    self.drawerViewController.paneState = MSDynamicsDrawerPaneStateClosed;
 
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedValue) {
        [self.drawerViewController bouncePaneOpenInDirection:maskedValue];
        [tester waitForTimeInterval:1.0];
        MSDynamicsDrawerPaneState paneState;
        XCTAssertTrue([self.drawerViewController.paneLayout paneWithCenter:self.drawerViewController.paneView.center isInValidState:&paneState forDirection:maskedValue]);
        XCTAssertTrue(paneState == MSDynamicsDrawerPaneStateClosed);
    });
}

@end
