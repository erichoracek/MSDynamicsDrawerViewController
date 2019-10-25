//
//  OCHamcrest - HCTestFailureHandlerChain.h
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import <Foundation/Foundation.h>

@class HCTestFailureHandler;


/**
 Returns chain of test failure handlers.
 
 @ingroup integration
 */
FOUNDATION_EXPORT HCTestFailureHandler *HC_testFailureHandlerChain(void);
