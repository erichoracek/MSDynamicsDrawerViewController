//
//  MSPaneViewControllerTests.m
//  Tests
//
//  Created by Eric Horacek on 6/23/14.
//
//

#import <XCTest/XCTest.h>
#import <libextobjc/EXTScope.h>
#import <MSDynamicsDrawerViewController/MSDynamicsDrawerViewController.h>
#import <Aspects/Aspects.h>

@interface MSPaneViewControllerTests : XCTestCase

@property (nonatomic, strong) UIWindow *window;

@end

@implementation MSPaneViewControllerTests

- (void)testAddPaneLifecycle
{
    MSDynamicsDrawerViewController *drawerViewController = [MSDynamicsDrawerViewController new];

    self.window = [UIWindow new];
    self.window.rootViewController = drawerViewController;
    self.window.hidden = NO;

    UIViewController *paneViewController = [UIViewController new];
    
    __block NSInteger viewWillAppearInvocationCount = 0;
    [paneViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertFalse(animated, @"Must be non animated");
        viewWillAppearInvocationCount++;
    } error:NULL];
    
    __block NSInteger viewDidAppearInvocationCount = 0;
    [paneViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertFalse(animated, @"Must be non animated");
        viewDidAppearInvocationCount++;
    } error:NULL];
    
    __block NSInteger viewWillDisappearInvocationCount = 0;
    [paneViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertFalse(animated, @"Must be non animated");
        viewWillDisappearInvocationCount++;
    } error:NULL];
    
    __block NSInteger viewDidDisappearInvocationCount = 0;
    [paneViewController aspect_hookSelector:@selector(viewDidDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertFalse(animated, @"Must be non animated");
        viewDidDisappearInvocationCount++;
    } error:NULL];
    
    __block UIViewController *willMoveToViewController;
    [paneViewController aspect_hookSelector:@selector(willMoveToParentViewController:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, UIViewController *parentViewController) {
        willMoveToViewController = parentViewController;
    } error:NULL];
    
    __block UIViewController *didMoveToViewController;
    [paneViewController aspect_hookSelector:@selector(didMoveToParentViewController:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, UIViewController *parentViewController) {
        didMoveToViewController = parentViewController;
    } error:NULL];

    XCTAssertEqual(viewWillAppearInvocationCount, 0, @"Must not yet have viewWillAppear invoked");
    XCTAssertEqual(viewDidAppearInvocationCount, 0, @"Must not yet have viewDidAppear invoked");
    XCTAssertNil(willMoveToViewController, @"Must not yet have will moved to parent");
    XCTAssertNil(didMoveToViewController, @"Must not yet have did moved to parent");

    drawerViewController.paneViewController = paneViewController;

    XCTAssertEqual(viewWillAppearInvocationCount, 1, @"Must have viewWillAppear invoked once");
    XCTAssertEqual(viewDidAppearInvocationCount, 1, @"Must have viewDidAppear invoked once");
    XCTAssertEqual(viewWillDisappearInvocationCount, 0, @"Must not yet have viewWillDisappear invoked");
    XCTAssertEqual(viewDidDisappearInvocationCount, 0, @"Must not yet have viewDidDisappear invoked");
    XCTAssertEqual(willMoveToViewController, drawerViewController, @"Must have will moved to drawer view controller");
    XCTAssertEqual(didMoveToViewController, drawerViewController, @"Must have did moved to drawer view controller");
    
    XCTAssertTrue([paneViewController isViewLoaded], @"View must be loaded after pane view is added");
    
    XCTAssertEqual(paneViewController.parentViewController, drawerViewController, @"Drawer view controller should be pane's parent");
    XCTAssertTrue((drawerViewController.paneViewController == paneViewController), @"Pane view controller must be properly set on the drawer view controller");
    XCTAssertTrue([drawerViewController.childViewControllers containsObject:paneViewController], @"Drawer view controller must have pane as a child view controller");

    drawerViewController.paneViewController = nil;
    
    XCTAssertNil(willMoveToViewController, @"Must will move to nil parent");
    XCTAssertNil(didMoveToViewController, @"Must did move to nil parent");
    XCTAssertEqual(viewWillDisappearInvocationCount, 1, @"Must have viewWillDisappear invoked once");
    XCTAssertEqual(viewDidDisappearInvocationCount, 1, @"Must have viewDidDisappear invoked once");
    XCTAssertNil(drawerViewController.paneViewController, @"Setting pane view controller should set it to nil on the drawer view controller");
    
    self.window.hidden = YES;
}

