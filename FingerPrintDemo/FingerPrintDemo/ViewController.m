//
//  ViewController.m
//  FingerPrintDemo
//
//  Created by David Fumberger on 7/10/2014.
//  Copyright (c) 2014 Collect3 Pty Ltd. All rights reserved.
//

#import "ViewController.h"
#import "CTFingerPrintAnimatedView.h"

@interface TouchIDView : UIView
@property (nonatomic, strong) CTFingerPrintAnimatedView *animatedView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGesture;
@end

@implementation TouchIDView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        // The animated finger
        float w = 200;
        self.animatedView = [[CTFingerPrintAnimatedView alloc] initWithFrame: CGRectMake(0, 0, w, w)];
        [self addSubview: self.animatedView];
        
        // Gesture for changing animation modes
        self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(changeAnimation:)];
        self.swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:self.swipeGesture];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.animatedView highlightWithColor:[UIColor greenColor] animated: YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.animatedView revertHighlightColorAnimated: YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    [self.animatedView revertHighlightColorAnimated: YES];
}

- (void)changeAnimation:(UISwipeGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CTFingerPrintAnimationMode lastMode = self.animatedView.animationMode;
        [self.animatedView stopAnimation];
        [self.animatedView showAllVisible:NO animated:NO duration:0.0f];
        if (lastMode == CTFingerPrintAnimationModeRandom) {
            [self.animatedView startAnimation: CTFingerPrintAnimationModeCycleUpDown];
        } else {
            [self.animatedView startAnimation: CTFingerPrintAnimationModeRandom];
        }
    }
}

- (void)layoutSubviews {
    self.animatedView.center = self.center;
    [super layoutSubviews];
}

@end


@implementation ViewController

- (void)loadView {
    self.view = [[TouchIDView alloc] initWithFrame: [UIScreen mainScreen].bounds];
}

- (void)viewDidAppear:(BOOL)animated {
    TouchIDView *touchIDView = (TouchIDView*)self.view;
    [touchIDView.animatedView startAnimation: CTFingerPrintAnimationModeRandom];
}

@end
