//
//  CTFingerPrintView.m
//  CTFingerPrint
//
//  Created by David Fumberger on 8/09/2014.
//  Copyright (c) 2014 Collect3 Pty Ltd. All rights reserved.
//

#import "CTFingerPrintView.h"
#import "CTFingerPrintGenerator.h"

@interface CTFingerGradientView : UIView
@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;
@end

@implementation CTFingerGradientView
+ (Class)layerClass {
    return [CAGradientLayer class];
}

- (CAGradientLayer*)gradientLayer {
    return (CAGradientLayer*)self.layer;
}

- (void)setStartColor:(UIColor *)startColor endColor:(UIColor*)endColor animated:(BOOL)animated {
    UIColor *fromStartColor = _startColor;
    UIColor *fromEndColor   = _endColor;
    _startColor = [startColor copy];
    _endColor   = [endColor copy];
    if (animated) {
        CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"colors"];
        colorAnimation.fromValue = @[ (id)fromStartColor.CGColor,
                                      (id)fromEndColor.CGColor ];
        colorAnimation.toValue  =  @[ (id)self.startColor.CGColor,
                                      (id)self.endColor.CGColor ];
        colorAnimation.duration = 0.35;
        colorAnimation.removedOnCompletion = YES;
        [self.gradientLayer addAnimation:colorAnimation forKey:@"colorAnimation"];
    }
    [self updateColors];
}

- (void)animationDidStart:(CAAnimation *)anim {

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

}

- (void)updateColors {
    [self.gradientLayer setColors: [NSArray arrayWithObjects: (id)[self.startColor CGColor] , (id)[self.endColor CGColor], nil]];
}

- (void)setStartColor:(UIColor *)startColor {
    _startColor = startColor;
    [self updateColors];
}

- (void)setEndColor:(UIColor *)endColor {
    _endColor = endColor;
    [self updateColors];
}

@end

@interface FingerRidgePath()
@property (nonatomic, strong) CABasicAnimation *currentAnimation;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) id delegate;
@end

@protocol FingerRidgePathDelegate <NSObject>
- (void)visibleStateDidChangeForRidge:(FingerRidgePath*)ridge animated:(BOOL)animated duration:(float)duration;
@end


@implementation FingerRidgePath
- (void)animationDidStart:(CAAnimation *)anim {
    self.isAnimating = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (!flag) {
        //NSLog(@"did not finish");
    }
    self.isAnimating = NO;
}

