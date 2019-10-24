//
//  OCHamcrest - HCAnyOf.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCAnyOf.h"

#import "HCCollect.h"


@interface HCAnyOf ()
@property (nonatomic, readonly) NSArray *matchers;
@end

@implementation HCAnyOf

+ (instancetype)anyOf:(NSArray *)matchers
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
    for (id <HCMatcher> oneMatcher in self.matchers)
        if ([oneMatcher matches:item])
            return YES;
    return NO;
}

- (void)describeTo:(id<HCDescription>)description
{
    [description appendList:self.matchers start:@"(" separator:@" or " end:@")"];
}

@end


id HC_anyOf(id match, ...)
{
    va_list args;
    va_start(args, match);
    NSArray *matcherList = HCCollectMatchers(match, args);
    va_end(args);
    
    return [HCAnyOf anyOf:matcherList];
}
