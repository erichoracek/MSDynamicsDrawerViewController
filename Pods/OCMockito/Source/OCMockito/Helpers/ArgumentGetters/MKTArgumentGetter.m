#import "MKTArgumentGetter.h"

@interface MKTArgumentGetter (SubclassResponsibility)
- (id)getArgumentAtIndex:(NSInteger)idx ofType:(char const *)type onInvocation:(NSInvocation *)invocation;
@end

@interface MKTArgumentGetter ()
@property (nonatomic, readonly) char const *handlerType;
@property (nonatomic, readonly) MKTArgumentGetter *successor;
@end


@implementation MKTArgumentGetter


- (instancetype)initWithType:(char const *)handlerType successor:(MKTArgumentGetter *)successor
{
    self = [super init];
    if (self)
    {
        _handlerType = handlerType;
        _successor = successor;
    }
    return self;
}

- (BOOL)handlesArgumentType:(char const *)argType
{
    return argType[0] == self.handlerType[0];
}

- (id)retrieveArgumentAtIndex:(NSInteger)idx ofType:(char const *)type onInvocation:(NSInvocation *)invocation
{
    if ([self handlesArgumentType:type])
        return [self getArgumentAtIndex:idx ofType:type onInvocation:invocation];
    else
        return [self.successor retrieveArgumentAtIndex:idx ofType:type onInvocation:invocation];
}

@end
