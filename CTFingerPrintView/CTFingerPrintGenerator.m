//
//  CTFingerPrintGenerator.m
//  CTFingerPrint
//
//  Created by David Fumberger on 8/09/2014.
//  Copyright (c) 2014 Collect3 Pty Ltd. All rights reserved.
//

#import "CTFingerPrintGenerator.h"

#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__ * 180.0) / M_PI)

#define ANGLE_ZERO 270
typedef struct {
    CGPoint center;
    float radius;
    float startAngle;
    float endAngle;
} Circle;

@interface CTFingerPrintGenerator()
@property (nonatomic, assign) NSUInteger segmentResolution;
@end

@implementation CTFingerPrintGenerator
- (id)init {
    if (self = [super init]) {
        // Amount of padding to add
        self.centerPadding = CGPointMake(4, 4);
        
        self.contentWidth = 150;
        
        // Segment 'resolution'
        self.segmentResolution = 30;
        
        // Number of rings
        self.numberOfRings = 7;
        
        // Defaults
        self.minSegmentLength = (self.contentWidth * 0.2);// 30.0f;
        self.maxEmptySegmentLength = (self.contentWidth * 0.06);// 10.0f;
        self.maxFilledSegmentLength = (self.contentWidth * 0.75);// 10.0f;
    }
    return self;
}

- (UIBezierPath*)drawArcFromCenter:(CGPoint)center
                            radius:(float)radius
                        startAngle:(float)startAngle
                          endAngle:(float)endAngle
                      appendToPath:(UIBezierPath*)path
                             paths:(NSMutableArray*)paths
                         clockwise:(BOOL)clock
              currentSegmentLength:(float*)currentSegmentLength
                              type:(NSInteger)type {
    
    // The path we'll be appending to
    UIBezierPath *workingPath = path;
    
    // Reset angle to zero if 360
    if (endAngle >= 360)   { endAngle -= 360; }
    if (startAngle >= 360) { startAngle -= 360; }
    
    // Work out how far apart each segment is
    float segmentAngle = (endAngle - startAngle) / self.segmentResolution;
    BOOL lastDidDraw = YES;
    
    
    float currentAngle = startAngle;
    
    for (int i = 0; i < self.segmentResolution; i++) {
        // Randomly decide whether to draw
        BOOL shouldDraw = ((rand() % 20) != 0) || (i == 0);
        
        float segmentStartAngle = DEGREES_TO_RADIANS(currentAngle);
        float segmentEndAngle   = DEGREES_TO_RADIANS(currentAngle + segmentAngle);
        
        // Add to the current known segment length
        if (currentSegmentLength) {
            float length = fabs((segmentStartAngle - segmentEndAngle) * radius);
            *currentSegmentLength += length;
        }
        
        // If the draw state is changing validate we've hit the minimum segment length.
        if (lastDidDraw != shouldDraw) {
            // If not , continuing drawing with the previous state
            if (*currentSegmentLength < self.minSegmentLength) {
                shouldDraw = lastDidDraw;
                // Otherwise start reset the current segment length.
            } else {
                *currentSegmentLength = 0;
            }
        }
        
        // If we're in a empty draw state, validate we dont go larger than maxEmptySegmentLength.
        // This is so gaps dont look too big
        if (!shouldDraw && *currentSegmentLength > self.maxEmptySegmentLength) {
            shouldDraw = YES;
            *currentSegmentLength = 0;
        }
        
        // If we're in a empty draw state, validate we dont go larger than maxEmptySegmentLength.
        // This is so gaps dont look too big
        if (shouldDraw && *currentSegmentLength > self.maxFilledSegmentLength) {
            shouldDraw = NO;
            *currentSegmentLength = 0;
        }
        
        // When it's a 'right' side curve, look ahead to make sure we always end up with a line hitting the outer radius
        float lengthToEndAngle = fabs((DEGREES_TO_RADIANS(currentAngle) - DEGREES_TO_RADIANS(endAngle)) * radius);
        if ((lengthToEndAngle < (self.minSegmentLength / 2.0)) && type == 2) {
            shouldDraw = YES;
        }
        
        
        
        // Record last state drawing / not drawing
        lastDidDraw = shouldDraw;
        
        if (shouldDraw) {
            
            // Start a new path if nescessary
            if (workingPath == nil) { workingPath = [[UIBezierPath alloc] init]; }
            
            // Add the segment to the current path
            [workingPath addArcWithCenter:CGPointMake(center.x , center.y)
                                   radius:radius
                               startAngle:segmentStartAngle
                                 endAngle:segmentEndAngle
                                clockwise:clock];
        } else {
            
            // If switching to not drawing, then add the current path to the list of paths
            // and reset to nil
            if (workingPath) {
                [paths addObject: workingPath];
                *currentSegmentLength = 0;
            }
            workingPath = nil;
        }
        
        // Increment the angle
        currentAngle += segmentAngle;
    }
    
    return workingPath;
}

