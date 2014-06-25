//
//  MSStylerTests.m
//  Tests
//
//  Created by Eric Horacek on 6/22/14.
//
//

#import <XCTest/XCTest.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import <Aspects/Aspects.h>
#import <libextobjc/EXTScope.h>

@interface MSTestStyler : NSObject <MSDynamicsDrawerStyler>

@end

@implementation MSTestStyler

- (void)stylerWasAddedToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
}

- (void)stylerWasRemovedFromDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction
{
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction
{
}

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction
{
}

@end

@interface MSStylerTests : XCTestCase

@property (nonatomic, strong) MSDynamicsDrawerViewController *drawerViewController;

@end

@implementation MSStylerTests

- (void)testStylerLifecycleAddedRemoved
{
    void(^testStylerLifecycleForDirection)(MSDynamicsDrawerDirection direction) = ^(MSDynamicsDrawerDirection direction) {
        
        __block NSInteger invocationCount = 0;
        MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedValue) {
            invocationCount++;
        });
        
        UIWindow *window = [UIWindow new];
        MSDynamicsDrawerViewController *drawerViewController = [MSDynamicsDrawerViewController new];
        window.rootViewController = drawerViewController;
        
        MSTestStyler *testStyler = [MSTestStyler new];
        
        __block BOOL wasAddedInvoked = NO;
        __block NSInteger wasAddedInvocationCount = 0;
        __block MSDynamicsDrawerDirection wasAddedDirection = MSDynamicsDrawerDirectionNone;
        [testStyler aspect_hookSelector:@selector(stylerWasAddedToDynamicsDrawerViewController:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual(drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer");
            XCTAssertTrue((direction & stylerDirection), @"Must be called with a correct direction");
            XCTAssertTrue([drawerViewController isViewLoaded], @"Drawer view controller view must be loaded at this point");
            XCTAssertEqual(drawerViewController.view.window, window, @"Drawer view controller view must have window at this point");
            wasAddedInvoked = YES;
            wasAddedInvocationCount++;
            wasAddedDirection |= stylerDirection;
        } error:NULL];
        
        __block BOOL wasRemovedInvoked = NO;
        __block NSInteger wasRemovedInvocationCount = 0;
        __block MSDynamicsDrawerDirection wasRemovedDirection = MSDynamicsDrawerDirectionNone;
        [testStyler aspect_hookSelector:@selector(stylerWasRemovedFromDynamicsDrawerViewController:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual(drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer");
            XCTAssertTrue((direction & stylerDirection), @"Must be called with a correct direction");
            XCTAssertTrue([drawerViewController isViewLoaded], @"Drawer view controller view must be loaded at this point");
            XCTAssertEqual(drawerViewController.view.window, window, @"Drawer view controller view must have window at this point");
            wasRemovedInvoked = YES;
            wasRemovedInvocationCount++;
            wasRemovedDirection |= stylerDirection;
        } error:NULL];
        
        [drawerViewController addStyler:testStyler forDirection:direction];

        XCTAssertFalse(wasAddedInvoked, @"Styler must be not yet added");
        
        // Show the window (with the drawer as root view controller)
        window.hidden = NO;
        
        XCTAssertTrue(wasAddedInvoked, @"Styler must be added when the view has been loaded");
        XCTAssertEqual(wasAddedInvocationCount, invocationCount, @"Styler must be added individually for each direction it's added for");
        XCTAssertEqual(wasAddedDirection, direction, @"Styler must be added individually for each direction it's added for");
        
        XCTAssertFalse(wasRemovedInvoked, @"Styler must be not yet be removed");
        
        // Remove the view controller
        window.rootViewController = nil;
        
        XCTAssertTrue(wasRemovedInvoked, @"Styler must not yet be added until the view has been loaded");
        XCTAssertEqual(wasRemovedInvocationCount, invocationCount, @"Styler must be removed individually for each direction it's added for");
        XCTAssertEqual(wasRemovedDirection, direction, @"Styler must be removed individually for each direction it's added for");
    };
    
    // Test for all values individually
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection direction) {
        testStylerLifecycleForDirection(direction);
    });
    
    // Test for masked values
    testStylerLifecycleForDirection(MSDynamicsDrawerDirectionAll);
    testStylerLifecycleForDirection(MSDynamicsDrawerDirectionHorizontal);
    testStylerLifecycleForDirection(MSDynamicsDrawerDirectionVertical);
    testStylerLifecycleForDirection(MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft | MSDynamicsDrawerDirectionRight);
}

