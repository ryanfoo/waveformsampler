//
//  WSamplerSecondViewController.h
//  WaveformSampler
//
//  Created by Ryan Foo on 7/1/13.
//  Copyright (c) 2013 New York University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface WSamplerSecondViewController : GLKViewController <GLKViewControllerDelegate>
// @interface WSamplerSecondViewController : UIViewController

// Declare statuses
@property (assign, nonatomic) BOOL playStatus;
@property (assign, nonatomic) BOOL clearStatus;
@property (assign, nonatomic) BOOL isMoving;

// Declare frame selections
@property (assign, nonatomic) SInt64 startFrame;
@property (assign, nonatomic) SInt64 endFrame;

@end
