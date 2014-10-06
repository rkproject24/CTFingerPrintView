CTFingerPrintView
=================

Generates a unique animated finger print in the style of Apple's Touch ID logo

![Example GIF](https://raw.github.com/Collect3/CTFingerPrintView/images/TouchID.gif)


Usage
=====
Use CTFingerPrintAnimatedView in your project to show an animated finger print

```
    CTFingerPrintAnimatedView *fpv = [[CTFingerPrintAnimatedView alloc] initWithFrame: CGRectMake(0,0,200,200)];
    
    // Supports tint color
    fpv.tintColor = [UIColor orangeColor];
    
    // Start animating
    [fpv startAnimation: CTFingerPrintAnimationModeCycleUpDown];
```

Demo
=====
A demo project 'FingerPrintDemo' is included.
