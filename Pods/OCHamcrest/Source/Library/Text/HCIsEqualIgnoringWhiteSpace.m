//
//  OCHamcrest - HCIsEqualIgnoringWhiteSpace.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCIsEqualIgnoringWhiteSpace.h"

#import "HCRequireNonNilObject.h"


static void removeTrailingSpace(NSMutableString *string)
{
    NSUInteger length = [string length];
    if (length > 0)
    {
        NSUInteger charIndex = length - 1;
        if (isspace([string characterAtIndex:charIndex]))
            [string deleteCharactersInRange:NSMakeRange(charIndex, 1)];
    }
}

static NSMutableString *stripSpace(NSString *string)
{
    NSUInteger length = [string length];
    NSMutableString *result = [NSMutableString stringWithCapacity:length];
    bool lastWasSpace = true;
    for (NSUInteger charIndex = 0; charIndex < length; ++charIndex)
    {
        unichar character = [string characterAtIndex:charIndex];
        if (isspace(character))
        {
            if (!lastWasSpace)
                [result appendString:@" "];
            lastWasSpace = true;
        }
        else
        {
            [result appendFormat:@"%C", character];
            lastWasSpace = false;
        }
    }
        
    removeTrailingSpace(result);
    return result;
}


@interface HCIsEqualIgnoringWhiteSpace ()
@property (nonatomic, readonly) NSString *originalString;
@property (nonatomic, readonly) NSString *strippedString;
@end

@implementation HCIsEqualIgnoringWhiteSpace

+ (instancetype)isEqualIgnoringWhiteSpace:(NSString *)string
{
    return [[self alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString *)string
{
    HCRequireNonNilObject(string);
    
    self = [super init];
    if (self)
    {
        _originalString = [string copy];
        _strippedString = stripSpace(string);
    }
    return self;
}

- (BOOL)matches:(id)item
{
    if (![item isKindOfClass:[NSString class]])
        return NO;
    
    return [self.strippedString isEqualToString:stripSpace(item)];
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendDescriptionOf:self.originalString]
                  appendText:@" ignoring whitespace"];
}

@end


id HC_equalToIgnoringWhiteSpace(NSString *aString)
{
    return [HCIsEqualIgnoringWhiteSpace isEqualIgnoringWhiteSpace:aString];
}
