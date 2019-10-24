//
//  DXRDynamicXrayItemSnapshot+DXRDrawing.m
//  DynamicXray
//
//  Created by Chris Miles on 7/11/2013.
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

#import "DXRDynamicXrayItemSnapshot+DXRDrawing.h"
#import "DynamicXray+XrayView.h"

@implementation DXRDynamicXrayItemSnapshot (DXRDrawing)

- (void)drawInContext:(CGContextRef)context
{
    CGRect bounds = self.bounds;

    CGRect clipRect = CGContextGetClipBoundingBox(context);
    if (CGRectIntersectsRect(bounds, clipRect)) {
        CGContextSetShouldAntialias(context, false);

        CGFloat halfWidth = CGRectGetWidth(bounds)/2.0f;
        CGFloat halfHeight = CGRectGetHeight(bounds)/2.0f;

        CGContextTranslateCTM(context, self.center.x - halfWidth, self.center.y - halfHeight);

        CGContextTranslateCTM(context, halfWidth, halfHeight);
        CGContextConcatCTM(context, self.transform);
        CGContextTranslateCTM(context, -halfWidth, -halfHeight);

        CGContextAddRect(context, bounds);

        if (self.isContacted)
        {
            CGContextSaveGState(context);
            CGContextSetStrokeColorWithColor(context, [[DynamicXray xrayContactColor] colorWithAlphaComponent:self.contactedAlpha].CGColor);
        }

        CGContextStrokePath(context);

        if (self.isContacted)
        {
            CGContextRestoreGState(context);
        }
    }
}

@end
