CTFingerPrintView
=================

Generates a unique animated finger print in the style of Apple's Touch ID logo. 

Used in our product Video Safe 2 - http://collect3.com.au/videosafe2 when authenticating via Touch ID.


![Example GIF](https://raw.github.com/Collect3/CTFingerPrintView/images/TouchID.gif)


* Each time the view is created the finger print is uniquely generated. 

* Supports two animation modes:
     * Random - Randomly fills / unfills the ridges
     * Cycle Up / Down - Progressively fills all ridges then unfills all ridges


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
