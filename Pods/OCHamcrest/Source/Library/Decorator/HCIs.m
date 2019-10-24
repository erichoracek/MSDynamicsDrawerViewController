//
//  OCHamcrest - HCIs.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIs.h"

#import "HCWrapInMatcher.h"


@interface HCIs ()
@property (nonatomic, readonly) id <HCMatcher> matcher;
@end

@implementation HCIs

+ (instancetype)is:(id <HCMatcher>)matcher
{
    return [[self alloc] initWithMatcher:matcher];
}

- (instancetype)initWithMatcher:(id <HCMatcher>)matcher
{
    self = [super init];
    if (self)
        _matcher = matcher;
    return self;
}

- (BOOL)matches:(id)item
{
    return [self.matcher matches:item];
}

- (void)describeMismatchOf:(id)item to:(id<HCDescription>)mismatchDescription
{
    [self.matcher describeMismatchOf:item to:mismatchDescription];
}

- (void)describeTo:(id<HCDescription>)description
{
    [description appendDescriptionOf:self.matcher];
}

@end


id HC_is(id match)
{
    return [HCIs is:HCWrapInMatcher(match)];
}
