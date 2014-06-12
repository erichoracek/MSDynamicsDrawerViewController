//
//  DXRDynamicXrayView.m
//  DynamicXray
//
//  Created by Chris Miles on 4/08/13.
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

#import "DXRDynamicXrayView.h"

#import "DXRBehaviorSnapshotDrawing.h"
#import "DXRAttachmentBehaviorSnapshot.h"
#import "DXRCollisionBehaviorSnapshot.h"
#import "DXRGravityBehaviorSnapshot.h"
#import "DXRSnapBehaviorSnapshot.h"
#import "DXRPushBehaviorSnapshot.h"

#import "DXRDynamicXrayItemSnapshot.h"
#import "DXRDynamicXrayItemSnapshot+DXRDrawing.h"

#import "DXRDecayingLifetime.h"
#import "DXRContactVisualise.h"

#import "DynamicXray+XrayView.h"


@interface DXRDynamicXrayView ()

@property (strong, nonatomic) NSMutableArray *behaviorsToDraw;
@property (strong, nonatomic) NSMutableArray *contactPathsToDraw;
@property (strong, nonatomic) NSMutableArray *dynamicItemsToDraw;

@property (assign, nonatomic) CGSize lastBoundsSize;
@property (assign, nonatomic) CGPoint contactPathsOffset;

@end


@implementation DXRDynamicXrayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _allowsAntialiasing = YES;

        _behaviorsToDraw = [NSMutableArray array];
        _contactPathsToDraw = [NSMutableArray array];
        _dynamicItemsToDraw = [NSMutableArray array];

	self.backgroundColor = [UIColor clearColor];
	self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if ([self sizeHasChanged]) {
        [self setNeedsDisplay];
    }
}

- (BOOL)sizeHasChanged
{
    CGSize size = self.bounds.size;
    if (CGSizeEqualToSize(size, self.lastBoundsSize)) {
        return NO;
    }
    else {
        self.lastBoundsSize = size;
        return YES;
    }
}


#pragma mark - Draw Behaviors

- (void)drawAttachmentFromAnchor:(CGPoint)anchorPoint toPoint:(CGPoint)attachmentPoint length:(CGFloat)length isSpring:(BOOL)isSpring
{
    DXRAttachmentBehaviorSnapshot *attachmentSnapshot = [[DXRAttachmentBehaviorSnapshot alloc] initWithAnchorPoint:anchorPoint attachmentPoint:attachmentPoint length:length isSpring:isSpring];
    [self behaviorSnapshotNeedsDrawing:attachmentSnapshot];
}

- (void)drawCollisionBoundaryWithPath:(UIBezierPath *)path
{
    DXRCollisionBehaviorSnapshot *collisionSnapshot = [[DXRCollisionBehaviorSnapshot alloc] initWithPath:path];
    [self behaviorSnapshotNeedsDrawing:collisionSnapshot];
}

- (void)drawGravityBehaviorWithMagnitude:(CGFloat)magnitude angle:(CGFloat)angle
{
    DXRGravityBehaviorSnapshot *gravitySnapshot = [[DXRGravityBehaviorSnapshot alloc] initWithGravityMagnitude:magnitude angle:angle];
    [self behaviorSnapshotNeedsDrawing:gravitySnapshot];
}

- (void)drawSnapWithAnchorPoint:(CGPoint)anchorPoint forItem:(id<UIDynamicItem>)item
{
    anchorPoint = [self convertPointFromDynamicsReferenceView:anchorPoint];
    CGPoint itemCenter = [self convertPointFromDynamicsReferenceView:item.center];

    DXRSnapBehaviorSnapshot *snapSnapshot = [[DXRSnapBehaviorSnapshot alloc] initWithAnchorPoint:anchorPoint itemCenter:itemCenter itemBounds:item.bounds itemTransform:item.transform];
    [self behaviorSnapshotNeedsDrawing:snapSnapshot];
}

- (void)drawPushWithAngle:(CGFloat)angle magnitude:(CGFloat)magnitude transparency:(CGFloat)transparency atLocation:(CGPoint)pushLocation
{
    DXRPushBehaviorSnapshot *pushSnapshot = [[DXRPushBehaviorSnapshot alloc] initWithAngle:angle magnitude:magnitude location:pushLocation];
    pushSnapshot.transparency = transparency;
    [self behaviorSnapshotNeedsDrawing:pushSnapshot];
}

- (void)behaviorSnapshotNeedsDrawing:(DXRBehaviorSnapshot *)item
{
    [self.behaviorsToDraw addObject:item];

    [self setNeedsDisplay];
}


#pragma mark - Draw Dynamic Items

- (void)drawDynamicItems:(NSSet *)dynamicItems contactedItems:(NSMapTable *)contactedItems
{
    if (dynamicItems && [dynamicItems count] > 0) {
        for (id<UIDynamicItem> item in dynamicItems) {
            CGRect itemBounds = item.bounds;
            CGPoint itemCenter = [self convertPointFromDynamicsReferenceView:item.center];
            CGAffineTransform itemTransform = item.transform;

            DXRDecayingLifetime *contactLifetime = [contactedItems objectForKey:item];
            BOOL isContacted = (contactLifetime && contactLifetime.decay > 0);

            DXRDynamicXrayItemSnapshot *itemSnapshot = [DXRDynamicXrayItemSnapshot snapshotWithBounds:itemBounds center:itemCenter transform:itemTransform contacted:isContacted];
            if (isContacted) itemSnapshot.contactedAlpha = contactLifetime.decay;
            [self.dynamicItemsToDraw addObject:itemSnapshot];
        }

        [self setNeedsDisplay];
    }
}


#pragma mark - Draw Contact Paths

