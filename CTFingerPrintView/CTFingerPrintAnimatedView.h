//
//  CTFingerPrintAnimatedView.h
//  CTFingerPrint
//
//  Created by David Fumberger on 8/09/2014.
//  Copyright (c) 2014 Collect3 Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    CTFingerPrintAnimationModeNone,
    CTFingerPrintAnimationModeRandom,
    CTFingerPrintAnimationModeCycleUpDown
} CTFingerPrintAnimationMode;
@interface CTFingerPrintAnimatedView : UIView
/** Current animation mode (if animating) */
@property (nonatomic, readonly) CTFingerPrintAnimationMode animationMode;

/** Returns true if animating */
@property (nonatomic, readonly) BOOL isAnimating;

/** Starts animating the finger print with an animation type */
- (void)startAnimation:(CTFingerPrintAnimationMode)animationMode;

/** Stops animating */
- (void)stopAnimation;

/** Highlights the finger print with a color */
- (void)highlightWithColor:(UIColor*)color animated:(BOOL)animated;

/** Removes the highlight */
- (void)revertHighlightColorAnimated:(BOOL)animated;

/** Shows or hides all ridges */
- (void)showAllVisible:(BOOL)visibleState animated:(BOOL)animated duration:(float)duration;
@end
