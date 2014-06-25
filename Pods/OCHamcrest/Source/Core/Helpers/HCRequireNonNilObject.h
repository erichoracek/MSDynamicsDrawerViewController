//
//  OCHamcrest - HCRequireNonNilObject.h
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import <Foundation/Foundation.h>


/**
 Throws an NSException if @a obj is @c nil.
 
 @ingroup helpers
*/
FOUNDATION_EXPORT void HCRequireNonNilObject(id obj);
