//
//  WSamplerAppDelegate.h
//  WaveformSampler
//
//  Created by Ryan Foo on 7/1/13.
//  Copyright (c) 2013 New York University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudiOS/AudioPlayer.h>
#import <AudiOS/AudioFileReader.h>
#import "AudioData.h"

// Define variables
#define kFrameSize      2048       
#define kYOffset        -1.f

@interface WSamplerAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// Audio Properties
@property (strong, nonatomic) AudioData *audioData;
@property (strong, nonatomic) AudioPlayer *audioPlayer;
@property (strong, nonatomic) AudioPlayer *audioPlayer01;
@property (strong, nonatomic) AudioPlayer *audioPlayer02;
@property (strong, nonatomic) AudioPlayer *audioPlayer03;
@property (strong, nonatomic) AudioPlayer *audioPlayer04;

// Play or Edit Mode
@property (assign, nonatomic) BOOL status;

// Edit status for each button
@property (assign, nonatomic) BOOL editStatus1;
@property (assign, nonatomic) BOOL editStatus2;
@property (assign, nonatomic) BOOL editStatus3;
@property (assign, nonatomic) BOOL editStatus4;

// If one button is being edited, don't allow other buttons to be edited
@property (assign, nonatomic) BOOL usedEdit;

@end