- (void)testStylerLifecycleChangeState
{
    
    void(^transitionFromStateToStateForDirectionAnimated)(MSDynamicsDrawerPaneState, MSDynamicsDrawerPaneState, MSDynamicsDrawerDirection, BOOL) = ^(MSDynamicsDrawerPaneState fromPaneSate, MSDynamicsDrawerPaneState toPaneState, MSDynamicsDrawerDirection direction, BOOL animated) {
        
        NSLog(@"transition");
        
        UIWindow *window = [UIWindow new];
        self.drawerViewController = [MSDynamicsDrawerViewController new];
        window.rootViewController = self.drawerViewController;
        
        UIViewController *rightDrawerViewController = [UIViewController new];
        [self.drawerViewController setDrawerViewController:rightDrawerViewController forDirection:direction];
        
        UIViewController *paneViewController = [UIViewController new];
        self.drawerViewController.paneViewController = paneViewController;
        
        self.drawerViewController.paneState = fromPaneSate;
        
        CGPoint fromPaneStatePaneCenter = [self.drawerViewController.paneLayout paneCenterForPaneState:fromPaneSate direction:direction];
        CGFloat fromPaneStatePaneClosedFraction = [self.drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:fromPaneStatePaneCenter forDirection:direction];
        
        CGPoint toPaneStatePaneCenter = [self.drawerViewController.paneLayout paneCenterForPaneState:toPaneState direction:direction];
        CGFloat toPaneStatePaneClosedFraction = [self.drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:toPaneStatePaneCenter forDirection:direction];
        
        MSTestStyler *testStyler = [MSTestStyler new];
        
        __block BOOL mayUpdateToPaneStateInvoked = NO;
        [testStyler aspect_hookSelector:@selector(dynamicsDrawerViewController:mayUpdateToPaneState:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerPaneState stylerPaneState, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual(self.drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(stylerPaneState, toPaneState, @"Must be called with correct pane state");
            XCTAssertEqual(stylerDirection, direction, @"Must be in correct direction");
            mayUpdateToPaneStateInvoked = YES;
        } error:NULL];
        
        __block BOOL didUpdatePaneClosedFractionInvoked = NO;
        NSMutableArray *paneClosedFractions = [NSMutableArray new];
        [testStyler aspect_hookSelector:@selector(dynamicsDrawerViewController:didUpdatePaneClosedFraction:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, CGFloat paneClosedFraction, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual(self.drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(stylerDirection, direction, @"Must be in correct direction");
            XCTAssertTrue(mayUpdateToPaneStateInvoked, @"May update to pane state must be invoked before paneClosedFraction");
            [paneClosedFractions addObject:@(paneClosedFraction)];
            didUpdatePaneClosedFractionInvoked = YES;
        } error:NULL];
        
        __block BOOL didUpdateToPaneStateInvoked = NO;
        [testStyler aspect_hookSelector:@selector(dynamicsDrawerViewController:didUpdateToPaneState:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *stylerDrawerViewController, MSDynamicsDrawerPaneState stylerPaneState, MSDynamicsDrawerDirection stylerDirection) {
            XCTAssertEqual(self.drawerViewController, stylerDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(stylerPaneState, toPaneState, @"Must be called with correct pane state");
            XCTAssertEqual(stylerDirection, direction, @"Must be in correct direction");
            XCTAssertTrue(didUpdatePaneClosedFractionInvoked, @"Must be invoked after didUpdatePaneClosedFraction");
            didUpdateToPaneStateInvoked = YES;
        } error:NULL];
        
        [self.drawerViewController addStyler:testStyler forDirection:direction];
        
        // Show the window (with the drawer as the rootViewController)
        window.hidden = NO;
        
        XCTestExpectation *stateUpdateExpectation = [self expectationWithDescription:@"Update Pane State"];
        @weakify(self);
        [self.drawerViewController setPaneState:toPaneState animated:animated allowUserInterruption:NO completion:^{
            @strongify(self);
            XCTAssertTrue(didUpdateToPaneStateInvoked, @"Must invoke did update to pane state");
            NSLog(@"%@", paneClosedFractions);
            XCTAssertEqualObjects([paneClosedFractions firstObject], @(fromPaneStatePaneClosedFraction), @"Pane closed fractions must start at fromPaneStatePaneClosedFraction");
            XCTAssertEqualObjects([paneClosedFractions lastObject], @(toPaneStatePaneClosedFraction), @"Pane closed fractions must end at toPaneStatePaneClosedFraction");
            [stateUpdateExpectation fulfill];
        }];
        XCTAssertTrue(mayUpdateToPaneStateInvoked, @"Must invoke may update to pane state");
        [self waitForExpectationsWithTimeout:2.0 handler:nil];
    };
    
    // Test transitioning between all states in all directions both animated and non-animated
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection maskedDirection) {
        for (MSDynamicsDrawerPaneState fromPaneState = MSDynamicsDrawerPaneStateClosed; fromPaneState <= MSDynamicsDrawerPaneStateOpenWide; fromPaneState++) {
            for (MSDynamicsDrawerPaneState toPaneState = MSDynamicsDrawerPaneStateClosed; toPaneState <= MSDynamicsDrawerPaneStateOpenWide; toPaneState++) {
                if (fromPaneState != toPaneState) {
                    transitionFromStateToStateForDirectionAnimated(fromPaneState, toPaneState, maskedDirection, NO);
                    transitionFromStateToStateForDirectionAnimated(fromPaneState, toPaneState, maskedDirection, YES);
                }
            }
        }
    });
}

@end
