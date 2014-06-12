//
//  DXRPushBehaviorSnapshot+DXRDrawing.m
//  DynamicXray
//
//  Created by Chris Miles on 21/01/2014.
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

#import "DXRPushBehaviorSnapshot+DXRDrawing.h"

static CGFloat const DXRPushBehaviorLineMagnitudeScaleFactor = 50.0f;
static CGFloat const DXRPushBehaviorLineWidth = 3.0f;
static CGFloat const DXRPushBehaviorMaxArrowHeadLength = 40.0f;
static CGFloat const DXRPushBehaviorMinimalLineLength = 20.0f;


@implementation DXRPushBehaviorSnapshot (DXRDrawing)

- (void)drawInContext:(CGContextRef)context
{
    if (self.magnitude > 0) {
        CGPoint pushLocation = self.pushLocation;
        CGFloat lineAngle = self.angle;
        CGFloat lineLength = self.magnitude * DXRPushBehaviorLineMagnitudeScaleFactor;
        if (lineLength < DXRPushBehaviorMinimalLineLength) lineLength = DXRPushBehaviorMinimalLineLength;

        CGPoint lineStartLocation = CGPointMake(pushLocation.x - lineLength * (CGFloat)cos(lineAngle), pushLocation.y - lineLength * (CGFloat)sin(lineAngle));

        CGFloat arrowHeadLength = (CGFloat)fmin(lineLength * 0.3f, DXRPushBehaviorMaxArrowHeadLength);
        CGFloat arrowHeadAngle1 = lineAngle + (150.0f * (CGFloat)M_PI / 180.0f);
        CGFloat arrowHeadAngle2 = lineAngle - (150.0f * (CGFloat)M_PI / 180.0f);
        CGPoint arrowHeadEndPoint1 = CGPointMake(pushLocation.x + (CGFloat)cos(arrowHeadAngle1)*arrowHeadLength, pushLocation.y + (CGFloat)sin(arrowHeadAngle1)*arrowHeadLength);
        CGPoint arrowHeadEndPoint2 = CGPointMake(pushLocation.x + (CGFloat)cos(arrowHeadAngle2)*arrowHeadLength, pushLocation.y + (CGFloat)sin(arrowHeadAngle2)*arrowHeadLength);

        CGFloat circleRadius = 0.5f;

        if (circleRadius > 0) {
            // Draw circle at push location
            CGContextAddEllipseInRect(context, CGRectMake(pushLocation.x - circleRadius, pushLocation.y - circleRadius, circleRadius*2.0f, circleRadius*2.0f));
            CGContextDrawPath(context, kCGPathFillStroke);
        }

        CGContextSetLineWidth(context, DXRPushBehaviorLineWidth);

        // Animate the line dash
        CGFloat dashPhase = (CGFloat) -fmod([[NSDate date] timeIntervalSinceReferenceDate] * 20.0, 6.0);
        const CGFloat dashPattern[2] = {3.0f, 3.0f};
        CGContextSetLineDash(context, dashPhase, dashPattern, 2);

        // Draw push line
        CGContextMoveToPoint(context, lineStartLocation.x, lineStartLocation.y);
        CGContextAddLineToPoint(context, pushLocation.x, pushLocation.y);

        // Draw arrow head
        CGContextAddLineToPoint(context, arrowHeadEndPoint1.x, arrowHeadEndPoint1.y);
        CGContextMoveToPoint(context, pushLocation.x, pushLocation.y);
        CGContextAddLineToPoint(context, arrowHeadEndPoint2.x, arrowHeadEndPoint2.y);

        CGContextStrokePath(context);
    }
}

@end
