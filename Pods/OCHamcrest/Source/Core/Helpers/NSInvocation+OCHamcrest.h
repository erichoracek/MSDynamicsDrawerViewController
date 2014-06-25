//
//  OCHamcrest - NSInvocation+OCHamcrest.h
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import <Foundation/Foundation.h>


@interface NSInvocation (OCHamcrest)

+ (NSInvocation *)och_invocationWithTarget:(id)target selector:(SEL)selector;
+ (NSInvocation *)och_invocationOnObjectOfType:(Class)aClass selector:(SEL)selector;
- (id)och_invoke;

@end
