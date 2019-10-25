//
//  OCHamcrest - HCStringStartsWith.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCStringStartsWith.h"


@implementation HCStringStartsWith

+ (instancetype)stringStartsWith:(NSString *)aSubstring
{
    return [[self alloc] initWithSubstring:aSubstring];
}

- (BOOL)matches:(id)item
{
    if (![item respondsToSelector:@selector(hasPrefix:)])
        return NO;
    
    return [item hasPrefix:self.substring];
}

- (NSString *)relationship
{
    return @"starting with";
}

@end


id HC_startsWith(NSString *aString)
{
    return [HCStringStartsWith stringStartsWith:aString];
}