- (void)setVisible:(BOOL)visible {
    [self setVisible:visible animated:NO];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated  {
    [self setVisible:visible animated:animated duration:1.5];
}

- (void)setVisible:(BOOL)visible animated:(BOOL)animated duration:(float)duration {
    _visible = visible;
    [self.delegate visibleStateDidChangeForRidge: self animated: animated duration: duration];
}
@end

@interface CTFingerPrintView() <FingerRidgePathDelegate>
@property (nonatomic, strong) CTFingerGradientView *gradientView;
@property (nonatomic, strong) CALayer *contentLayer;
@property (nonatomic, assign) BOOL animatingTintColor;
@end

@implementation CTFingerPrintView
- (id)initWithFrame:(CGRect)frame beziers:(NSArray*)beziers {
    if (self = [super initWithFrame: frame]) {
        self.clipsToBounds = NO;
        
        self.gradientView = [[CTFingerGradientView alloc] initWithFrame: self.bounds];
        self.gradientView.backgroundColor = [UIColor purpleColor];
        [self addSubview: self.gradientView];
        
        self.backgroundColor = [UIColor clearColor];
        self.lineWidth = 3.0;
        
        NSMutableArray *ridges = [[NSMutableArray alloc] init];
        for (UIBezierPath *path in beziers) {
            FingerRidgePath *ridge = [[FingerRidgePath alloc] init];
            ridge.bezierPath = path;
            ridge.visible = NO;
            ridge.delegate = self;
            [ridges addObject: ridge];
        }
        self.ridges = ridges;
        
        self.contentLayer = [[CALayer alloc] init];
        [self.layer addSublayer: self.contentLayer];
        
        self.gradientView.layer.mask = self.contentLayer;
        
        [self scaleBeziers: beziers];
        [self setupRidgeLayers];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    CTFingerPrintGenerator *generator = [[CTFingerPrintGenerator alloc] init];
    if (self = [self initWithFrame:frame beziers: [generator generateBezierPaths]]) {
        
    }
    return self;
}

- (void)setLineWidth:(float)lineWidth {
    _lineWidth = lineWidth;
    for (FingerRidgePath *ridge in self.ridges) {
        ridge.shapeLayer.lineWidth = self.lineWidth;
    }
}

- (void)setupRidgeLayers {
    for (FingerRidgePath *ridge in self.ridges) {
        CAShapeLayer *shape = [[CAShapeLayer alloc] init];
        UIBezierPath *bezier = ridge.bezierPath;
        shape.path = bezier.CGPath;
        shape.strokeStart = (ridge.visible) ? 0.0 : 1.0;
        shape.strokeEnd   = 1.0;
        shape.fillColor   = [UIColor clearColor].CGColor;
        shape.strokeColor = self.tintColor.CGColor;
        shape.lineWidth   = self.lineWidth;
        shape.lineCap     = kCALineCapRound;
        ridge.shapeLayer = shape;
        [self.contentLayer addSublayer: shape];
    }
}

- (void)showAllRidges {
    for (FingerRidgePath *ridge in self.ridges) {
        ridge.visible = YES;
    }
}

- (void)tintColorDidChange {
    
    CGFloat hue = 0;
    CGFloat sat = 0;
    CGFloat brightness = 0;
    CGFloat alpha = 0;
    
    [self.tintColor getHue:&hue
                saturation:&sat
                brightness:&brightness
                     alpha:&alpha];
    
    UIColor *startColor   = [UIColor colorWithHue:hue - 0.095
                                       saturation:sat * 2.0
                                       brightness:brightness * 2.0
                                            alpha:alpha];
    UIColor *endColor = self.tintColor;
    
    [self.gradientView setStartColor: startColor endColor: endColor animated: self.animatingTintColor];
}

- (void)visibleStateDidChangeForRidge:(FingerRidgePath*)ridge animated:(BOOL)animated duration:(float)duration {
    if (ridge.isAnimating) {
//        NSLog(@"Already animating");
    }

    CAShapeLayer *shape = ridge.shapeLayer;
    shape.strokeStart = (ridge.visible) ? 0.0 : 1.0;
    shape.strokeEnd   = 1.0;
    if (animated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:(ridge.visible) ? @"strokeEnd" : @"strokeStart"];
        pathAnimation.duration = duration; // 2 seconds
        pathAnimation.fromValue = [NSNumber numberWithFloat:0.0];
        pathAnimation.toValue   = [NSNumber numberWithFloat:1.0];
        pathAnimation.removedOnCompletion = YES;
        pathAnimation.delegate = ridge;
        [shape removeAllAnimations];
        [shape addAnimation:pathAnimation forKey:@"visibleStateAnimation"];
    }
}

- (void)beginTintColorAnimation {
    [CATransaction begin];
    self.animatingTintColor = YES;
}

- (void)endTintColorAnimation:(void (^)(void))completionBlock {
    [CATransaction setCompletionBlock: completionBlock];
    [CATransaction commit];
    self.animatingTintColor = NO;
}

- (void)scaleBeziers:(NSArray*)beziers {
    float maxX = 0;
    float maxY = 0;
    for (UIBezierPath *path in beziers) {
        float x = path.bounds.size.width  + path.bounds.origin.x;
        float y = path.bounds.size.height + path.bounds.origin.y;
        if (isinf(x) || isinf(y)) { continue; }
        maxX = ceilf((x > maxX) ? x : maxX);
        maxY = ceilf((y > maxY) ? y : maxY);
    }    
    float scaleX = self.bounds.size.width / (maxX + self.lineWidth);
    float scaleY = self.bounds.size.height / (maxY + self.lineWidth);
    float scale = MIN(scaleX, scaleY);
    
    CGAffineTransform t = CGAffineTransformMakeScale(scale, scale);
    for (UIBezierPath *path in beziers) {
        [path applyTransform: t];
    }
}
@end
