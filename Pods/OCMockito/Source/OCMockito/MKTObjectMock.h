//
//  OCMockito - MKTObjectMock.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTBaseMockObject.h"


/**
 Mock object of a given class.
 */
@interface MKTObjectMock : MKTBaseMockObject

+ (instancetype)mockForClass:(Class)aClass;
- (instancetype)initWithClass:(Class)aClass;

@end
