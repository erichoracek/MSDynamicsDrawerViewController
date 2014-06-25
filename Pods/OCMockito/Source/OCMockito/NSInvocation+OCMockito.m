//
//  OCMockito - NSInvocation+OCMockito.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "NSInvocation+OCMockito.h"

#import "MKTArgumentGetter.h"
#import "MKTArgumentGetterChain.h"
#import "MKTReturnValueSetter.h"
#import "MKTReturnValueSetterChain.h"
#import "TPWeakProxy.h"


@implementation NSInvocation (OCMockito)

- (NSArray *)mkt_arguments
{
    NSMethodSignature *signature = [self methodSignature];
    NSUInteger numberOfArguments = [signature numberOfArguments];
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:numberOfArguments - 2];

    for (NSUInteger idx = 2; idx < numberOfArguments; ++idx) // Indices 0 and 1 are self and _cmd
    {
        const char *argType = [signature getArgumentTypeAtIndex:idx];
        id arg = [MKTArgumentGetterChain() retrieveArgumentAtIndex:idx ofType:argType onInvocation:self];
        if (arg)
            [arguments addObject:arg];
        else
        {
            NSLog(@"mkt_arguments unhandled type: %s", argType);
            [arguments addObject:[NSNull null]];
        }
    }

    return arguments;
}

- (void)mkt_setReturnValue:(id)returnValue
{
    char const *returnType = [[self methodSignature] methodReturnType];
    [MKTReturnValueSetterChain() setReturnValue:returnValue ofType:returnType onInvocation:self];
}

- (void)mkt_retainArgumentsWithWeakTarget
{
    if ([self argumentsRetained])
        return;
    TPWeakProxy *proxy = [[TPWeakProxy alloc] initWithObject:[self target]];
    [self setTarget:proxy];
    [self retainArguments];
}

@end
