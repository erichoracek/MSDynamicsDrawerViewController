//
//  DXRDecayingLifetime.m
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

#import "DXRDecayingLifetime.h"

static NSTimeInterval const DXRDefaultDecayTime = 0.2;    // decay time in seconds


@interface DXRDecayingLifetime ()

@property (assign, nonatomic, readwrite) NSUInteger referenceCount;

@property (assign, nonatomic) NSTimeInterval allReferencesEndedTime;

@end


@implementation DXRDecayingLifetime

- (instancetype)init
{
    self = [super init];
    if (self) {
        _decayTime = DXRDefaultDecayTime;
    }
    return self;
}

- (void)incrementReferenceCount
{
    self.referenceCount += 1;
    self.allReferencesEndedTime = 0;
}

- (void)decrementReferenceCount
{
    if (self.referenceCount > 0) self.referenceCount -= 1;

    if (self.referenceCount == 0 && self.allReferencesEndedTime <= 0) self.allReferencesEndedTime = [[NSDate date] timeIntervalSinceReferenceDate];
}

- (void)zeroReferenceCount
{
    self.referenceCount = 0;
    if (self.allReferencesEndedTime <= 0) self.allReferencesEndedTime = [[NSDate date] timeIntervalSinceReferenceDate];
}

- (float)decay
{
    float decay = 1.0;

    if (self.referenceCount == 0) {
        if (self.allReferencesEndedTime <= 0) self.allReferencesEndedTime = [[NSDate date] timeIntervalSinceReferenceDate];

        NSTimeInterval currentTime = [[NSDate date] timeIntervalSinceReferenceDate];
        NSTimeInterval decayTime = self.decayTime;

        if (currentTime - self.allReferencesEndedTime > decayTime) {
            decay = 0;
        }
        else {
            decay = (float)(1.0f - (currentTime - self.allReferencesEndedTime) / decayTime);
        }
    }

    return decay;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p referenceCount=%lu>", [self class], self, (unsigned long)self.referenceCount];
}

@end
