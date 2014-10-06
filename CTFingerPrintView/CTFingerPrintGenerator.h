//
//  CTFingerPrintGenerator.h
//  CTFingerPrint
//
//  Created by David Fumberger on 8/09/2014.
//  Copyright (c) 2014 Collect3 Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface CTFingerPrintGenerator : NSObject
// Padding to shift the paths by
@property (nonatomic, assign) CGPoint centerPadding;

// Width of content to relatively create bezier paths to.
@property (nonatomic, assign) float contentWidth;

// Ring count
@property (nonatomic, assign) NSUInteger numberOfRings;

// Minimum size of any segment
@property (nonatomic, assign) float minSegmentLength;

// Maximum size of an empty segment
@property (nonatomic, assign) float maxEmptySegmentLength;

// Maximum size of a filled segment
@property (nonatomic, assign) float maxFilledSegmentLength;

// Returns bezier paths representing finger prints
- (NSArray*)generateBezierPaths;
@end
