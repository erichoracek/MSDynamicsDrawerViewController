//
//  OCHamcrest - HCReturnValueGetter.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCReturnValueGetter.h"


@interface HCReturnValueGetter (SubclassResponsibility)
- (id)returnValueFromInvocation:(NSInvocation *)invocation;
@end

@interface HCReturnValueGetter ()
@property (nonatomic, readonly) char const *handlerType;
@property (nonatomic, readonly) HCReturnValueGetter *successor;
@end


@implementation HCReturnValueGetter

- (instancetype)initWithType:(char const *)handlerType successor:(HCReturnValueGetter *)successor
{
    self = [super init];
    if (self)
    {
        _handlerType = handlerType;
        _successor = successor;
    }
    return self;
}

- (BOOL)handlesReturnType:(char const *)returnType
{
    return strcmp(returnType, self.handlerType) == 0;
}

- (id)returnValueOfType:(char const *)type fromInvocation:(NSInvocation *)invocation
{
    if ([self handlesReturnType:type])
        return [self returnValueFromInvocation:invocation];
    else
        return [self.successor returnValueOfType:type fromInvocation:invocation];
}

@end
