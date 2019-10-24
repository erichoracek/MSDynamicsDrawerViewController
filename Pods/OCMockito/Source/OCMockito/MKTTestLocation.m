//
//  OCMockito - MKTTestLocation.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTTestLocation.h"

#import <OCHamcrest/HCTestFailure.h>
#import <OCHamcrest/HCTestFailureHandler.h>
#import <OCHamcrest/HCTestFailureHandlerChain.h>

void MKTFailTest(id testCase, const char *fileName, int lineNumber, NSString *description)
{
    HCTestFailure *failure = [[HCTestFailure alloc] initWithTestCase:testCase
                                                            fileName:[NSString stringWithUTF8String:fileName]
                                                          lineNumber:(NSUInteger)lineNumber
                                                              reason:description];
    HCTestFailureHandler *chain = HC_testFailureHandlerChain();
    [chain handleFailure:failure];
}

void MKTFailTestLocation(MKTTestLocation testLocation, NSString *description)
{
    MKTFailTest(testLocation.testCase, testLocation.fileName, testLocation.lineNumber, description);
}
