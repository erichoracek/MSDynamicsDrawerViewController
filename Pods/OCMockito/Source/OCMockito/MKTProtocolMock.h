//
//  OCMockito - MKTProtocolMock.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTBaseMockObject.h"


/**
 Mock object implementing a given protocol.
 */
@interface MKTProtocolMock : MKTBaseMockObject
{
    Protocol *_mockedProtocol;
}

+ (instancetype)mockForProtocol:(Protocol *)aProtocol;
- (instancetype)initWithProtocol:(Protocol *)aProtocol;

@end