- (NSArray*)generateBezierPaths {
    CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
    
    srand(CFAbsoluteTimeGetCurrent());
    NSMutableArray *allPaths = [[NSMutableArray alloc] init];
    
    for (int mainCircle = 0; mainCircle < self.numberOfRings; mainCircle++) {
        
        UIBezierPath *path = nil;
        
        // Keeps track of how long the current segment is in total.
        float currentSegmentLength = 0;
        
        // Left
        Circle leftLine = [self bottomLineForCircle: (self.numberOfRings - 1) - mainCircle];
        path = [self drawArcFromCenter: leftLine.center
                                radius: leftLine.radius
                            startAngle: leftLine.endAngle
                              endAngle: leftLine.startAngle
                          appendToPath: path
                                 paths: allPaths
                             clockwise: NO
                  currentSegmentLength: &currentSegmentLength
                                  type: 0];
        
        // Top / Center
        path = [self drawArcFromCenter: CGPointMake(self.contentWidth / 2.0, self.contentWidth / 2.0)
                                radius: ((mainCircle + 1) * (self.contentWidth / self.numberOfRings)) / 2.0f
                            startAngle: ANGLE_ZERO + 270
                              endAngle: ANGLE_ZERO + 360 + 90
                          appendToPath: path
                                 paths: allPaths
                             clockwise: YES
                  currentSegmentLength: &currentSegmentLength
                                  type: 1];
        
        // Right. Don't draw for the last outer ring
        if (mainCircle < (self.numberOfRings - 1)) {
            Circle rightLine = [self bottomLineForCircle: (self.numberOfRings + 1) + mainCircle ];
            path = [self drawArcFromCenter: rightLine.center
                                    radius: rightLine.radius
                                startAngle: rightLine.startAngle
                                  endAngle: rightLine.endAngle
                              appendToPath: path
                                     paths: allPaths
                                 clockwise: YES
                      currentSegmentLength: &currentSegmentLength
                                      type: 2];
        }
        
        if (path) {
            [allPaths addObject: path];
            path = nil;
        }
        
        // Middle line
        if (mainCircle == 0) {
            currentSegmentLength = 0;
            Circle centerLine = [self bottomLineForCircle: self.numberOfRings];
            path = [self drawArcFromCenter:centerLine.center
                                    radius:centerLine.radius
                                startAngle:centerLine.endAngle
                                  endAngle:centerLine.startAngle
                              appendToPath:nil
                                     paths:allPaths
                                 clockwise:NO
                      currentSegmentLength:&currentSegmentLength
                                      type: 1];
            if (path) { [allPaths addObject: path]; }
        }
    }
    float rotation = -DEGREES_TO_RADIANS((rand() % 10) + 10) ;
    for (UIBezierPath *path in allPaths) {
        [path applyTransform: CGAffineTransformMakeTranslation(-self.contentWidth / 2.0, -self.contentWidth / 2.0)];
        [path applyTransform: CGAffineTransformMakeRotation(rotation)];
        [path applyTransform: CGAffineTransformMakeTranslation(self.contentWidth / 2.0, self.contentWidth / 2.0)];
        [path applyTransform: CGAffineTransformMakeTranslation(self.centerPadding.x, self.centerPadding.y)];
    }
    
    //NSLog(@"CTFingerPrintGenerator: Generate Time %f", CFAbsoluteTimeGetCurrent() - t);
    return allPaths;
}

