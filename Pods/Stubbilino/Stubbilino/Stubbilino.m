//
//  Stubbilino.m
//  Stubbilino
//
//  Copyright (c) 2013 Robert Böhnke
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.

#import <objc/runtime.h>

#import "Stubbilino.h"
#import "Stubbilino+Private.h"

static void SBStubMethodWithBlock(__unsafe_unretained id self, SEL cmd, SEL selector, id block) {
    if (![self respondsToSelector:selector]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"Stubbed object does not respond to selector %@", NSStringFromSelector(selector)];
    }

    Method method = class_getInstanceMethod(object_getClass(self), selector);

    class_replaceMethod(object_getClass(self),
                        selector,
                        imp_implementationWithBlock(block),
                        method_getTypeEncoding(method));
}

static void SBRemoveStub(__unsafe_unretained id self, SEL cmd, SEL selector) {
    Method superMethod = class_getInstanceMethod(class_getSuperclass(object_getClass(self)), selector);

    class_replaceMethod(object_getClass(self),
                        selector,
                        method_getImplementation(superMethod),
                        method_getTypeEncoding(superMethod));
}

static void SBRemoveStubClass(id object, void *context) {
    Class stubClass = object_getClass(object);
    Class originalClass = class_getSuperclass(stubClass);

    object_setClass(object, originalClass);

    objc_disposeClassPair(stubClass);
}

@implementation Stubbilino

+ (id<SBStub>)stubObject:(NSObject *)object
{
    if (CFSetContainsValue(Stubbilino.stubbedObjects, (__bridge const void *)object)) {
        return (id<SBStub>)object;
    }

    NSString *name = [Stubbilino nameOfStub:object_getClass(object)];

    Class stubClass = objc_allocateClassPair(object_getClass(object), name.UTF8String, 0);

    class_addMethod(stubClass, @selector(stubMethod:withBlock:), (IMP)&SBStubMethodWithBlock, "v@::@");
    class_addMethod(stubClass, @selector(removeStub:), (IMP)&SBRemoveStub, "v@::");

    SEL deallocSelector = sel_registerName("dealloc");

    Method deallocMethod = class_getInstanceMethod(object_getClass(object), deallocSelector);
    void (*originalDealloc)(id, SEL) = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);

    id newDealloc = ^(__unsafe_unretained id obj) {
        SBRemoveStubClass(obj, NULL);

        CFSetRemoveValue(Stubbilino.stubbedObjects, (__bridge const void *)obj);

        originalDealloc(obj, deallocSelector);
    };

    class_addMethod(stubClass, deallocSelector, imp_implementationWithBlock(newDealloc), "v@:");

    object_setClass(object, stubClass);

    CFSetAddValue(Stubbilino.stubbedObjects, (__bridge const void *)object);

    return (id<SBStub>)object;
}

+ (id)unstubObject:(NSObject<SBStub> *)object
{
    if (!CFSetContainsValue(Stubbilino.stubbedObjects, (__bridge const void *)object)) {
        return (id<SBStub>)object;
    }

    SBRemoveStubClass(object, NULL);

    CFSetRemoveValue(Stubbilino.stubbedObjects, (__bridge const void *)object);

    return object;
}

+ (Class<SBStub>)stubClass:(Class)class
{
    return (Class<SBStub>)[self stubObject:(id)class];
}

+ (Class)unstubClass:(Class<SBStub>)class
{
    return (Class)[self unstubObject:(id)class];
}

+ (void)removeAllStubs
{
    CFSetApplyFunction(Stubbilino.stubbedObjects, (CFSetApplierFunction)&SBRemoveStubClass, NULL);
    CFSetRemoveAllValues(Stubbilino.stubbedObjects);
}

#pragma mark - Private

+ (NSString *)nameOfStub:(Class)class
{
    return [NSString stringWithFormat:@"SBStubOf%@", NSStringFromClass(class)];
}

+ (CFMutableSetRef)stubbedObjects
{
    static CFMutableSetRef stubbedObjects;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stubbedObjects = CFSetCreateMutable(NULL, 0, NULL);
    });
    return stubbedObjects;
}

@end
