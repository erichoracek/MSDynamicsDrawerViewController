//
//  OCMockito - MKTReturnValueSetter.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import <Foundation/Foundation.h>


@interface MKTReturnValueSetter : NSObject

- (instancetype)initWithType:(char const *)handlerType successor:(MKTReturnValueSetter *)successor;
- (void)setReturnValue:(id)returnValue ofType:(char const *)type onInvocation:(NSInvocation *)invocation;

@end
