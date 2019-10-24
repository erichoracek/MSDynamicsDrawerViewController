//
//  OCHamcrest - HCIsDictionaryContainingKey.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsDictionaryContainingKey.h"

#import "HCRequireNonNilObject.h"
#import "HCWrapInMatcher.h"


@interface HCIsDictionaryContainingKey ()
@property (nonatomic, readonly) id <HCMatcher> keyMatcher;
@end


@implementation HCIsDictionaryContainingKey

+ (instancetype)isDictionaryContainingKey:(id <HCMatcher>)keyMatcher
{
    return [[self alloc] initWithKeyMatcher:keyMatcher];
}

- (instancetype)initWithKeyMatcher:(id <HCMatcher>)keyMatcher
{
    self = [super init];
    if (self)
        _keyMatcher = keyMatcher;
    return self;
}

- (BOOL)matches:(id)dict
{
    if ([dict isKindOfClass:[NSDictionary class]])
        for (id oneKey in dict)
            if ([self.keyMatcher matches:oneKey])
                return YES;
    return NO;
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:@"a dictionary containing key "]
                  appendDescriptionOf:self.keyMatcher];
}

@end


id HC_hasKey(id keyMatch)
{
    HCRequireNonNilObject(keyMatch);
    return [HCIsDictionaryContainingKey isDictionaryContainingKey:HCWrapInMatcher(keyMatch)];
}
