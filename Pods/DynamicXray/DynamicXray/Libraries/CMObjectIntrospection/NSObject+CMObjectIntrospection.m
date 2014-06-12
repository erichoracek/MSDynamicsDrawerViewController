//
//  NSObject+CMObjectIntrospection.m
//
//  Created by Chris Miles on 4/08/13.
//  Copyright (c) 2013 Chris Miles. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "NSObject+CMObjectIntrospection.h"
@import ObjectiveC.runtime;


@interface NSObject (CMObjectIntrospectionPrivateAccess)

// These description methods are only available in iOS 7+
- (NSString *)_ivarDescription;
- (NSString *)_methodDescription;
- (NSString *)_shortMethodDescription;

@end


@implementation NSObject (CMObjectIntrospection)

- (void)CMObjectIntrospectionDumpInfo
{
    SEL ivarDescriptionSelector = NSSelectorFromString(@"_ivarDescription");
    if ([self respondsToSelector:ivarDescriptionSelector]) {
        NSLog(@"%@", [self _ivarDescription]);

        SEL methodDescriptionSelector = NSSelectorFromString(@"_methodDescription"); // note: we can also call "_shortMethodDescription"
        if ([self respondsToSelector:methodDescriptionSelector]) {
            NSLog(@"%@", [self _methodDescription]);
        }
    }
    else {
        // Pre-iOS 7
        Class myClass = [self class];
        [NSObject CMObjectIntrospectionDumpInfoForClass:myClass];
    }
}

+ (void)CMObjectIntrospectionDumpInfoForClass:(Class)interestingClass
{
    u_int count;
    
    Ivar *ivars = class_copyIvarList(interestingClass, &count);
    NSMutableArray *ivarArray = [NSMutableArray arrayWithCapacity:count];
    for (u_int i = 0; i < count ; i++)
    {
        const char *ivarName = ivar_getName(ivars[i]);
        [ivarArray addObject:[NSString  stringWithCString:ivarName encoding:NSUTF8StringEncoding]];
    }
    free(ivars);
    
    objc_property_t *properties = class_copyPropertyList(interestingClass, &count);
    NSMutableArray *propertyArray = [NSMutableArray arrayWithCapacity:count];
    for (u_int i = 0; i < count ; i++)
    {
        const char *propertyName = property_getName(properties[i]);
        [propertyArray addObject:[NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
    }
    free(properties);
    
    Method *methods = class_copyMethodList(interestingClass, &count);
    NSMutableArray *methodArray = [NSMutableArray arrayWithCapacity:count];
    for (u_int i = 0; i < count ; i++)
    {
        SEL selector = method_getName(methods[i]);
        const char *methodName = sel_getName(selector);
        [methodArray addObject:[NSString  stringWithCString:methodName encoding:NSUTF8StringEncoding]];
    }
    free(methods);
    
    NSDictionary *classDump = [NSDictionary dictionaryWithObjectsAndKeys:
                               ivarArray, @"ivars",
                               propertyArray, @"properties",
                               methodArray, @"methods",
                               nil];
    
    NSLog(@"%@: %@", interestingClass, classDump);
}


- (id)getValueForIvarWithName:(NSString *)iVarName class:(Class)aClass
{
    id value = nil;

    const char *name = [iVarName cStringUsingEncoding:NSUTF8StringEncoding];

    u_int count;
    Ivar *ivars = class_copyIvarList(aClass, &count);
    for (u_int i = 0; i < count ; i++)
    {
        Ivar anIvar = ivars[i];
        const char *ivarName = ivar_getName(anIvar);
        if (strcmp(ivarName, name) == 0) {

            value = object_getIvar(self, anIvar);
            break;
        }
    }
    free(ivars);

    return value;
}

//- (CGPathRef)getPathForIvarWithName:(NSString *)iVarName class:(Class)aClass
//{
//    struct CGPath *path = NULL;
//
//    const char *name = [iVarName cStringUsingEncoding:NSUTF8StringEncoding];
//
//    u_int count;
//    Ivar *ivars = class_copyIvarList(aClass, &count);
//    for (u_int i = 0; i < count ; i++)
//    {
//        Ivar anIvar = ivars[i];
//        const char *ivarName = ivar_getName(anIvar);
//        if (strcmp(ivarName, name) == 0) {
//
//            const char *typeEncoding = ivar_getTypeEncoding(anIvar);
//            if (strcmp(typeEncoding, "^{CGPath=}") == 0) {
//
//                //value = object_getIvar(self, anIvar);
//                path = ((struct CGPath * (*)(id, Ivar))object_getIvar)(self, anIvar);
//            }
//            else {
//                DLog(@"Unexpected type encoding \"%s\" for CGPath ivar named \"%@\"", typeEncoding, iVarName);
//            }
//
//            break;
//        }
//    }
//    free(ivars);
//    
//    return path;
//}

@end
