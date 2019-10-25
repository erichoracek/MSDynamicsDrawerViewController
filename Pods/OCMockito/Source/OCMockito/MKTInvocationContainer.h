//
//  OCMockito - MKTInvocationContainer.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import <Foundation/Foundation.h>

@class MKTInvocationMatcher;
@class MKTStubbedInvocationMatcher;
@protocol HCMatcher;


@interface MKTInvocationContainer : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *registeredInvocations;

- (instancetype)init;
- (void)setInvocationForPotentialStubbing:(NSInvocation *)invocation;
- (void)setMatcher:(id <HCMatcher>)matcher atIndex:(NSUInteger)argumentIndex;
- (void)addAnswer:(id)answer;
- (MKTStubbedInvocationMatcher *)findAnswerFor:(NSInvocation *)invocation;
@end
