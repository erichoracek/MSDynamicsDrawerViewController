//
//  OCMockito - MKTFloatReturnSetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTFloatReturnSetter.h"


@implementation MKTFloatReturnSetter

- (instancetype)initWithSuccessor:(MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(float) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    float value = [returnValue floatValue];
    [invocation setReturnValue:&value];
}

@end
