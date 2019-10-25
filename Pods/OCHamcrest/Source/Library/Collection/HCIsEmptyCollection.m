//
//  OCHamcrest - HCIsEmptyCollection.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsEmptyCollection.h"

#import "HCIsEqual.h"


@implementation HCIsEmptyCollection

+ (instancetype)isEmptyCollection
{
    return [[self alloc] init];
}

- (instancetype)init
{
    self = [super initWithCount:HC_equalTo(@0)];
    return self;
}

- (void)describeMismatchOf:(id)item to:(id<HCDescription>)mismatchDescription
{
    [[mismatchDescription appendText:@"was "] appendDescriptionOf:item];
}

- (void)describeTo:(id<HCDescription>)description
{
    [description appendText:@"empty collection"];
}

@end


FOUNDATION_EXPORT id HC_isEmpty()
{
    return [HCIsEmptyCollection isEmptyCollection];
}
