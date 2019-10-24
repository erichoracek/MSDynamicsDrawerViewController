//
//  OCHamcrest - HCHasDescription.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCHasDescription.h"

#import "HCWrapInMatcher.h"
#import "NSInvocation+OCHamcrest.h"


@implementation HCHasDescription

+ (instancetype)hasDescription:(id <HCMatcher>)descriptionMatcher
{
    return [[self alloc] initWithDescription:descriptionMatcher];
}

- (instancetype)initWithDescription:(id <HCMatcher>)descriptionMatcher
{
    NSInvocation *anInvocation = [NSInvocation och_invocationOnObjectOfType:[NSObject class]
                                                                   selector:@selector(description)];
    self = [super initWithInvocation:anInvocation matching:descriptionMatcher];
    if (self)
        self.shortMismatchDescription = YES;
    return self;
}

@end


id HC_hasDescription(id match)
{
    return [HCHasDescription hasDescription:HCWrapInMatcher(match)];
}
