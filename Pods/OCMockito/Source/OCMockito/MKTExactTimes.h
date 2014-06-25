//
//  OCMockito - MKTExactTimes.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import <Foundation/Foundation.h>
#import "MKTVerificationMode.h"


@interface MKTExactTimes : NSObject <MKTVerificationMode>

- (instancetype)initWithCount:(NSUInteger)expectedNumberOfInvocations;

@end
