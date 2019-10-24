//
//  TPWeakProxy.m
//  TPWeakProxy
//
//  Copyright (c) 2013 Tetherpad, Inc. All rights reserved.
//

#import "TPWeakProxy.h"

@interface TPWeakProxy ()

@property (weak, nonatomic) id theObject;

@end

@implementation TPWeakProxy

- (id)initWithObject:(id)object {
    // No init method in superclass
    self.theObject = object;
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget:self.theObject];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [self.theObject methodSignatureForSelector:aSelector];
}

@end
