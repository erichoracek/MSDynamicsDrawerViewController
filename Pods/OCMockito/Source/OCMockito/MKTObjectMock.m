//
//  OCMockito - MKTObjectMock.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTObjectMock.h"


@implementation MKTObjectMock
{
    Class _mockedClass;
}

+ (instancetype)mockForClass:(Class)aClass
{
    return [[self alloc] initWithClass:aClass];
}

- (instancetype)initWithClass:(Class)aClass
{
    self = [super init];
    if (self)
        _mockedClass = aClass;
    return self;
}

- (NSString *)description
{
    return [@"mock object of " stringByAppendingString:NSStringFromClass(_mockedClass)];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [_mockedClass instanceMethodSignatureForSelector:aSelector];
}


#pragma mark NSObject protocol

- (BOOL)isKindOfClass:(Class)aClass
{
    return [_mockedClass isSubclassOfClass:aClass];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [_mockedClass instancesRespondToSelector:aSelector];
}

@end
