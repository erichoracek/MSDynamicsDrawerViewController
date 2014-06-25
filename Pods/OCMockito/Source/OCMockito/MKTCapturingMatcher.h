//
//  OCMockito - MKTCapturingMatcher.h
//  Copyright 2014 Jonathan M. Reid. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Source: https://github.com/jonreid/OCMockito
//

#if TARGET_OS_MAC
    #import <OCHamcrest/HCIsAnything.h>
#else
    #import <OCHamcrestIOS/HCIsAnything.h>
#endif


@interface MKTCapturingMatcher : HCIsAnything

- (void)captureArgument:(id)arg;
- (NSArray *)allValues;
- (id)lastValue;

@end
