//
//  OCMockito - MKTInvocationMatcher.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import <Foundation/Foundation.h>

@protocol HCMatcher;


@interface MKTInvocationMatcher : NSObject

@property (nonatomic, strong) NSInvocation *expected;
@property (nonatomic) NSUInteger numberOfArguments;
@property (nonatomic, strong) NSMutableArray *argumentMatchers;

- (instancetype)init;
- (void)setMatcher:(id <HCMatcher>)matcher atIndex:(NSUInteger)index;
- (NSUInteger)argumentMatchersCount;
- (void)setExpectedInvocation:(NSInvocation *)expectedInvocation;
- (BOOL)matches:(NSInvocation *)actual;
- (void)captureArgumentsFromInvocations:(NSArray *)invocations;

@end
