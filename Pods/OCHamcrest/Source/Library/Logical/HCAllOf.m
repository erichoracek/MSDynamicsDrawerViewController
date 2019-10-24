//
//  OCHamcrest - HCAllOf.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCAllOf.h"

#import "HCCollect.h"


@interface HCAllOf ()
@property (nonatomic, readonly) NSArray *matchers;
@end

@implementation HCAllOf

+ (instancetype)allOf:(NSArray *)matchers
{
    return [[self alloc] initWithMatchers:matchers];
}

- (instancetype)initWithMatchers:(NSArray *)matchers
{
    self = [super init];
    if (self)
        _matchers = [matchers copy];
    return self;
}

- (BOOL)matches:(id)item
{
    return [self matches:item describingMismatchTo:nil];
}

- (BOOL)matches:(id)item describingMismatchTo:(id<HCDescription>)mismatchDescription
{
    for (id <HCMatcher> oneMatcher in self.matchers)
    {
        if (![oneMatcher matches:item])
        {
            [[mismatchDescription appendDescriptionOf:oneMatcher] appendText:@" "];
            [oneMatcher describeMismatchOf:item to:mismatchDescription];
            return NO;
        }
    }
    return YES;
}

- (void)describeMismatchOf:(id)item to:(id<HCDescription>)mismatchDescription
{
    [self matches:item describingMismatchTo:mismatchDescription];
}

- (void)describeTo:(id<HCDescription>)description
{
    [description appendList:self.matchers start:@"(" separator:@" and " end:@")"];
}

@end


id HC_allOf(id match, ...)
{
    va_list args;
    va_start(args, match);
    NSArray *matcherList = HCCollectMatchers(match, args);
    va_end(args);
    
    return [HCAllOf allOf:matcherList];
}
