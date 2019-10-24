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

@end

@implementation MSPaneViewControllerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!*flag);
    return *flag;
}

//- (void)testAddPaneLifecycle
//{
//    MSDynamicsDrawerViewController *drawerViewController = [MSDynamicsDrawerViewController new];
//    
//    UIWindow *window = [UIWindow new];
//    window.rootViewController = drawerViewController;
//    window.hidden = NO;
//    
//    MSTestViewController *paneViewController = [MSTestViewController new];
//
//    XCTAssertEqual(paneViewController.viewWillAppearCount, 0, @"Must not yet have viewWillAppear invoked");
//    XCTAssertEqual(paneViewController.viewDidAppearCount, 0, @"Must not yet have viewDidAppear invoked");
//    
//    drawerViewController.paneViewController = paneViewController;
//    
//    XCTAssertEqual(paneViewController.viewWillAppearCount, 1, @"Must have viewWillAppear invoked once");
//    XCTAssertEqual(paneViewController.viewDidAppearCount, 1, @"Must have viewDidAppear invoked once");
//    XCTAssertEqual(paneViewController.viewDidDisappearCount, 0, @"Must not yet have viewWillDisappear invoked");
//    XCTAssertEqual(paneViewController.viewDidDisappearCount, 0, @"Must not yet have viewDidDisappear invoked");
//    
//    XCTAssertEqual(paneViewController.willMoveToParentViewController, drawerViewController, @"Drawer view controller must will be moved to parent");
//    XCTAssertEqual(paneViewController.didMoveToParentViewController, drawerViewController, @"Drawer view controller must did move to parent");
//    XCTAssertEqual(drawerViewController, paneViewController.parentViewController, @"Drawer view controller should be pane's parent");
//    
//    XCTAssertTrue([drawerViewController.paneViewController isViewLoaded], @"View must be loaded after pane view is added");
//    XCTAssertTrue(drawerViewController.paneViewController == paneViewController, @"Pane view controller must be properly set on the drawer view controller");
//    XCTAssertNotEqual([drawerViewController.childViewControllers indexOfObjectIdenticalTo:paneViewController], NSNotFound, @"Drawer view controller must have pane as a child view controller");
//    
//    drawerViewController.paneViewController = nil;
//    
//    XCTAssertEqual(paneViewController.viewDidDisappearCount, 1, @"Must have viewWillDisappear invoked once");
//    XCTAssertEqual(paneViewController.viewDidDisappearCount, 1, @"Must have viewDidDisappear invoked once");
//    
//    XCTAssertNil(drawerViewController.paneViewController, @"Setting pane view controller should set it to nil on the drawer view controller");
//}

- (void)testReplacePaneLifecycleAnimated
{
    MSDynamicsDrawerViewController *drawerViewController = [MSDynamicsDrawerViewController new];
    
    UIWindow *window = [UIWindow new];
    window.rootViewController = drawerViewController;
    window.hidden = NO;
    
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
    
//    [drawerViewController setDrawerViewController:[UIViewController new] forDirection:MSDynamicsDrawerDirectionLeft];
//    [drawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft];
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

@end
