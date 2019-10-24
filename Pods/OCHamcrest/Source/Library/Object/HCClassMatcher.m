//
//  OCHamcrest - HCClassMatcher.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import "HCClassMatcher.h"

#import "HCRequireNonNilObject.h"


@interface HCClassMatcher (SubclassResponsibility)
- (NSString *)expectation;
@end


@implementation HCClassMatcher

- (instancetype)initWithType:(Class)aClass
{
    HCRequireNonNilObject(aClass);
    
    self = [super init];
    if (self)
        _theClass = aClass;
    return self;
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:[self expectation]]
                  appendText:NSStringFromClass(self.theClass)];
}

- (void)describeMismatchOf:(id)item to:(id<HCDescription>)mismatchDescription
{
    [mismatchDescription appendText:@"was "];
    if (item)
    {
        [[mismatchDescription appendText:NSStringFromClass([item class])]
                              appendText:@" instance "];
    }
    [mismatchDescription appendDescriptionOf:item];
}

@end
