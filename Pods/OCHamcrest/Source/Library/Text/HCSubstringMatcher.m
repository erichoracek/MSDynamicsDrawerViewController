//
//  OCHamcrest - HCSubstringMatcher.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCSubstringMatcher.h"

#import "HCRequireNonNilObject.h"


@interface HCSubstringMatcher (SubclassResponsibility)
- (NSString *)relationship;
@end


@implementation HCSubstringMatcher

- (instancetype)initWithSubstring:(NSString *)aString
{
    HCRequireNonNilObject(aString);
    
    self = [super init];
    if (self)
        _substring = [aString copy];
    return self;
}

- (void)describeTo:(id<HCDescription>)description
{
    [[[[description appendText:@"a string "]
                    appendText:[self relationship]]
                    appendText:@" "]
                    appendDescriptionOf:self.substring];
}

@end
