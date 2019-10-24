//
//  OCMockito - MKTReturnValueSetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTReturnValueSetter.h"


@interface MKTReturnValueSetter (SubclassResponsibility)
- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation;
@end

@interface MKTReturnValueSetter ()
@property (nonatomic, readonly) char const *handlerType;
@property (nonatomic, readonly) MKTReturnValueSetter *successor;
@end


@implementation MKTReturnValueSetter

- (instancetype)initWithType:(char const *)handlerType successor:(MKTReturnValueSetter *)successor
{
    self = [super init];
    if (self)
    {
        _handlerType = handlerType;
        _successor = successor;
    }
    return self;
}

- (BOOL)handlesReturnType:(char const *)returnType
{
    return returnType[0] == self.handlerType[0];
}

- (void)setReturnValue:(id)returnValue ofType:(char const *)type onInvocation:(NSInvocation *)invocation
{
    if ([self handlesReturnType:type])
        [self setReturnValue:returnValue onInvocation:invocation];
    else
        [self.successor setReturnValue:returnValue ofType:type onInvocation:invocation];
}

@end
