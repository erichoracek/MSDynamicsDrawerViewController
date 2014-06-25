//
//  OCMockito - MKTBaseMockObject.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTBaseMockObject.h"

#import "MKTInvocationContainer.h"
#import "MKTInvocationMatcher.h"
#import "MKTMockingProgress.h"
#import "MKTOngoingStubbing.h"
#import "MKTStubbedInvocationMatcher.h"
#import "MKTVerificationData.h"
#import "MKTVerificationMode.h"
#import "NSInvocation+OCMockito.h"


@implementation MKTBaseMockObject
{
    MKTMockingProgress *_mockingProgress;
    MKTInvocationContainer *_invocationContainer;
}

- (instancetype)init
{
    if (self)
    {
        _mockingProgress = [MKTMockingProgress sharedProgress];
        _invocationContainer = [[MKTInvocationContainer alloc] init];
    }
    return self;
}

- (void)reset
{
    [_mockingProgress reset];
    _invocationContainer = [[MKTInvocationContainer alloc] init];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([self handlingVerifyOfInvocation:invocation])
        return;
    [self prepareInvocationForStubbing:invocation];
    [self answerInvocation:invocation];
}

- (BOOL)handlingVerifyOfInvocation:(NSInvocation *)invocation
{
    id <MKTVerificationMode> verificationMode = [_mockingProgress pullVerificationMode];
    if (verificationMode)
        [self verifyInvocation:invocation usingVerificationMode:verificationMode];
    return verificationMode != nil;
 }

- (void)verifyInvocation:(NSInvocation *)invocation usingVerificationMode:(id <MKTVerificationMode>)verificationMode
{
    MKTInvocationMatcher *invocationMatcher = [self matcherWithInvocation:invocation];
    MKTVerificationData *data = [self verificationDataWithMatcher:invocationMatcher];
    [data captureArguments];
    [verificationMode verifyData:data];
}

- (MKTInvocationMatcher *)matcherWithInvocation:(NSInvocation *)invocation
{
    MKTInvocationMatcher *invocationMatcher = [_mockingProgress pullInvocationMatcher];
    if (!invocationMatcher)
        invocationMatcher = [[MKTInvocationMatcher alloc] init];
    [invocationMatcher setExpectedInvocation:invocation];
    return invocationMatcher;
}

- (MKTVerificationData *)verificationDataWithMatcher:(MKTInvocationMatcher *)invocationMatcher
{
    MKTVerificationData *data = [[MKTVerificationData alloc] init];
    data.invocations = _invocationContainer;
    data.wanted = invocationMatcher;
    data.testLocation = _mockingProgress.testLocation;
    return data;
}

- (void)prepareInvocationForStubbing:(NSInvocation *)invocation
{
    [_invocationContainer setInvocationForPotentialStubbing:invocation];
    MKTOngoingStubbing *ongoingStubbing = [[MKTOngoingStubbing alloc] initWithInvocationContainer:_invocationContainer];
    [_mockingProgress reportOngoingStubbing:ongoingStubbing];
}

- (void)answerInvocation:(NSInvocation *)invocation
{
    MKTStubbedInvocationMatcher *stubbedInvocation = [_invocationContainer findAnswerFor:invocation];
    if (stubbedInvocation)
        [self useExistingAnswerInStub:stubbedInvocation forInvocation:invocation];
}

- (void)useExistingAnswerInStub:(MKTStubbedInvocationMatcher *)stub forInvocation:(NSInvocation *)invocation
{
    [invocation mkt_setReturnValue:stub.answer];
}


#pragma mark MKTPrimitiveArgumentMatching

- (id)withMatcher:(id <HCMatcher>)matcher forArgument:(NSUInteger)index
{
    [_mockingProgress setMatcher:matcher forArgument:index];
    return self;
}

- (id)withMatcher:(id <HCMatcher>)matcher
{
    return [self withMatcher:matcher forArgument:0];
}

@end
