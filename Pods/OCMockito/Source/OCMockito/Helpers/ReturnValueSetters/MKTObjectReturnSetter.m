//
//  OCMockito - MKTObjectReturnSetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTObjectReturnSetter.h"


@implementation MKTObjectReturnSetter

- (instancetype)initWithSuccessor:(MKTReturnValueSetter *)successor
{
    self = [super initWithType:@encode(id) successor:successor];
    return self;
}

- (void)setReturnValue:(id)returnValue onInvocation:(NSInvocation *)invocation
{
    __unsafe_unretained id value = returnValue;
    [invocation setReturnValue:&value];
}

@end
