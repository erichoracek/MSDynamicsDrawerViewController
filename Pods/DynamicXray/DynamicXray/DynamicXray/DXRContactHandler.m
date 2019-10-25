//
//  DXRContactHandler.m
//  DynamicXray
//
//  Created by Chris Miles on 10/01/2014.
//  Copyright (c) 2014 Chris Miles. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "DXRContactHandler.h"
@import UIKit;

@import ObjectiveC.runtime;

#import "NSObject+CMObjectIntrospection.h"


/*
    Mimic PKPhysicsBody shapeType enum
 */
typedef NS_ENUM(NSInteger, DXRPhysicsBodyShapeType)
{
    DXRPhysicsBodyShapeTypeUnknown0     = 0,
    DXRPhysicsBodyShapeTypeUnknown1,
    DXRPhysicsBodyShapeTypeRectangle    = 2,
    DXRPhysicsBodyShapeTypeUnknown3,
    DXRPhysicsBodyShapeTypeEdge         = 4,
    DXRPhysicsBodyShapeTypeUnknown5,
    DXRPhysicsBodyShapeTypeEdgeLoop     = 6,
};


typedef NS_ENUM(NSInteger, DXRContactType)
{
    DXRContactTypeBegin = 0,
    DXRContactTypeEnd,
};


NSString * const DXRDynamicXrayContactDidBeginNotification = @"DXRDynamicXrayContactDidBeginNotification";
NSString * const DXRDynamicXrayContactDidEndNotification = @"DXRDynamicXrayContactDidEndNotification";


@implementation DXRContactHandler

#pragma mark - Handle Contact with PKPhysicsContact

+ (void)handleBeginContactWithPhysicsContact:(PKPhysicsContact *)physicsContact
{
    PKPhysicsBody *bodyA = physicsContact.bodyA;
    PKPhysicsBody *bodyB = physicsContact.bodyB;

    [self handleContactWithPhysicsBody:bodyA type:DXRContactTypeBegin];
    [self handleContactWithPhysicsBody:bodyB type:DXRContactTypeBegin];
}

+ (void)handleEndContactWithPhysicsContact:(PKPhysicsContact *)physicsContact
{
    PKPhysicsBody *bodyA = physicsContact.bodyA;
    PKPhysicsBody *bodyB = physicsContact.bodyB;

    [self handleContactWithPhysicsBody:bodyA type:DXRContactTypeEnd];
    [self handleContactWithPhysicsBody:bodyB type:DXRContactTypeEnd];
}


#pragma mark - Handle Contact with Physics Bodies

+ (void)handleContactWithPhysicsBody:(PKPhysicsBody *)body type:(DXRContactType)contactType
{
    NSUInteger bodyContactsCount = [[body allContactedBodies] count];
    NSInteger shapeType = [[body valueForKey:@"_shapeType"] integerValue];

    if (shapeType == DXRPhysicsBodyShapeTypeEdgeLoop) {
        Class bodyClass = NSClassFromString(@"PKPhysicsBody");

        if ([self isMinimumSystemVersion:@"7.1"]) {
            // object_getIvar() crashes on 7.0; works on 7.1
            CGPathRef path = CFBridgingRetain([body getValueForIvarWithName:@"_path" class:bodyClass]);
            if (path) {
                [self handleContactWithShapePath:path type:contactType contactsCount:bodyContactsCount];
                CFRelease(path);
            }
        }
    }
    else if (shapeType == DXRPhysicsBodyShapeTypeEdge) {
        NSValue *p0obj = [body valueForKey:@"p0"];
        NSValue *p1obj = [body valueForKey:@"p1"];
        if (p0obj && p1obj) {
            CGPoint p0 = [p0obj CGPointValue];
            CGPoint p1 = [p1obj CGPointValue];

            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:p0];
            [path addLineToPoint:p1];

            [self handleContactWithShapePath:path.CGPath type:contactType contactsCount:bodyContactsCount];
        }
    }

    id object = body.representedObject;

    //DLog(@"physicsContact: %@", physicsContact);
    //NSInteger dynamicType = [[body valueForKey:@"_dynamicType"] integerValue];
    //DLog(@"body: %@ object: %@ dynamicType=%ld shapeType=%ld", body, object, (long)dynamicType, (long)shapeType);

    if (object) {
        [self handleContactWithObject:object type:contactType contactsCount:bodyContactsCount];
    }

}


#pragma mark - Handle Contact with Objects

+ (void)handleContactWithObject:(id)object type:(DXRContactType)contactType contactsCount:(NSUInteger)contactsCount
{
    if (object && [object conformsToProtocol:@protocol(UIDynamicItem)]) {
        //DLog(@"DynamicItem began contact %@", object);

        NSString *notificationName = (contactType == DXRContactTypeBegin ? DXRDynamicXrayContactDidBeginNotification : DXRDynamicXrayContactDidEndNotification);
        NSDictionary *userInfo = @{@"dynamicItem": object, @"contactsCount": @(contactsCount)};
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    }
    else {
        DLog(@"Unhandled contact object: %@", object);
    }
}


#pragma mark - Handle Contact with Shape Path

+ (void)handleContactWithShapePath:(CGPathRef)path type:(DXRContactType)contactType contactsCount:(NSUInteger)contactsCount
{
    if (path) {
        NSString *notificationName = (contactType == DXRContactTypeBegin ? DXRDynamicXrayContactDidBeginNotification : DXRDynamicXrayContactDidEndNotification);
        id obj = (__bridge id)(path);
        NSDictionary *userInfo = @{@"path": obj, @"contactsCount": @(contactsCount)};
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    }
}


#pragma mark - System Version Comparison

+ (BOOL)isMinimumSystemVersion:(NSString *)minimumVersion
{
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    return ([minimumVersion compare:systemVersion options:NSNumericSearch] != NSOrderedDescending);
}

@end
