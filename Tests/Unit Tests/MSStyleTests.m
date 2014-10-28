//
//  MSStyleTests.m
//  Tests
//
//  Created by Eric Horacek on 6/22/14.
//
//

#import <XCTest/XCTest.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerHelperFunctions.h>
#import <Aspects/Aspects.h>
#import <libextobjc/EXTScope.h>

@interface MSTestStyle : NSObject <MSDynamicsDrawerStyle>

@end

@implementation MSTestStyle

- (void)willMoveToDynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController forDirection:(MSDynamicsDrawerDirection)direction { }
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController mayUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction { }
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)paneState forDirection:(MSDynamicsDrawerDirection)direction { }
- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)drawerViewController didUpdatePaneClosedFraction:(CGFloat)paneClosedFraction forDirection:(MSDynamicsDrawerDirection)direction { }

@end

@interface MSStyleTests : XCTestCase

@property (nonatomic, strong) MSDynamicsDrawerViewController *drawerViewController;

@end

@implementation MSStyleTests

- (void)testStyleLifecycleWindowRootViewController
{
    void(^testStyleLifecycleForDirection)(MSDynamicsDrawerDirection direction) = ^(MSDynamicsDrawerDirection direction) {
        
        __block NSInteger invocationCount = 0;
        MSDynamicsDrawerDirectionActionForMaskedValues(direction, ^(MSDynamicsDrawerDirection maskedDirection) {
            invocationCount++;
        });
        
        UIWindow *window = [UIWindow new];
        MSDynamicsDrawerViewController *drawerViewController = [MSDynamicsDrawerViewController new];
        window.rootViewController = drawerViewController;
        // Show the window (with the drawer as root view controller)
        window.hidden = NO;
        
        MSTestStyle *testStyle = [MSTestStyle new];
        
        __block BOOL willMoveInvoked = NO;
        __block NSInteger willMoveInvocationCount = 0;
        __block MSDynamicsDrawerDirection willMoveDirection = MSDynamicsDrawerDirectionNone;
        
        @weakify(drawerViewController);
        id <AspectToken> willMoveToken = [testStyle aspect_hookSelector:@selector(willMoveToDynamicsDrawerViewController:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *styleDrawerViewController, MSDynamicsDrawerDirection styleDirection) {
            @strongify(drawerViewController);
            XCTAssertEqual(drawerViewController, styleDrawerViewController, @"Must be called with correct drawer");
            XCTAssertTrue((direction & styleDirection), @"Must be called with a correct direction");
            XCTAssertTrue([drawerViewController isViewLoaded], @"Drawer view controller view must be loaded at this point");
            XCTAssertTrue(drawerViewController.view.window, @"Drawer view controller view have window at this point");
            willMoveInvoked = YES;
            willMoveInvocationCount++;
            willMoveDirection |= styleDirection;
        } error:NULL];
        
        [drawerViewController addStyle:testStyle forDirection:direction];

        XCTAssertTrue(willMoveInvoked, @"Style must be added when the view has been loaded");
        XCTAssertEqual(willMoveInvocationCount, invocationCount, @"Style must be added individually for each direction it's added for");
        XCTAssertEqual(willMoveDirection, direction, @"Style must be added individually for each direction it's added for");
        
        [willMoveToken remove];
        
        willMoveInvoked = NO;
        willMoveInvocationCount = 0;
        willMoveDirection = MSDynamicsDrawerDirectionNone;
        
        [testStyle aspect_hookSelector:@selector(willMoveToDynamicsDrawerViewController:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *styleDrawerViewController, MSDynamicsDrawerDirection styleDirection) {
            @strongify(drawerViewController);
            XCTAssertNil(styleDrawerViewController, @"Must be called with nil drawer");
            XCTAssertTrue((direction & styleDirection), @"Must be called with a correct direction");
            XCTAssertTrue([drawerViewController isViewLoaded], @"Drawer view controller view must be loaded at this point");
            XCTAssertNil(drawerViewController.view.window, @"Drawer view controller view must have nil window at this point");
            willMoveInvoked = YES;
            willMoveInvocationCount++;
            willMoveDirection |= styleDirection;
        } error:NULL];

        // Remove the view controller
        window.hidden = YES;
        window.rootViewController = nil;
        
        XCTAssertTrue(willMoveInvoked, @"Style must be added when the view has been unloaded");
        XCTAssertEqual(willMoveInvocationCount, invocationCount, @"Style must be added individually for each direction it's added for");
        XCTAssertEqual(willMoveDirection, direction, @"Style must be added individually for each direction it's added for");
    };
    
    // Test for all values individually
    MSDynamicsDrawerDirectionActionForMaskedValues(MSDynamicsDrawerDirectionAll, ^(MSDynamicsDrawerDirection direction) {
        testStyleLifecycleForDirection(direction);
    });
    
    // Test for masked values
    testStyleLifecycleForDirection(MSDynamicsDrawerDirectionAll);
    testStyleLifecycleForDirection(MSDynamicsDrawerDirectionHorizontal);
    testStyleLifecycleForDirection(MSDynamicsDrawerDirectionVertical);
    testStyleLifecycleForDirection(MSDynamicsDrawerDirectionTop | MSDynamicsDrawerDirectionLeft | MSDynamicsDrawerDirectionRight);
}

