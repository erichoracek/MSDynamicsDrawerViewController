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
    
    self.window = [UIWindow new];
    self.window.rootViewController = drawerViewController;
    self.window.hidden = NO;
    
    UIViewController *oldPaneViewController = [UIViewController new];
    UIViewController *newPaneViewController = [UIViewController new];
    
    __block BOOL willAppearInvoked = NO;
    [oldPaneViewController aspect_hookSelector:@selector(viewWillAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertFalse(animated, @"Must be non animated");
        willAppearInvoked = YES;
    } error:NULL];
    
    __block BOOL didAppearInvoked = NO;
    [oldPaneViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo, BOOL animated) {
        XCTAssertFalse(animated, @"Must be non animated");
        didAppearInvoked = YES;
    } error:NULL];
    
    drawerViewController.paneViewController = oldPaneViewController;
    
    XCTAssertTrue(willAppearInvoked, @"Must call will appear");
    XCTAssertTrue(didAppearInvoked, @"Must call did appear");
    
    [drawerViewController setDrawerViewController:[UIViewController new] forDirection:MSDynamicsDrawerDirectionLeft];
    [drawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft];
//
//    __block BOOL done = NO;
//    
//    @weakify(drawerViewController);
//    [drawerViewController setPaneViewController:newPaneViewController animated:YES completion:^{
//        @strongify(drawerViewController);
//        
//        XCTAssertEqual(oldPaneViewController.viewWillDisappearCount, 1, @"Must have viewWillDisappear invoked once");
//        XCTAssertEqual(oldPaneViewController.viewDidDisappearCount, 1, @"Must have viewWillDisappear invoked once");
//        XCTAssertNil(oldPaneViewController.willMoveToParentViewController, @"Old pane must will be moved to nil parent");
//        XCTAssertNil(oldPaneViewController.didMoveToParentViewController, @"Old pane must did move to nil parent");
//        XCTAssertNil(oldPaneViewController.parentViewController, @"Old pane should have no parent");
//        
//        XCTAssertEqual(newPaneViewController.viewWillAppearCount, 1, @"Must not yet have viewwillAppear invoked");
//        XCTAssertEqual(newPaneViewController.viewDidAppearCount, 1, @"Must not yet have viewDidAppear invoked");
//        XCTAssertEqual(newPaneViewController.willMoveToParentViewController, drawerViewController, @"New pane must will be moved to drawer parent");
//        XCTAssertEqual(newPaneViewController.didMoveToParentViewController, drawerViewController, @"New pane must did move to drawer parent");
//        XCTAssertEqual(drawerViewController, newPaneViewController.parentViewController, @"New pane should have drawer as parent");
//        XCTAssertNotEqual([drawerViewController.childViewControllers indexOfObjectIdenticalTo:newPaneViewController], NSNotFound, @"Drawer view controller must have new pane as a child view controller");
//        
//        done = YES;
//    }];
//    
//    XCTAssertTrue([self waitFor:&done timeout:2.0], @"Timed out waiting for response asynch method completion");
}

- (void)testDrawerOpenLifecycle
{
    
}

@end
