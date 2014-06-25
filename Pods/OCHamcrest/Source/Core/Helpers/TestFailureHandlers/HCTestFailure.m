//
//  OCHamcrest - HCTestFailure.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCTestFailure.h"


@implementation HCTestFailure

- (instancetype)initWithTestCase:(id)testCase
                        fileName:(NSString *)fileName
                      lineNumber:(NSUInteger)lineNumber
                          reason:(NSString *)reason
{
    self = [super init];
    if (self)
    {
        _testCase = testCase;
        _fileName = fileName;
        _lineNumber = lineNumber;
        _reason = reason;
    }
    return self;
}

@end
