//
//  OCMockito - MKTStructReturnSetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTStructReturnSetter.h"


@implementation MKTStructReturnSetter

- (instancetype)initWithSuccessor:(MKTReturnValueSetter *)successor
{
    self = [super initWithType:"{" successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    NSMethodSignature *methodSignature = [invocation methodSignature];
    NSMutableData *value = [NSMutableData dataWithLength:[methodSignature methodReturnLength]];
    [returnValue getValue:[value mutableBytes]];
    [invocation setReturnValue:[value mutableBytes]];
}

@end
