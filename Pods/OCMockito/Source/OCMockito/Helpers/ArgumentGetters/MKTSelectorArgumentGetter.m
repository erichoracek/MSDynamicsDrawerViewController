//
//  OCMockito - MKTSelectorArgumentGetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTSelectorArgumentGetter.h"

@implementation MKTSelectorArgumentGetter

- (instancetype)initWithSuccessor:(MKTArgumentGetter *)successor
{
    self = [super initWithType:@encode(SEL) successor:successor];
    return self;
}

- (id)getArgumentAtIndex:(NSInteger)idx ofType:(char const *)type onInvocation:(NSInvocation *)invocation
{
    SEL arg = nil;
    [invocation getArgument:&arg atIndex:idx];
    return arg ? NSStringFromSelector(arg) : [NSNull null];
}

@end
