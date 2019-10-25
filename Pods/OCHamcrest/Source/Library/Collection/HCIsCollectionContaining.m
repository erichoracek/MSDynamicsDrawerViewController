//
//  OCHamcrest - HCIsCollectionContaining.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsCollectionContaining.h"

#import "HCAllOf.h"
#import "HCCollect.h"
#import "HCRequireNonNilObject.h"
#import "HCWrapInMatcher.h"


@interface HCIsCollectionContaining ()
@property (nonatomic, readonly) id <HCMatcher> elementMatcher;
@end

@implementation HCIsCollectionContaining


+ (instancetype)isCollectionContaining:(id <HCMatcher>)elementMatcher
{
    return [[self alloc] initWithMatcher:elementMatcher];
}

- (instancetype)initWithMatcher:(id <HCMatcher>)elementMatcher
{
    self = [super init];
    if (self)
        _elementMatcher = elementMatcher;
    return self;
}

- (BOOL)matches:(id)collection
{
    if (![collection conformsToProtocol:@protocol(NSFastEnumeration)])
        return NO;
        
    for (id item in collection)
        if ([self.elementMatcher matches:item])
            return YES;
    return NO;
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:@"a collection containing "]
                  appendDescriptionOf:self.elementMatcher];
}

@end


id HC_hasItem(id itemMatch)
{
    HCRequireNonNilObject(itemMatch);
    return [HCIsCollectionContaining isCollectionContaining:HCWrapInMatcher(itemMatch)];
}

id HC_hasItems(id itemMatch, ...)
{
    va_list args;
    va_start(args, itemMatch);
    NSArray *matchers = HCCollectWrappedItems(itemMatch, args, HC_hasItem);
    va_end(args);

    return [HCAllOf allOf:matchers];
}
