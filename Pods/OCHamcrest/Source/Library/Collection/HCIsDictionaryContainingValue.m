//
//  OCHamcrest - HCIsDictionaryContainingValue.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsDictionaryContainingValue.h"

#import "HCRequireNonNilObject.h"
#import "HCWrapInMatcher.h"


@interface HCIsDictionaryContainingValue ()
@property (nonatomic, readonly) id <HCMatcher> valueMatcher;
@end


@implementation HCIsDictionaryContainingValue

+ (instancetype)isDictionaryContainingValue:(id <HCMatcher>)valueMatcher
{
    return [[self alloc] initWithValueMatcher:valueMatcher];
}

- (instancetype)initWithValueMatcher:(id <HCMatcher>)valueMatcher
{
    self = [super init];
    if (self)
        _valueMatcher = valueMatcher;
    return self;
}

- (BOOL)matches:(id)dict
{
    if ([dict respondsToSelector:@selector(allValues)])
        for (id oneValue in [dict allValues])
            if ([self.valueMatcher matches:oneValue])
                return YES;
    return NO;
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:@"a dictionary containing value "]
                  appendDescriptionOf:self.valueMatcher];
}

@end


id HC_hasValue(id valueMatch)
{
    HCRequireNonNilObject(valueMatch);
    return [HCIsDictionaryContainingValue isDictionaryContainingValue:HCWrapInMatcher(valueMatch)];
}
