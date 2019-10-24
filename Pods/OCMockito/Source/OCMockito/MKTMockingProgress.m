//
//  OCMockito - MKTMockingProgress.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTMockingProgress.h"

#import "MKTInvocationMatcher.h"
#import "MKTOngoingStubbing.h"
#import "MKTVerificationMode.h"


@implementation MKTMockingProgress
{
    MKTInvocationMatcher *_invocationMatcher;
    id <MKTVerificationMode> _verificationMode;
    MKTOngoingStubbing *_ongoingStubbing;
}

+ (instancetype)sharedProgress
{
    static id sharedProgress = nil;
    if (!sharedProgress)
        sharedProgress = [[self alloc] init];
    return sharedProgress;
}

- (void)reset
{
    _invocationMatcher = nil;
    _verificationMode = nil;
    _ongoingStubbing = nil;
}

- (void)stubbingStartedAtLocation:(MKTTestLocation)location
{
    [self setTestLocation:location];
}

- (void)reportOngoingStubbing:(MKTOngoingStubbing *)ongoingStubbing
{
    _ongoingStubbing = ongoingStubbing;
}

- (MKTOngoingStubbing *)pullOngoingStubbing
{
    MKTOngoingStubbing *result = _ongoingStubbing;
    _ongoingStubbing = nil;
    return result;
}

- (void)verificationStarted:(id <MKTVerificationMode>)mode atLocation:(MKTTestLocation)location
{
    _verificationMode = mode;
    [self setTestLocation:location];
}

- (id <MKTVerificationMode>)pullVerificationMode
{
    id <MKTVerificationMode> result = _verificationMode;
    _verificationMode = nil;
    return result;
}

- (void)setMatcher:(id <HCMatcher>)matcher forArgument:(NSUInteger)index
{
    if (!_invocationMatcher)
        _invocationMatcher = [[MKTInvocationMatcher alloc] init];
    [_invocationMatcher setMatcher:matcher atIndex:index];
}

- (MKTInvocationMatcher *)pullInvocationMatcher
{
    MKTInvocationMatcher *result = _invocationMatcher;
    _invocationMatcher = nil;
    return result;
}

@end
