//
//  OCHamcrest - HCStringContains.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCStringContains.h"


@implementation HCStringContains

+ (instancetype)stringContains:(NSString *)aString
{
    return [[self alloc] initWithSubstring:aString];
}

- (BOOL)matches:(id)item
{
    if (![item respondsToSelector:@selector(rangeOfString:)])
        return NO;
    
    return [item rangeOfString:self.substring].location != NSNotFound;
}

- (NSString *)relationship
{
    return @"containing";
}

@end


id <HCMatcher> HC_containsString(NSString *aString)
{
    return [HCStringContains stringContains:aString];
}
