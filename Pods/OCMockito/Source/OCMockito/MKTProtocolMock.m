//
//  OCMockito - MKTProtocolMock.m
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTProtocolMock.h"

#import <objc/runtime.h>


@implementation MKTProtocolMock

+ (instancetype)mockForProtocol:(Protocol *)aProtocol
{
    return [[self alloc] initWithProtocol:aProtocol];
}

- (instancetype)initWithProtocol:(Protocol *)aProtocol
{
    self = [super init];
    if (self)
        _mockedProtocol = aProtocol;
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"mock implementer of %@ protocol",
            NSStringFromProtocol(_mockedProtocol)];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    struct objc_method_description methodDescription = protocol_getMethodDescription(_mockedProtocol, aSelector, YES, YES);
    if (!methodDescription.name)
        methodDescription = protocol_getMethodDescription(_mockedProtocol, aSelector, NO, YES);
    if (!methodDescription.name)
        return nil;
	return [NSMethodSignature signatureWithObjCTypes:methodDescription.types];
}


#pragma mark NSObject protocol

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return protocol_conformsToProtocol(_mockedProtocol, aProtocol);
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    return [self methodSignatureForSelector:aSelector] != nil;
}

@end
