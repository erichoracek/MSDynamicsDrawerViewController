//
//  OCMockito - MKTCharArgumentGetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTCharArgumentGetter.h"

@implementation MKTCharArgumentGetter

- (instancetype)initWithSuccessor:(MKTArgumentGetter *)successor
{
    self = [super initWithType:@encode(char) successor:successor];
    return self;
}

- (id)getArgumentAtIndex:(NSInteger)idx ofType:(char const *)type onInvocation:(NSInvocation *)invocation
{
    char arg;
    [invocation getArgument:&arg atIndex:idx];
    return @(arg);
}

@end