- (void)drawContactPaths:(NSMapTable *)contactPaths
{
    [self.contactPathsToDraw removeAllObjects];

    NSMutableArray *pathsToDraw = [NSMutableArray array];

    for (id key in contactPaths) {
        // Keys are CGPathRefs
        DXRDecayingLifetime *contactLifetime = [contactPaths objectForKey:key];
        float alpha = [contactLifetime decay];

        if (alpha > 0) {
            DXRContactVisualise *contactVisualise = [[DXRContactVisualise alloc] initWithObjToDraw:key alpha:alpha];
            [pathsToDraw addObject:contactVisualise];
        }
    }

    [self.contactPathsToDraw addObjectsFromArray:pathsToDraw];

    self.contactPathsOffset = [self convertPointFromDynamicsReferenceView:CGPointZero];
}


#pragma mark - Coordinate Conversion

- (CGPoint)convertPointFromDynamicsReferenceView:(CGPoint)point
{
    return [self convertPoint:point fromReferenceView:self.dynamicsReferenceView];
}

- (CGPoint)convertPoint:(CGPoint)point fromReferenceView:(UIView *)referenceView
{
    UIWindow *appWindow = [UIApplication sharedApplication].keyWindow;
    CGPoint result;

    if (referenceView) {
        result = [referenceView convertPoint:point toView:nil];         // convert reference view to its window coords
    }
    else {
        result = [self pointTransformedFromDeviceOrientation:point];    // convert to app window coords
    }

    result = [self.window convertPoint:result fromWindow:appWindow];    // convert to DynamicXray window coords
    result = [self convertPoint:result fromView:nil];                   // convert to DynamicXray view coords

    result.x += self.drawOffset.horizontal;
    result.y += self.drawOffset.vertical;

    return result;
}

- (void)convertPath:(UIBezierPath *)path fromReferenceView:(UIView *)referenceView
{
    CGPoint originOffset = [self convertPoint:CGPointZero fromReferenceView:referenceView];
    CGAffineTransform transform = CGAffineTransformMakeTranslation(originOffset.x, originOffset.y);
    [path applyTransform:transform];
}

- (CGPoint)pointTransformedFromDeviceOrientation:(CGPoint)point
{
    CGPoint result;
    CGSize windowSize = [UIApplication sharedApplication].keyWindow.bounds.size;
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;

    if (statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
        result.x = windowSize.width - point.y;
        result.y = point.x;
    }
    else if (statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        result.x = windowSize.width - point.x;
        result.y = windowSize.height - point.y;
    }
    else if (statusBarOrientation == UIInterfaceOrientationLandscapeLeft) {
        result.x = point.y;
        result.y = windowSize.height - point.x;
    }
    else {
        result = point;
    }

    return result;
}


- (void)calcFPS
{
    // FPS
    static double fps_prev_time = 0;
    static NSUInteger fps_count = 0;

    /* FPS */
    double curr_time = CACurrentMediaTime();
    if (curr_time - fps_prev_time >= 0.5) {
        double delta = (curr_time - fps_prev_time) / fps_count;
        NSString *fpsDescription = [NSString stringWithFormat:@"%0.0f fps", 1.0/delta];
        NSLog(@"    Draw FPS: %@", fpsDescription);
        fps_prev_time = curr_time;
        fps_count = 1;
    }
    else {
        fps_count++;
    }
}


#pragma mark - Drawing

- (void)drawRect:(__unused CGRect)rect
{
    //[self calcFPS];

    UIColor *strokeColor = [DynamicXray xrayStrokeColor];
    UIColor *fillColor = [DynamicXray xrayFillColor];
    UIColor *contactColor = [DynamicXray xrayContactColor];

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect bounds = self.bounds;
    CGContextClipToRect(context, bounds);
    CGContextSetAllowsAntialiasing(context, (bool)self.allowsAntialiasing);

    [strokeColor setStroke];
    [fillColor setFill];

    for (DXRDynamicXrayItemSnapshot *itemSnapshot in self.dynamicItemsToDraw) {
        CGContextSaveGState(context);
        [itemSnapshot drawInContext:context];
        CGContextRestoreGState(context);
    }

    for (DXRBehaviorSnapshot *behavior in self.behaviorsToDraw) {
        if ([behavior conformsToProtocol:@protocol(DXRBehaviorSnapshotDrawing)]) {
            CGContextSaveGState(context);

            if (behavior.transparency > 0) {
                CGFloat alpha = 1.0f - behavior.transparency;
                [[strokeColor colorWithAlphaComponent:alpha] setStroke];
                [[fillColor colorWithAlphaComponent:alpha] setFill];
            }

            [(id<DXRBehaviorSnapshotDrawing>)behavior drawInContext:context];
            CGContextRestoreGState(context);
        }
        else {
            DLog(@"WARNING: DXRBehaviorSnapshot is not drawable: %@", behavior);
        }
    }

    if ([self.contactPathsToDraw count] > 0) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, self.contactPathsOffset.x, self.contactPathsOffset.y);
        CGContextSetLineWidth(context, 3.0f);

        for (DXRContactVisualise *contactVisualise in self.contactPathsToDraw) {
            CGPathRef path = (__bridge CGPathRef)(contactVisualise.objToDraw);
            CGFloat alpha = contactVisualise.alpha;

            CGContextSetStrokeColorWithColor(context, [contactColor colorWithAlphaComponent:alpha].CGColor);

            CGContextAddPath(context, path);
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
    }
    
    [self.behaviorsToDraw removeAllObjects];
    [self.contactPathsToDraw removeAllObjects];
    [self.dynamicItemsToDraw removeAllObjects];
}

@end
