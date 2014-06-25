//
//  OCMockito - MKTBoolArgumentGetter.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import "MKTArgumentGetter.h"


@interface MKTBoolArgumentGetter : MKTArgumentGetter

- (instancetype)initWithSuccessor:(MKTArgumentGetter *)successor;

@end
