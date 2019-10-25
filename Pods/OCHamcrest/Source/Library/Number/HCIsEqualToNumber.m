//
//  OCHamcrest - HCIsEqualToNumber.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsEqualToNumber.h"

#import "HCIsEqual.h"


FOUNDATION_EXPORT id HC_equalToChar(char value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToDouble(double value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToFloat(float value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToInt(int value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToLong(long value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToLongLong(long long value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToShort(short value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToUnsignedChar(unsigned char value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToUnsignedInt(unsigned int value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToUnsignedLong(unsigned long value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToUnsignedLongLong(unsigned long long value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToUnsignedShort(unsigned short value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToInteger(NSInteger value)
{
    return HC_equalTo(@(value));
}

FOUNDATION_EXPORT id HC_equalToUnsignedInteger(NSUInteger value)
{
    return HC_equalTo(@(value));
}

#pragma mark -

FOUNDATION_EXPORT id HC_equalToBool(BOOL value)
{
    return [[HCIsEqualToBool alloc] initWithValue:value];
}

@implementation HCIsEqualToBool
{
    BOOL _value;
}

+ (NSString*) stringForBool:(BOOL)value
{
    return value ? @"<YES>" : @"<NO>";
}

- (instancetype)initWithValue:(BOOL)value
{
    self = [super init];
    if (self)
        _value = value;
    return self;
}

- (BOOL)matches:(id)item
{
    if (![item isKindOfClass:[NSNumber class]])
        return NO;

    return [item boolValue] == _value;
}

- (void)describeTo:(id<HCDescription>)description
{
    [description appendText:@"a BOOL with value "];
    [description appendText:[HCIsEqualToBool stringForBool:_value]];
}

- (void)describeMismatchOf:(id)item to:(id<HCDescription>)mismatchDescription
{
    [mismatchDescription appendText:@"was "];
    [mismatchDescription appendText:[HCIsEqualToBool stringForBool:[item boolValue]]];
}

@end
