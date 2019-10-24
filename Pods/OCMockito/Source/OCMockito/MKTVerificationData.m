//
//  OCMockito - MKTVerificationData.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTVerificationData.h"

#import "MKTInvocationContainer.h"
#import "MKTInvocationMatcher.h"


@implementation MKTVerificationData

- (NSUInteger)numberOfMatchingInvocations
{
    NSUInteger count = 0;
    for (NSInvocation *invocation in self.invocations.registeredInvocations)
    {
        if ([self.wanted matches:invocation])
            ++count;
    }
    return count;
}

- (void)captureArguments
{
    [self.wanted captureArgumentsFromInvocations:self.invocations.registeredInvocations];
}

@end