- (Circle)bottomLineForCircle:(NSInteger)outerCircleNum {
    
    CGPoint center     = CGPointMake(0, self.contentWidth /  2.0);
    float radius     = (outerCircleNum * (self.contentWidth / self.numberOfRings)) / 2.0f;
    float startAngle = ANGLE_ZERO + 90;
    CGPoint innerCircleCenter     = CGPointMake(self.contentWidth / 2.0f, self.contentWidth /  2.0);
    
    Circle innerCircle = (Circle){ innerCircleCenter, self.contentWidth / 2.0, 0, 360 };
    Circle outerCircle = (Circle){ center, radius, 0, 360 };
    
    // Find the points where the circle intersects with the outside of the main circle
    CGPoint pointOneIntersect = CGPointZero;
    CGPoint pointTwoIntersect = CGPointZero;
    [self findIntersectionOfCircle:innerCircle circle:outerCircle sol1:&pointOneIntersect sol2:&pointTwoIntersect];
    
    float angle = [self angleBetweenPoints:pointTwoIntersect point2:center];
    return (Circle){ center, radius, startAngle,RADIANS_TO_DEGREES( angle) * -1 };
}

- (float) angleBetweenPoints:(CGPoint)point1 point2:(CGPoint)point2 {
    float deltaX = point1.x - point2.x;
    float deltaY = point1.y - point2.y;
    
    float angle_rad = atan2(deltaY,deltaX);
    return angle_rad;
}

- (NSUInteger) findIntersectionOfCircle: (Circle)c1 circle:(Circle)c2 sol1:(CGPoint *)sol1 sol2:(CGPoint *)sol2 {
    //Calculate distance between centres of circle
    float dx = (c2.center.x-c1.center.x);
    float dy = (c2.center.y-c1.center.y);
    float d = sqrt(dx*dx + dy*dy);
    
    float c1r = c1.radius;
    float c2r = c2.radius;
    float m = c1r + c2r;
    float n = c1r - c2r;
    
    if (n < 0)
        n = n * -1;
    
    // No solns
    if ( d > m )
        return 0;
    
    // Circle are contained within each other
    if ( d < n )
        return 0;
    
    // Circles are the same
    if ( d == 0 && c1r == c2r )
        return -1;
    
    // Solve for a
    float a = ( c1r * c1r - c2r * c2r + d * d ) / (2 * d);
    
    // Solve for h
    float h = sqrt( c1r * c1r - a * a );
    
    // Calculate point p, where the line through the circle intersection points crosses the line between the circle centers.
    CGPoint p;
    
    p.x = c1.center.x + ( a / d ) * ( c2.center.x - c1.center.x );
    p.y = c1.center.y + ( a / d ) * ( c2.center.y - c1.center.y );
    
    // 1 soln , circles are touching
    if ( d == c1r + c2r ) {
        *sol1 = p;
        return 1;
    }
    // 2solns
    CGPoint p1;
    CGPoint p2;
    
    p1.x = p.x + ( h / d ) * ( c2.center.y - c1.center.y );
    p1.y = p.y - ( h / d ) * ( c2.center.x - c1.center.x );
    
    p2.x = p.x - ( h / d ) * ( c2.center.y - c1.center.y );
    p2.y = p.y + ( h / d ) * ( c2.center.x - c1.center.x );
    
    *sol1 = p1;
    *sol2 = p2;
    
    return 2;	
}
@end
