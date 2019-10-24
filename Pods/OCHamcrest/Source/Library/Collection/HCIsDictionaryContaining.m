//
//  OCHamcrest - HCIsDictionaryContaining.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsDictionaryContaining.h"

#import "HCRequireNonNilObject.h"
#import "HCWrapInMatcher.h"


@interface HCIsDictionaryContaining ()
@property (nonatomic, readonly) id <HCMatcher> keyMatcher;
@property (nonatomic, readonly) id <HCMatcher> valueMatcher;
@end


@implementation HCIsDictionaryContaining

+ (instancetype)isDictionaryContainingKey:(id <HCMatcher>)keyMatcher
                                    value:(id <HCMatcher>)valueMatcher
{
    return [[self alloc] initWithKeyMatcher:keyMatcher valueMatcher:valueMatcher];
}

- (instancetype)initWithKeyMatcher:(id <HCMatcher>)keyMatcher
                      valueMatcher:(id <HCMatcher>)valueMatcher
{
    self = [super init];
    if (self)
    {
        _keyMatcher = keyMatcher;
        _valueMatcher = valueMatcher;
    }
    return self;
}

- (BOOL)matches:(id)dict
{
    if ([dict isKindOfClass:[NSDictionary class]])
        for (id oneKey in dict)
            if ([self.keyMatcher matches:oneKey] && [self.valueMatcher matches:dict[oneKey]])
                return YES;
    return NO;
}

- (void)describeTo:(id<HCDescription>)description
{
    [[[[[description appendText:@"a dictionary containing { "]
                     appendDescriptionOf:self.keyMatcher]
                     appendText:@" = "]
                     appendDescriptionOf:self.valueMatcher]
                     appendText:@"; }"];
}

@end


id HC_hasEntry(id keyMatch, id valueMatch)
{
    HCRequireNonNilObject(keyMatch);
    HCRequireNonNilObject(valueMatch);
    return [HCIsDictionaryContaining isDictionaryContainingKey:HCWrapInMatcher(keyMatch)
                                                         value:HCWrapInMatcher(valueMatch)];
}
