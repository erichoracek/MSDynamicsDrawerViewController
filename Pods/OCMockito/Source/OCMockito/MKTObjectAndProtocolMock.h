//
//  OCMockito - MKTObjectAndProtocolMock.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//  
//  Created by: Kevin Lundberg
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTProtocolMock.h"


/**
 Mock object of a given class that also implements a given protocol.
 */
@interface MKTObjectAndProtocolMock : MKTProtocolMock

+ (instancetype)mockForClass:(Class)aClass protocol:(Protocol *)protocol;
- (instancetype)initWithClass:(Class)aClass protocol:(Protocol *)protocol;

@end
