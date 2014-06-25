//
//  OCMockito - MKTLongReturnSetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTLongReturnSetter.h"


@implementation MKTLongReturnSetter

- (instancetype)initWithSuccessor:(MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(long) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    long value = [returnValue longValue];
    [invocation setReturnValue:&value];
}

@end
