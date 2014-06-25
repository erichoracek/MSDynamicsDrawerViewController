//
//  OCHamcrest - HCAssertThat.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCAssertThat.h"

#import "HCStringDescription.h"
#import "HCMatcher.h"
#import "HCTestFailure.h"
#import "HCTestFailureHandler.h"
#import "HCTestFailureHandlerChain.h"


static NSString *describeMismatch(id matcher, id actual)
{
    HCStringDescription *description = [HCStringDescription stringDescription];
    [[[description appendText:@"Expected "]
            appendDescriptionOf:matcher]
            appendText:@", but "];
    [matcher describeMismatchOf:actual to:description];
    return [description description];
}

void HC_assertThatWithLocation(id testCase, id actual, id <HCMatcher> matcher,
                               const char *fileName, int lineNumber)
{
    if (![matcher matches:actual])
    {
        HCTestFailure *failure = [[HCTestFailure alloc] initWithTestCase:testCase
                                                                fileName:[NSString stringWithUTF8String:fileName]
                                                              lineNumber:(NSUInteger)lineNumber
                                                                  reason:describeMismatch(matcher, actual)];
        HCTestFailureHandler *chain = HC_testFailureHandlerChain();
        [chain handleFailure:failure];
    }
}

