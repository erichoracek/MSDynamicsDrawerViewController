//
//  OCHamcrest - HCTestFailure.h
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Jon Reid, http://qualitycoding.org/
//  Docs: http://hamcrest.github.com/OCHamcrest/
//  Source: https://github.com/hamcrest/OCHamcrest
//

#import <Foundation/Foundation.h>


/**
 Test failure location and reason.
 
 @ingroup integration
 */
@interface HCTestFailure : NSObject

@property (nonatomic, readonly) id testCase;
@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSUInteger lineNumber;
@property (nonatomic, readonly) NSString *reason;

- (instancetype)initWithTestCase:(id)testCase
                        fileName:(NSString *)fileName
                      lineNumber:(NSUInteger)lineNumber
                          reason:(NSString *)reason;

@end
