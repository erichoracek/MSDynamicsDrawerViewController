//
//  OCHamcrest - HCConformsToProtocol.m
//  Copyright 2014 hamcrest.org. See LICENSE.txt
//
//  Created by: Todd Farrell
//

#import "HCConformsToProtocol.h"

#import "HCRequireNonNilObject.h"


@interface HCConformsToProtocol ()
@property (nonatomic, readonly) Protocol *protocol;
@end

@implementation HCConformsToProtocol

+ (instancetype)conformsTo:(Protocol *)protocol
{
    return [[self alloc] initWithProtocol:protocol];
}

- (instancetype)initWithProtocol:(Protocol *)protocol
{
    HCRequireNonNilObject(protocol);
    
    self = [super init];
    if (self)
        _protocol = protocol;
    return self;
}

- (BOOL)matches:(id)item
{
    return [item conformsToProtocol:self.protocol];
}

- (void)describeTo:(id<HCDescription>)description
{
    [[description appendText:@"an object that conforms to "]
                  appendText:NSStringFromProtocol(self.protocol)];
}

@end


id HC_conformsTo(Protocol *aProtocol)
{
    return [HCConformsToProtocol conformsTo:aProtocol];
}
