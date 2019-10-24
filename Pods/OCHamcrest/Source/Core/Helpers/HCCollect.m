//
//  OCHamcrest - HCCollect.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCCollect.h"

#import "HCWrapInMatcher.h"

static id passThrough(id value)
{
    return value;
}

NSMutableArray *HCCollectItems(id item, va_list args)
{
    return HCCollectWrappedItems(item, args, passThrough);
}

NSMutableArray *HCCollectMatchers(id item, va_list args)
{
    return HCCollectWrappedItems(item, args, HCWrapInMatcher);
}

NSMutableArray *HCCollectWrappedItems(id item, va_list args, id (*wrap)(id))
{
    NSMutableArray *list = [NSMutableArray arrayWithObject:wrap(item)];

    id nextItem = va_arg(args, id);
    while (nextItem)
    {
        [list addObject:wrap(nextItem)];
        nextItem = va_arg(args, id);
    }

    return list;
}
