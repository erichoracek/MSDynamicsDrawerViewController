//
//  OCMockito - MKTArgumentCaptor.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTArgumentCaptor.h"

#import "MKTCapturingMatcher.h"


@implementation MKTArgumentCaptor
{
    MKTCapturingMatcher *_matcher;
}

- (instancetype)init
{
    self = [super init];
    if (self)
        _matcher = [[MKTCapturingMatcher alloc] init];
    return self;
}

- (id)capture
{
    return _matcher;
}

- (id)value
{
    return [_matcher lastValue];
}

- (NSArray *)allValues
{
    return [_matcher allValues];
}

@end
