//
//  OCHamcrest - HCDescribedAs.h
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import <OCHamcrest/HCBaseMatcher.h>


@interface HCDescribedAs : HCBaseMatcher

+ (instancetype)describedAs:(NSString *)description
                 forMatcher:(id <HCMatcher>)matcher
                 overValues:(NSArray *)templateValues;

- (instancetype)initWithDescription:(NSString *)description
                         forMatcher:(id <HCMatcher>)matcher
                         overValues:(NSArray *)templateValues;

@end


FOUNDATION_EXPORT id HC_describedAs(NSString *description, id <HCMatcher> matcher, ...) NS_REQUIRES_NIL_TERMINATION;

/**
 describedAs(description, matcher, ...) -
 Adds custom failure description to a given matcher.
 
 @param description  Overrides the matcher's description.
 @param matcher,...  The matcher to satisfy, followed by a comma-separated list of substitution values ending with @c nil.
 
 The description may contain substitution placeholders \%0, \%1, etc. These will be replaced by
 any values that follow the matcher.
 
 (In the event of a name clash, don't \#define @c HC_SHORTHAND and use the synonym
 @c HC_describedAs instead.)
 
 @ingroup decorator_matchers
 */
#ifdef HC_SHORTHAND
    #define describedAs HC_describedAs
#endif
