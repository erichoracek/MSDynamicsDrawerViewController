//
//  OCHamcrest - HCReturnValueGetterChain.h
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import <Foundation/Foundation.h>

@class HCReturnValueGetter;


/**
 Returns chain of return type handlers.
 */
FOUNDATION_EXPORT HCReturnValueGetter *HCReturnValueGetterChain(void);
