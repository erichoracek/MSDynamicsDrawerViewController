//
//  DXRDynamicXrayConfigurationFaderView.m
//  DynamicXray
//
//  Created by Chris Miles on 5/03/2014.
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

#import "DXRDynamicXrayConfigurationFaderView.h"
#import "DXRAssetBytesIconNoOverlay.png.h"
#import "DXRAssetBytesIconNoOverlay@2x.png.h"
#import "DXRAssetBytesIconOverlay.png.h"
#import "DXRAssetBytesIconOverlay@2x.png.h"


@interface DXRDynamicXrayConfigurationFaderView ()

@property (strong, nonatomic, readwrite) UISlider *faderSlider;

@end


@implementation DXRDynamicXrayConfigurationFaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UISlider *faderSlider = [[UISlider alloc] initWithFrame:CGRectZero];

        UIImageView *iconNoOverlayView = [[UIImageView alloc] initWithImage:[self iconNoOverlayImage]];
        UIImageView *iconOverlayView = [[UIImageView alloc] initWithImage:[self iconOverlayImage]];

        [self addSubview:iconNoOverlayView];
        [self addSubview:iconOverlayView];
        [self addSubview:faderSlider];

        faderSlider.translatesAutoresizingMaskIntoConstraints = NO;
        iconNoOverlayView.translatesAutoresizingMaskIntoConstraints = NO;
        iconOverlayView.translatesAutoresizingMaskIntoConstraints = NO;

        NSDictionary *layoutMetrics = @{@"margin": @(10.0f)};
        NSDictionary *layoutViews = NSDictionaryOfVariableBindings(faderSlider, iconNoOverlayView, iconOverlayView);

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[iconNoOverlayView]-(margin)-[faderSlider]-(margin)-[iconOverlayView]|"
                                                                     options:NSLayoutFormatAlignAllCenterY
                                                                     metrics:layoutMetrics
                                                                       views:layoutViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[iconNoOverlayView]-(>=0)-|"
                                                                     options:0
                                                                     metrics:layoutMetrics
                                                                       views:layoutViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[faderSlider]-(>=0)-|"
                                                                     options:0
                                                                     metrics:layoutMetrics
                                                                       views:layoutViews]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[iconOverlayView]-(>=0)-|"
                                                                     options:0
                                                                     metrics:layoutMetrics
                                                                       views:layoutViews]];

        self.faderSlider = faderSlider;
    }
    return self;
}

- (UIImage *)iconNoOverlayImage
{
    UIScreen *screen = (self.window.screen ?: [UIScreen mainScreen]);
    CGFloat scale = screen.scale;

    unsigned char *imageBytes = (scale >= 2.0 ? DXRAssetBytesIconNoOverlay2xPNG : DXRAssetBytesIconNoOverlayPNG);
    unsigned long imageBytesCount = (scale >= 2.0 ? DXRAssetBytesIconNoOverlay2xPNG_size : DXRAssetBytesIconNoOverlayPNG_size);
    NSData *imageData = [NSData dataWithBytes:imageBytes length:imageBytesCount];
    UIImage *image = [UIImage imageWithData:imageData scale:scale];
    return image;
}

- (UIImage *)iconOverlayImage
{
    UIScreen *screen = (self.window.screen ?: [UIScreen mainScreen]);
    CGFloat scale = screen.scale;

    unsigned char *imageBytes = (scale >= 2.0 ? DXRAssetBytesIconOverlay2xPNG : DXRAssetBytesIconOverlayPNG);
    unsigned long imageBytesCount = (scale >= 2.0 ? DXRAssetBytesIconOverlay2xPNG_size : DXRAssetBytesIconOverlayPNG_size);
    NSData *imageData = [NSData dataWithBytes:imageBytes length:imageBytesCount];
    UIImage *image = [UIImage imageWithData:imageData scale:scale];
    return image;
}

@end
