//
//  DXRGravityBehaviorSnapshot+DXRDrawing.m
//  DynamicXray
//
//  Created by Chris Miles on 14/10/13.
//  Copyright (c) 2013-2014 Chris Miles. All rights reserved.
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

#import "DXRGravityBehaviorSnapshot+DXRDrawing.h"
#import "DynamicXray+XrayView.h"
@import UIKit;

static CGFloat const circleDiameter = 40.0f;
static CGFloat const arrowHeadPointOffsetAngle = 0.25f;


@implementation DXRGravityBehaviorSnapshot (DXRDrawing)

- (void)drawInContext:(CGContextRef)context
{
    CGRect circleFrame = CGRectMake(20.0f, 70.0f, circleDiameter, circleDiameter);
    CGPoint circleCenter = CGPointMake(CGRectGetMidX(circleFrame), CGRectGetMidY(circleFrame));

    CGFloat angle = self.angle;
    CGFloat arrowRadius = circleDiameter / 2.0f - 1.0f;
    CGPoint arrowEndPoint = CGPointMake(circleCenter.x + arrowRadius * (CGFloat)cos(angle), circleCenter.y + arrowRadius * (CGFloat)sin(angle));
    CGFloat arrowHeadPointEndRadius = arrowRadius * 0.7f;
    CGPoint arrowHeadPoint1 = CGPointMake(circleCenter.x + arrowHeadPointEndRadius * (CGFloat)cos(angle-arrowHeadPointOffsetAngle),
                                          circleCenter.y + arrowHeadPointEndRadius * (CGFloat)sin(angle-arrowHeadPointOffsetAngle));
    CGPoint arrowHeadPoint2 = CGPointMake(circleCenter.x + arrowHeadPointEndRadius * (CGFloat)cos(angle+arrowHeadPointOffsetAngle),
                                          circleCenter.y + arrowHeadPointEndRadius * (CGFloat)sin(angle+arrowHeadPointOffsetAngle));

    // Draw circle
    CGContextSetLineWidth(context, 1.0f);
    CGContextAddEllipseInRect(context, circleFrame);
    CGContextDrawPath(context, kCGPathStroke);

    // Draw arrow
    CGContextMoveToPoint(context, arrowEndPoint.x, arrowEndPoint.y);
    CGContextAddLineToPoint(context, arrowHeadPoint1.x, arrowHeadPoint1.y);
    CGContextMoveToPoint(context, arrowEndPoint.x, arrowEndPoint.y);
    CGContextAddLineToPoint(context, arrowHeadPoint2.x, arrowHeadPoint2.y);
    CGContextDrawPath(context, kCGPathStroke);

    // Draw label inside circle
    NSString *label = [NSString stringWithFormat:@"%0.1fg", self.magnitude];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    NSDictionary *attr = @{
                           NSParagraphStyleAttributeName: style,
                           NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:11.0f],
                           NSForegroundColorAttributeName: [DynamicXray xrayStrokeColor],
                           };

    CGSize labelSize = [label sizeWithAttributes:attr];
    CGRect labelFrame = CGRectMake(circleFrame.origin.x, circleFrame.origin.y + (CGRectGetHeight(circleFrame) - labelSize.height)/2.0f, CGRectGetWidth(circleFrame), labelSize.height);
    [label drawInRect:labelFrame withAttributes:attr];
}

@end
