//
//  OCHamcrest - HCWrapInMatcher.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCWrapInMatcher.h"

#import "HCIsEqual.h"


id <HCMatcher> HCWrapInMatcher(id matcherOrValue)
{
    if (!matcherOrValue)
        return nil;
    
    if ([matcherOrValue conformsToProtocol:@protocol(HCMatcher)])
        return matcherOrValue;
    return HC_equalTo(matcherOrValue);
}
