# TPWeakProxy

An NSProxy object for turning strong references into weak references.

## Usage

    // Create a weak proxy to the object which you would like to be weakly referenced.
    // For example, self.

    TPWeakProxy *proxy = [[TPWeakProxy alloc] initWithObject:self];
    
    // Now, you can use proxy anywhere you'd normally use self,
    // except that self will have a weak reference to it where you use the proxy.
    
    // As an example, NSTimer maintains a strong reference to its target. Sometimes
    // this isn't what you want.

    NSTimer *myWeakRefTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                               target:proxy
                                                             selector:@selector(myWeakRefTimerFired:)
                                                             userInfo:nil
                                                              repeats:NO];
                                                              
## Installation

Easiest way: use Cocoapods. Otherwise, copy the .h and .m into your project.

    $ edit Podfile
    platform :ios, '6.1'
    pod 'TPWeakProxy', '~> 1.0.0'
    
    $ pod install
    
    $ open App.xcworkspace
    
## Motivation

TPWeakProxy solves the problem of object reference loops in Objective C. Reference loops can occur when an instantiated object keeps a strong reference to the object by which it was instantiated - making it impossible for the first object to be deallocated while the second object continues to exist.

This can be a problem in the fairly common iOS pattern of using NSTimers. 

For example, let's say you have a UIViewController which wants to trigger a refresh event. The naive approach:

    @interface

    @property (strong, non-atomic) NSTimer *myTimer;
    
    @end

    @implementation
    
    -(void)dealloc {
        [self.myTimer invalidate];
    }
    
    -(void)viewDidLoad {
        [super viewDidLoad];
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                        target:self
                                                      selector:@selector(myTimerFired:)
                                                      userInfo:nil
                                                       repeats:NO];
     }

    @end
    
This has a problem: NSTimer has a strong reference to target:, and the
target has a strong reference to the NSTimer (via the myTimer
property). Now we have a reference loop, and therefor we have a memory leak.

We can start to fix that pretty easily; the NSTimer is strongly referenced by
the NSRunLoop object it's associated with, so the UIViewController which created it 
can change its reference to be weak:

    @property (weak, non-atomic) NSTimer *myTimer;
    
Yay! Now we don't have a memory leak any more, but we still have a
problem. Since the NSTimer has a strong reference to the
UIViewController, we don't actually dealloc the view controller until
after the NSTimer has fired. If your NSTimer is going to fire a long
time from now, that at least wastes resources, and may actually cause
subtle bugs. Unfortunately, the NSTimer API has been essentially 
unchanged for over two decades; it's not likely
Apple will provide an NSTimer with a weak reference to its target any
time soon. So we fix it with TPWeakProxy, like so:

    -(void)viewDidLoad {
        [super viewDidLoad];
        TPWeakProxy *proxy = [[TPWeakProxy alloc] initWithObject:self];
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                        target:proxy
                                                      selector:@selector(myTimerFired:)
                                                      userInfo:nil
                                                       repeats:NO];
     }

Now, the NSTimer won't prevent the UIViewController from being
dealloc'd when it's popped off the stack, and the dealloc() will now
invalidate the timer correctly.

## License

TPWeakProxy is available under the MIT license. See the LICENSE file for more info.