- (void)testStyleLifecycleDrawerStates
{
    void(^transitionFromStateToStateForDirectionAnimated)(MSDynamicsDrawerPaneState, MSDynamicsDrawerPaneState, MSDynamicsDrawerDirection, BOOL) = ^(MSDynamicsDrawerPaneState fromPaneSate, MSDynamicsDrawerPaneState toPaneState, MSDynamicsDrawerDirection direction, BOOL animated) {
        
        UIWindow *window = [UIWindow new];
        self.drawerViewController = [MSDynamicsDrawerViewController new];
        window.rootViewController = self.drawerViewController;
        
        UIViewController *rightDrawerViewController = [UIViewController new];
        [self.drawerViewController setDrawerViewController:rightDrawerViewController forDirection:direction];
        
        UIViewController *paneViewController = [UIViewController new];
        self.drawerViewController.paneViewController = paneViewController;
        
        self.drawerViewController.paneState = fromPaneSate;
        
        MSTestStyle *style = [MSTestStyle new];
        MSTestStyle *oppositeDirectionStyle = [MSTestStyle new];
        
        __block BOOL mayUpdateToPaneStateInvoked = NO;
        id <AspectToken> mayUpdateToPaneStateToken = [MSTestStyle aspect_hookSelector:@selector(dynamicsDrawerViewController:mayUpdateToPaneState:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *styleDrawerViewController, MSDynamicsDrawerPaneState stylePaneState, MSDynamicsDrawerDirection styleDirection) {
            XCTAssertEqual([aspectInfo instance], style, @"Must only be invoked for style");
            XCTAssertEqual(self.drawerViewController, styleDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(stylePaneState, toPaneState, @"Must be called with correct pane state");
            XCTAssertEqual(styleDirection, direction, @"Must be in correct direction");
            mayUpdateToPaneStateInvoked = YES;
        } error:NULL];
        
        __block BOOL didUpdatePaneClosedFractionInvoked = NO;
        NSMutableArray *paneClosedFractions = [NSMutableArray new];
        id <AspectToken> didUpdatePaneClosedFractionToken = [MSTestStyle aspect_hookSelector:@selector(dynamicsDrawerViewController:didUpdatePaneClosedFraction:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *styleDrawerViewController, CGFloat paneClosedFraction, MSDynamicsDrawerDirection styleDirection) {
            XCTAssertEqual([aspectInfo instance], style, @"Must only be invoked for style");
            XCTAssertEqual(self.drawerViewController, styleDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(styleDirection, direction, @"Must be in correct direction");
            XCTAssertTrue(mayUpdateToPaneStateInvoked, @"May update to pane state must be invoked before paneClosedFraction");
            [paneClosedFractions addObject:@(paneClosedFraction)];
            didUpdatePaneClosedFractionInvoked = YES;
        } error:NULL];
        
        __block BOOL didUpdateToPaneStateInvoked = NO;
        id <AspectToken> didUpdateToPaneStateToken = [MSTestStyle aspect_hookSelector:@selector(dynamicsDrawerViewController:didUpdateToPaneState:forDirection:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, MSDynamicsDrawerViewController *styleDrawerViewController, MSDynamicsDrawerPaneState stylePaneState, MSDynamicsDrawerDirection styleDirection) {
            XCTAssertEqual([aspectInfo instance], style, @"Must only be invoked for test style");
            XCTAssertEqual(self.drawerViewController, styleDrawerViewController, @"Must be called with correct drawer view controller");
            XCTAssertEqual(stylePaneState, toPaneState, @"Must be called with correct pane state");
            XCTAssertEqual(styleDirection, direction, @"Must be in correct direction");
            XCTAssertTrue(didUpdatePaneClosedFractionInvoked, @"Must be invoked after didUpdatePaneClosedFraction");
            didUpdateToPaneStateInvoked = YES;
        } error:NULL];
        
        MSDynamicsDrawerDirection(^oppositeDirection)(MSDynamicsDrawerDirection) = ^(MSDynamicsDrawerDirection ofDirection) {
            switch ((NSInteger)ofDirection) {
            case MSDynamicsDrawerDirectionTop:
                return MSDynamicsDrawerDirectionBottom;
            case MSDynamicsDrawerDirectionLeft:
                return MSDynamicsDrawerDirectionRight;
            case MSDynamicsDrawerDirectionBottom:
                return MSDynamicsDrawerDirectionTop;
            case MSDynamicsDrawerDirectionRight:
                return MSDynamicsDrawerDirectionLeft;
            }
            return (MSDynamicsDrawerDirection)-1;
        };
        
        [self.drawerViewController addStyle:oppositeDirectionStyle forDirection:oppositeDirection(direction)];
        [self.drawerViewController addStyle:style forDirection:direction];
        
        // Show the window (with the drawer as the rootViewController)
        window.hidden = NO;

        XCTestExpectation *stateUpdateExpectation = [self expectationWithDescription:@"Update Pane State"];
        @weakify(self);
        [self.drawerViewController setPaneState:toPaneState animated:animated allowUserInterruption:NO completion:^{
            @strongify(self);
            XCTAssertTrue(didUpdateToPaneStateInvoked, @"Must invoke did update to pane state");
            CGPoint fromPaneStatePaneCenter = [self.drawerViewController.paneLayout paneCenterForPaneState:fromPaneSate direction:direction];
            CGFloat fromPaneStatePaneClosedFraction = [self.drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:fromPaneStatePaneCenter forDirection:direction];
            XCTAssertEqualObjects([paneClosedFractions firstObject], @(fromPaneStatePaneClosedFraction), @"Pane closed fractions must start at fromPaneStatePaneClosedFraction");
            CGPoint toPaneStatePaneCenter = [self.drawerViewController.paneLayout paneCenterForPaneState:toPaneState direction:direction];
            CGFloat toPaneStatePaneClosedFraction = [self.drawerViewController.paneLayout paneClosedFractionForPaneWithCenter:toPaneStatePaneCenter forDirection:direction];
            XCTAssertEqualObjects([paneClosedFractions lastObject], @(toPaneStatePaneClosedFraction), @"Pane closed fractions must end at toPaneStatePaneClosedFraction");
            [stateUpdateExpectation fulfill];
        }];
        XCTAssertTrue(mayUpdateToPaneStateInvoked, @"Must invoke may update to pane state immedately after setPaneState:");
        
        [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *error) {
            [mayUpdateToPaneStateToken remove];
            [didUpdatePaneClosedFractionToken remove];
            [didUpdateToPaneStateToken remove];
        }];
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
