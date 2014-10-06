//
//  CTFingerPrintView.h
//  CTFingerPrint
//
//  Created by David Fumberger on 8/09/2014.
//  Copyright (c) 2014 Collect3 Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface FingerRidgePath : NSObject
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, assign) BOOL visible;
@property (nonatomic, assign) BOOL isAnimating;

/** Changes the visible state of the ridge, optionally animated */
- (void)setVisible:(BOOL)visible animated:(BOOL)animated;
- (void)setVisible:(BOOL)visible animated:(BOOL)animated duration:(float)duration;
@end

@interface CTFingerPrintView : UIView

/** Ridge paths */
@property (nonatomic, strong) NSMutableArray *ridges;

/** Line width of the ridges */
@property (nonatomic, assign) float lineWidth;

/** Creates the finger print view with a collection of beziers representing the ridges*/
- (id)initWithFrame:(CGRect)frame beziers:(NSArray*)beziers;

/** Forces all ridges to be visible */
- (void)showAllRidges;

/** To be called before changing tintColor if animating */
- (void)beginTintColorAnimation;

/** To be called after changing tintColor if animating */
- (void)endTintColorAnimation:(void (^)(void))completionBlock;

@end
