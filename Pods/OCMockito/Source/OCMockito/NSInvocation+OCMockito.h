//
//  OCMockito - NSInvocation+OCMockito.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import <Foundation/Foundation.h>

@interface NSInvocation (OCMockito)

- (NSArray *)mkt_arguments;
- (void)mkt_setReturnValue:(id)returnValue;
- (void)mkt_retainArgumentsWithWeakTarget;

@end
