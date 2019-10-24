//
//  OCHamcrest - HCIsInstanceOf.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsInstanceOf.h"


@implementation HCIsInstanceOf

+ (instancetype)isInstanceOf:(Class)type
{
    return [[self alloc] initWithType:type];
}

- (BOOL)matches:(id)item
{
    return [item isKindOfClass:self.theClass];
}

- (NSString *)expectation
{
    return @"an instance of ";
}

@end


id HC_instanceOf(Class aClass)
{
    return [HCIsInstanceOf isInstanceOf:aClass];
}
