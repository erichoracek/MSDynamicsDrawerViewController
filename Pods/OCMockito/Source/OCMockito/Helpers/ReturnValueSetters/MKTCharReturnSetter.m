//
//  OCMockito - MKTCharReturnSetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTCharReturnSetter.h"


@implementation MKTCharReturnSetter

- (instancetype)initWithSuccessor:(MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(char) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    char value = [returnValue charValue];
    [invocation setReturnValue:&value];
}

@end
