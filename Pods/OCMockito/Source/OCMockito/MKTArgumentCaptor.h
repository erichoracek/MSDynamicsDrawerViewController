//
//  OCMockito - MKTArgumentCaptor.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#import <Foundation/Foundation.h>


@interface MKTArgumentCaptor : NSObject

- (id)capture;
- (id)value;
- (NSArray *)allValues;

@end
