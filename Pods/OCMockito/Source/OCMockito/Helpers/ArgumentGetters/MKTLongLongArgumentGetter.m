//
//  OCMockito - MKTLongLongArgumentGetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTLongLongArgumentGetter.h"

@implementation MKTLongLongArgumentGetter

- (instancetype)initWithSuccessor:(MKTArgumentGetter *)successor
{
    self = [super initWithType:@encode(long long) successor:successor];
    return self;
}

- (id)getArgumentAtIndex:(NSInteger)idx ofType:(char const *)type onInvocation:(NSInvocation *)invocation
{
    long long arg;
    [invocation getArgument:&arg atIndex:idx];
    return @(arg);
}

@end
