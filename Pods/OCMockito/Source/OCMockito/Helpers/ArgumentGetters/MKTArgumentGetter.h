#import <Foundation/Foundation.h>


@interface MKTArgumentGetter : NSObject

- (instancetype)initWithType:(char const *)handlerType successor:(MKTArgumentGetter *)successor;
- (id)retrieveArgumentAtIndex:(NSInteger)idx ofType:(char const *)type onInvocation:(NSInvocation *)invocation;

@end
