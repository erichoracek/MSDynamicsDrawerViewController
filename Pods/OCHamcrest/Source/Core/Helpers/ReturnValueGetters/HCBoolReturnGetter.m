//
//  OCHamcrest - HCBoolReturnGetter.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCBoolReturnGetter.h"


@implementation HCBoolReturnGetter

- (instancetype)initWithSuccessor:(HCReturnValueGetter *)successor
{
    self = [super initWithType:@encode(BOOL) successor:successor];
    return self;
}

- (id)returnValueFromInvocation:(NSInvocation *)invocation
{
    BOOL value;
    [invocation getReturnValue:&value];
    return @(value);
}

@end
