//
//  OCHamcrest - HCIsCollectionOnlyContaining.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsCollectionOnlyContaining.h"

#import "HCAnyOf.h"
#import "HCCollect.h"


@interface HCIsCollectionOnlyContaining ()
@property (nonatomic, readonly) id <HCMatcher> matcher;
@end

@implementation HCIsCollectionOnlyContaining

+ (instancetype)isCollectionOnlyContaining:(id <HCMatcher>)matcher
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

- (BOOL)matches:(id)collection
{
    if (![collection conformsToProtocol:@protocol(NSFastEnumeration)])
        return NO;
    
    if ([collection count] == 0)
        return NO;
    
    for (id item in collection)
        if (![self.matcher matches:item])
            return NO;
    return YES;
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:@"a collection containing items matching "]
                  appendDescriptionOf:self.matcher];
}

@end


id HC_onlyContains(id itemMatch, ...)
{
    va_list args;
    va_start(args, itemMatch);
    NSArray *matchers = HCCollectMatchers(itemMatch, args);
    va_end(args);

    return [HCIsCollectionOnlyContaining isCollectionOnlyContaining:[HCAnyOf anyOf:matchers]];
}
