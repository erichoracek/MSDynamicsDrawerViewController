//
//  OCMockito - MKTInvocationContainer.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTInvocationContainer.h"

#import "MKTStubbedInvocationMatcher.h"
#import "NSInvocation+OCMockito.h"


@implementation MKTInvocationContainer
{
    MKTStubbedInvocationMatcher *_invocationForStubbing;
    NSMutableArray *_stubbed;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _registeredInvocations = [[NSMutableArray alloc] init];
        _stubbed = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)setInvocationForPotentialStubbing:(NSInvocation *)invocation
{
    [invocation mkt_retainArgumentsWithWeakTarget];
    [_registeredInvocations addObject:invocation];
    
    MKTStubbedInvocationMatcher *s = [[MKTStubbedInvocationMatcher alloc] init];
    [s setExpectedInvocation:invocation];
    _invocationForStubbing = s;
}

- (void)setMatcher:(id <HCMatcher>)matcher atIndex:(NSUInteger)argumentIndex
{
    [_invocationForStubbing setMatcher:matcher atIndex:argumentIndex];
}

- (void)addAnswer:(id)answer
{
    [_registeredInvocations removeLastObject];

    _invocationForStubbing.answer = answer;
    [_stubbed insertObject:_invocationForStubbing atIndex:0];
}

- (MKTStubbedInvocationMatcher *)findAnswerFor:(NSInvocation *)invocation
{
    for (MKTStubbedInvocationMatcher *s in _stubbed)
        if ([s matches:invocation])
            return s;
    return nil;
}

@end
