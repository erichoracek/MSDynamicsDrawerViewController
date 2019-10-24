//
//  OCHamcrest - HCStringDescription.h
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import <OCHamcrest/HCBaseDescription.h>

@protocol HCSelfDescribing;


/**
 An HCDescription that is stored as a string.
 
 @ingroup core
 */
@interface HCStringDescription : HCBaseDescription
{
    NSMutableString *accumulator;
}

/**
 Returns the description of an HCSelfDescribing object as a string.
 
 @param selfDescribing  The object to be described.
 @return The description of the object.
 */
+ (NSString *)stringFrom:(id<HCSelfDescribing>)selfDescribing;

/**
 Returns an empty description.
 */
+ (instancetype)stringDescription;

/**
 Returns an initialized HCStringDescription object that is empty.
 */
- (instancetype)init;

@end
