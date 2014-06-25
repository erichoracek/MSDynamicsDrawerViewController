//
//  OCMockito - MKTLongLongReturnSetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTLongLongReturnSetter.h"


@implementation MKTLongLongReturnSetter

- (instancetype)initWithSuccessor:(MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(long long) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    long long value = [returnValue longLongValue];
    [invocation setReturnValue:&value];
}

@end
