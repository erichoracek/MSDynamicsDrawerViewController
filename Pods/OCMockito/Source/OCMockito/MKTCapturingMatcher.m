//
//  OCMockito - MKTCapturingMatcher.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTCapturingMatcher.h"


@implementation MKTCapturingMatcher
{
    NSMutableArray *_arguments;
}

- (instancetype)init
{
    self = [super initWithDescription:@"<Capturing argument>"];
    if (self)
        _arguments = [[NSMutableArray alloc] init];
    return self;
}

- (void)captureArgument:(id)arg
{
    if (!arg)
        arg = [NSNull null];
    [_arguments addObject:arg];
}

- (NSArray *)allValues
{
    return _arguments;
}

- (id)lastValue
{
    if ([self noArgumentWasCaptured])
        return [self throwNoArgumentException];
    return [self convertNilArgument:[_arguments lastObject]];
}

- (BOOL)noArgumentWasCaptured
{
    return [_arguments count] == 0;
}

- (id)throwNoArgumentException
{
    @throw [NSException exceptionWithName:@"NoArgument"
                                       reason:@"No argument value was captured!\n"
                                              "You might have forgotten to use [argument capture] in verify()"
                                     userInfo:nil];
}

- (id)convertNilArgument:(id)arg
{
    if (arg == [NSNull null])
        arg = nil;
    return arg;
}

@end
