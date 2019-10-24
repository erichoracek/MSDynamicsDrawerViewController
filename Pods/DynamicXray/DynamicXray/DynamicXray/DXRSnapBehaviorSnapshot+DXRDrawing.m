//
//  DXRSnapBehaviorSnapshot+DXRDrawing.m
//  DynamicXray
//
//  Created by Chris Miles on 17/01/2014.
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

#import "DXRSnapBehaviorSnapshot+DXRDrawing.h"

static CGFloat const DXRSnapBehaviorLineWidth = 3.0f;


@implementation DXRSnapBehaviorSnapshot (DXRDrawing)

- (void)drawInContext:(CGContextRef)context
{
    CGPoint itemCenter = self.itemCenter;
    CGPoint anchorPoint = self.anchorPoint;

    CGFloat xDiff = self.anchorPoint.x - self.itemCenter.x;
    CGFloat yDiff = self.anchorPoint.y - self.itemCenter.y;
    CGFloat lineLength = (CGFloat)sqrt(xDiff*xDiff + yDiff*yDiff);
    CGFloat arrowHeadLength = lineLength * 0.2f;
    CGFloat lineAngle = (CGFloat)atan2(yDiff, xDiff);
    CGFloat arrowHeadAngle1 = lineAngle + (150.0f * (CGFloat)M_PI / 180.0f);
    CGFloat arrowHeadAngle2 = lineAngle - (150.0f * (CGFloat)M_PI / 180.0f);
    CGPoint arrowHeadEndPoint1 = CGPointMake(anchorPoint.x + (CGFloat)cos(arrowHeadAngle1)*arrowHeadLength, anchorPoint.y + (CGFloat)sin(arrowHeadAngle1)*arrowHeadLength);
    CGPoint arrowHeadEndPoint2 = CGPointMake(anchorPoint.x + (CGFloat)cos(arrowHeadAngle2)*arrowHeadLength, anchorPoint.y + (CGFloat)sin(arrowHeadAngle2)*arrowHeadLength);

    CGContextSetLineWidth(context, DXRSnapBehaviorLineWidth);

    const CGFloat dashPattern[2] = {3.0f, 3.0f};
    CGContextSetLineDash(context, 3, dashPattern, 2);

    CGContextMoveToPoint(context, itemCenter.x, itemCenter.y);
    CGContextAddLineToPoint(context, anchorPoint.x, anchorPoint.y);

    CGContextAddLineToPoint(context, arrowHeadEndPoint1.x, arrowHeadEndPoint1.y);
    CGContextMoveToPoint(context, anchorPoint.x, anchorPoint.y);
    CGContextAddLineToPoint(context, arrowHeadEndPoint2.x, arrowHeadEndPoint2.y);

    CGContextStrokePath(context);
}

@end
