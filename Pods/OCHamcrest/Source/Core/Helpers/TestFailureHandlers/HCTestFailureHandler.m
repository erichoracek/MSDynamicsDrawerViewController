//
//  OCHamcrest - HCTestFailureHandler.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCTestFailureHandler.h"


@interface HCTestFailureHandler (SubclassResponsibility)
- (BOOL)willHandleFailure:(HCTestFailure *)failure;
- (void)executeHandlingOfFailure:(HCTestFailure *)failure;
@end

@interface HCTestFailureHandler ()
@property (nonatomic, readonly) HCTestFailureHandler *successor;
@end


@implementation HCTestFailureHandler

- (instancetype)initWithSuccessor:(HCTestFailureHandler *)successor
{
    self = [super init];
    if (self)
        _successor = successor;
    return self;
}

- (void)handleFailure:(HCTestFailure *)failure
{
    if ([self willHandleFailure:failure])
        [self executeHandlingOfFailure:failure];
    else
        [self.successor handleFailure:failure];
}

@end
