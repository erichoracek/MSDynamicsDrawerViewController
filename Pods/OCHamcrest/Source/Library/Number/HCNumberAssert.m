//
//  OCHamcrest - HCNumberAssert.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCNumberAssert.h"

#import "HCAssertThat.h"


FOUNDATION_EXPORT void HC_assertThatBoolWithLocation(id testCase, BOOL actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatCharWithLocation(id testCase, char actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatDoubleWithLocation(id testCase, double actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatFloatWithLocation(id testCase, float actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatIntWithLocation(id testCase, int actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatLongWithLocation(id testCase, long actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatLongLongWithLocation(id testCase, long long actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatShortWithLocation(id testCase, short actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatUnsignedCharWithLocation(id testCase, unsigned char actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatUnsignedIntWithLocation(id testCase, unsigned int actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatUnsignedLongWithLocation(id testCase, unsigned long actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatUnsignedLongLongWithLocation(id testCase, unsigned long long actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatUnsignedShortWithLocation(id testCase, unsigned short actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatIntegerWithLocation(id testCase, NSInteger actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}

FOUNDATION_EXPORT void HC_assertThatUnsignedIntegerWithLocation(id testCase, NSUInteger actual,
        id <HCMatcher> matcher, char const * fileName, int lineNumber)
{
    HC_assertThatWithLocation(testCase, @(actual), matcher, fileName, lineNumber);
}