- (void)testPaneReplaceLifecycle
{
    MSDynamicsDrawerViewController *drawerViewController = [MSDynamicsDrawerViewController new];
    [drawerViewController setDrawerViewController:[UIViewController new] forDirection:MSDynamicsDrawerDirectionLeft];
    
    self.window = [UIWindow new];
    self.window.rootViewController = drawerViewController;
    self.window.hidden = NO;
    
    UIViewController *oldPaneViewController = [UIViewController new];
    
    __block NSInteger oldPaneVCWillAppearInvocationCount = 0;
    [oldPaneViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertFalse(animated, @"Must be non animated");
        oldPaneVCWillAppearInvocationCount = YES;
    } error:NULL];
    
    __block NSInteger oldPaneVCDidAppearInvocationCount = 0;
    [oldPaneViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertFalse(animated, @"Must be non animated");
        oldPaneVCDidAppearInvocationCount = YES;
    } error:NULL];
    
    __block NSInteger oldPaneVCWillDisappearInvocationCount = 0;
    [oldPaneViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertTrue(animated, @"Must be animated");
        oldPaneVCWillDisappearInvocationCount++;
    } error:NULL];
    
    __block NSInteger oldPaneVCDidDisappearInvocationCount = 0;
    [oldPaneViewController aspect_hookSelector:@selector(viewDidDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertTrue(animated, @"Must be animated");
        oldPaneVCDidDisappearInvocationCount++;
    } error:NULL];
    
    drawerViewController.paneViewController = oldPaneViewController;
    
    XCTAssertEqual(oldPaneVCWillAppearInvocationCount, 1);
    XCTAssertEqual(oldPaneVCDidAppearInvocationCount, 1);
    XCTAssertEqual(oldPaneVCWillDisappearInvocationCount, 0);
    XCTAssertEqual(oldPaneVCDidDisappearInvocationCount, 0);
    
    [drawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft];
    
    XCTestExpectation *stateUpdateExpectation = [self expectationWithDescription:@"Replace pane completion"];
    
    UIViewController *newPaneViewController = [UIViewController new];
    
    __block NSInteger newPaneVCWillAppearInvocationCount = 0;
    [newPaneViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertTrue(animated, @"Must be animated");
        newPaneVCWillAppearInvocationCount = YES;
    } error:NULL];
    
    __block NSInteger newPaneVCDidAppearInvocationCount = 0;
    [newPaneViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertTrue(animated, @"Must be animated");
        newPaneVCDidAppearInvocationCount = YES;
    } error:NULL];
    
    @weakify(drawerViewController);
    [drawerViewController setPaneViewController:newPaneViewController animated:YES completion:^{
        @strongify(drawerViewController);

        XCTAssertEqual(oldPaneVCWillAppearInvocationCount, 1);
        XCTAssertEqual(oldPaneVCDidAppearInvocationCount, 1);
        XCTAssertEqual(oldPaneVCWillDisappearInvocationCount, 1);
        XCTAssertEqual(oldPaneVCDidDisappearInvocationCount, 1);
        XCTAssertNil(oldPaneViewController.parentViewController, @"Old pane should have no parent");
        
        XCTAssertEqual(newPaneVCWillAppearInvocationCount, 1);
        XCTAssertEqual(newPaneVCDidAppearInvocationCount, 1);
        XCTAssertEqual(drawerViewController, newPaneViewController.parentViewController, @"New pane should have drawer as parent");
        
        [stateUpdateExpectation fulfill];
    }];
    
    XCTAssertEqual(oldPaneVCWillDisappearInvocationCount, 1, @"Will disappear must be invoked directly following setting the new view controller");
    XCTAssertEqual(oldPaneVCDidDisappearInvocationCount, 0, @"Did disappear must not yet be invoked directly following setting the new view controller");
    
    XCTAssertEqual(newPaneVCWillAppearInvocationCount, 0, @"Will appear must not yet be invoked");
    XCTAssertEqual(newPaneVCDidAppearInvocationCount, 0, @"Did appear must not yet be invoked");
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
//    XCTAssertTrue([self waitFor:&done timeout:2.0], @"Timed out waiting for response asynch method completion");
}

@end
