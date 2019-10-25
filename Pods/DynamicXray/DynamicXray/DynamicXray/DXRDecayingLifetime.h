//
//  DXRDecayingLifetime.h
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

#import <Foundation/Foundation.h>

@interface DXRDecayingLifetime : NSObject

@property (assign, nonatomic, readonly) NSUInteger referenceCount;

@property (assign, nonatomic, readonly) float decay;  // 1.0 -> 0

@property (assign, nonatomic) NSTimeInterval decayTime;

@property (strong, nonatomic) NSDictionary *userInfo;

- (void)incrementReferenceCount;
- (void)decrementReferenceCount;
- (void)zeroReferenceCount;

@end
