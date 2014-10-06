//
//  CTFingerPrintAnimatedView.m
//  CTFingerPrint
//
//  Created by David Fumberger on 8/09/2014.
//  Copyright (c) 2014 Collect3 Pty Ltd. All rights reserved.
//

#import "CTFingerPrintAnimatedView.h"
#import "CTFingerPrintView.h"
#import "CTFingerPrintGenerator.h"

@interface CTFingerPrintAnimatedView()
@property (nonatomic, strong) CTFingerPrintView *backgroundView;
@property (nonatomic, strong) CTFingerPrintView *foregroundView;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger cycleIndex;
@property (nonatomic, assign) BOOL cycleDirection;
@end

@implementation CTFingerPrintAnimatedView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        
        // Use CTFingerPrintGenerator to create a unique finger print for the finger every time
        // It will return an array of beziers to be used by the finger
        CTFingerPrintGenerator *generator = [[CTFingerPrintGenerator alloc] init];
        generator.numberOfRings = 10;
        NSArray *beziers = [generator generateBezierPaths];
        
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView  = [[CTFingerPrintView alloc] initWithFrame: self.bounds beziers: beziers];
        self.backgroundView.tintColor = [UIColor lightGrayColor];
        self.backgroundView.center = self.center;
        self.backgroundView.lineWidth = 4.0;
        [self.backgroundView showAllRidges];
        [self addSubview: self.backgroundView];
        
        self.foregroundView = [[CTFingerPrintView alloc] initWithFrame: self.bounds beziers: beziers];
        self.foregroundView.center = self.center;
        self.foregroundView.lineWidth = 4.0;
        [self addSubview: self.foregroundView];
        
        self.tintColor =  [UIColor colorWithRed:0.4
                                          green:0.5
                                           blue:0.7 alpha:1.0];
    }
    return self;
}

- (void)tintColorDidChange {
    [super tintColorDidChange];
    self.foregroundView.tintColor = self.tintColor;
}

- (void)startAnimation:(CTFingerPrintAnimationMode)animationMode {
    if (self.isAnimating) { return; }
    _animationMode = animationMode;
    self.cycleIndex = 0;
    self.cycleDirection = 0;
    [self animateForeground];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(animationMode == CTFingerPrintAnimationModeRandom) ? 0.25 : 0.15 target:self selector:@selector(animateForeground) userInfo:nil repeats:YES];
}

- (BOOL)isAnimating {
    return (self.animationMode != CTFingerPrintAnimationModeNone);
}

- (void)stopAnimation {
    if (!self.isAnimating) { return; }
    _animationMode = CTFingerPrintAnimationModeNone;
    [self.timer invalidate];
    self.timer = nil;
}

- (void)highlightWithColor:(UIColor*)color animated:(BOOL)animated {
    if (animated) {
        [self.foregroundView beginTintColorAnimation];
    }
    self.foregroundView.tintColor = color;
    if (animated) {
        [self.foregroundView endTintColorAnimation: ^(void) { }];
    }
}
- (void)revertHighlightColorAnimated:(BOOL)animated {
    if (animated) {
        [self.foregroundView beginTintColorAnimation];
    }
    self.foregroundView.tintColor = self.tintColor;
    if (animated) {
        [self.foregroundView endTintColorAnimation: ^(void) { }];
    }
}
- (void)showAllVisible:(BOOL)visibleState animated:(BOOL)animated duration:(float)duration {
    for (FingerRidgePath *ridge in self.foregroundView.ridges) {
        [ridge setVisible:visibleState animated:animated duration: duration];
    }
}

- (void)animateForeground {
    if (self.animationMode == CTFingerPrintAnimationModeRandom) {
        for (FingerRidgePath *ridge in self.foregroundView.ridges) {
            if (self.animationMode == CTFingerPrintAnimationModeRandom) {
                if (ridge.isAnimating) {
                    continue;
                }
                if ((rand() % 8) == 0) {
                    [ridge setVisible:!ridge.visible animated:YES];
                }
            }
        }
    } else if (self.animationMode == CTFingerPrintAnimationModeCycleUpDown) {
        FingerRidgePath *ridge = nil;
        if (self.cycleIndex >= 0 && self.cycleIndex < [self.foregroundView.ridges count]) {
            ridge = [self.foregroundView.ridges objectAtIndex: self.cycleIndex];
        }
        if (self.cycleDirection == 0) {
            [ridge setVisible:YES animated:YES];
            self.cycleIndex++;
            
            // Pad out the cycle index here to wait for animations to finish
            if (self.cycleIndex >= [self.foregroundView.ridges count] + 10) {
                self.cycleIndex = [self.foregroundView.ridges count] - 1;
                self.cycleDirection = !self.cycleDirection;
            }
        } else {
            [ridge setVisible:NO animated:YES];
            self.cycleIndex--;
            if (self.cycleIndex < -10) {
                self.cycleIndex = 0;
                self.cycleDirection = !self.cycleDirection;
            }
        }
    }
}

@end
