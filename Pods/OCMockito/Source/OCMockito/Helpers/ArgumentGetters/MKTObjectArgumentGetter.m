//
//  OCMockito - MKTObjectArgumentGetter.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTObjectArgumentGetter.h"

@implementation MKTObjectArgumentGetter

- (instancetype)initWithSuccessor:(MKTArgumentGetter *)successor
{
    self = [super initWithType:@encode(id) successor:successor];
    return self;
}

- (id)getArgumentAtIndex:(NSInteger)idx ofType:(char const *)type onInvocation:(NSInvocation *)invocation
{
    __unsafe_unretained id arg = nil;
    [invocation getArgument:&arg atIndex:idx];
    return arg ? arg : [NSNull null];
}

@end
