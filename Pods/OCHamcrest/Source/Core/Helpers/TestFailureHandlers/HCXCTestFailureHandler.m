//
//  OCHamcrest - HCXCTestFailureHandler.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCXCTestFailureHandler.h"

#import "HCTestFailure.h"


@interface NSObject (PretendMethodExistsOnNSObjectToAvoidLinkingXCTest)

- (void)recordFailureWithDescription:(NSString *)description
                              inFile:(NSString *)filename
                              atLine:(NSUInteger)lineNumber
                            expected:(BOOL)expected;

@end


@implementation HCXCTestFailureHandler

- (BOOL)willHandleFailure:(HCTestFailure *)failure
{
    return [failure.testCase respondsToSelector:@selector(recordFailureWithDescription:inFile:atLine:expected:)];
}

- (void)executeHandlingOfFailure:(HCTestFailure *)failure
{
    [failure.testCase recordFailureWithDescription:failure.reason
                                            inFile:failure.fileName
                                            atLine:failure.lineNumber
                                          expected:YES];
}

@end
