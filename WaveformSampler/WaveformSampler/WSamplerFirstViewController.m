//
//  WSamplerFirstViewController.m
//  WaveformSampler
//
//  Created by Ryan Foo on 7/1/13.
//  Copyright (c) 2013 New York University. All rights reserved.
//

#import "WSamplerFirstViewController.h"
#import "WSamplerAppDelegate.h"
#import <AudiOS/AudioPlayer.h>
#import <AudiOS/AudioFileReader.h>

@interface WSamplerFirstViewController () 

// UIButtons
@property (weak, nonatomic) IBOutlet UIButton *sample1;
@property (weak, nonatomic) IBOutlet UIButton *sample2;
@property (weak, nonatomic) IBOutlet UIButton *sample3;
@property (weak, nonatomic) IBOutlet UIButton *sample4;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *statusItem;

// Images
@property (strong, nonatomic) UIImage *playImage;
@property (strong, nonatomic) UIImage *stopImage;
@property (strong, nonatomic) UIImage *editImage;

@end

@implementation WSamplerFirstViewController

#pragma mark - Audio Callback

// Audio Callback
void myAudioCallback(Float32 * buffer, UInt32 numFrames, void * userData) {
    
    // Declare Audio Data
    AudioData *audioData = (__bridge AudioData *)(userData);
    
    // Create Buffer
    Float32 *audioFileBuf = [audioData.afr readSamplesWithBufferSize:numFrames];
    
    // Store information
    memset(buffer, 0, sizeof(Float32) * numFrames * audioData.numChannels);

    // Declare index 
    int af_idx = 0;
    
    // Playback
    for (int i = 0; i < numFrames; i++) {
       
        // Store information into Graphics line
        audioData.line[2*i+1] = buffer[audioData.numChannels*i+1] + kYOffset;
        
        // Stereo
        buffer[audioData.numChannels*i] = 0.5 * audioFileBuf[af_idx++];
        if (audioData.afr.numChannels == 2) {
            buffer[audioData.numChannels*i+1] = 0.5 * audioFileBuf[af_idx++];
        }
    }
}

// No Audio Callback
void noAudioCallback(Float32 * buffer, UInt32 numFrames, void * userData) {
    
    // Do nothing
}

#pragma mark - Lazy Instantiation

// Green Button
- (UIImage*)playImage {
    
    if (!_playImage) {
        _playImage = [UIImage imageNamed: @"green-square-th.png"];
    }
    
    return _playImage;
}

// Red Button
- (UIImage*)stopImage {
    
    if (!_stopImage) {
        _stopImage = [UIImage imageNamed: @"red-square-button-th.png"];
    }
    
    return _stopImage;
}

// Blue Button
- (UIImage*)editImage {
    
    if (!_editImage) {
        _editImage = [UIImage imageNamed: @"blue-square-button-th.png"];
    }
    
    return _editImage;
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Call variables from WSamplerAppDelegate
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Set Background Color
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    // Default Statuses
    appDelegate.status = YES;
    appDelegate.editStatus1 = NO;
    appDelegate.editStatus2 = NO;
    appDelegate.editStatus3 = NO;
    appDelegate.editStatus4 = NO;
    appDelegate.usedEdit = NO;
    
    // Default Status Button Title
    [_statusItem setTitle: @"Go To Edit Mode"];
    
    // Default Button Image
    [_sample1 setImage: self.playImage forState:normal];
    [_sample2 setImage: self.playImage forState:normal];
    [_sample3 setImage: self.playImage forState:normal];
    [_sample4 setImage: self.playImage forState:normal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBActions

// Upper left UIButton in tab bar
- (IBAction)statusButtonPressed:(id)sender {
    
    // Call variables from WSamplerAppDelegate
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];

    // If edit mode has been selected...change title and status
    if (appDelegate.status == YES)
    {
        [self.statusItem setTitle: @"Go To Play Mode"];
        appDelegate.status = NO;
    }
    // If play mode has been selected...change title and status
    else
    {
        [self.statusItem setTitle: @"Go To Edit Mode"];
        appDelegate.status = YES;
    }
    
}

//Upper Left Button
- (IBAction)sampleButton01:(id)sender {

    // Call variables from WSamplerAppDelegate
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];

    // Load file for button
    [appDelegate.audioData.afr loadFileWithName:@"Kick.aif" andSampleRate:appDelegate.audioData.srate];
    
    // If in edit mode, select button to edit
    if (appDelegate.status == NO)
    {
        if (appDelegate.editStatus1 == NO)
        {
            if (appDelegate.usedEdit == NO)
            {
                // Change image
                [self.sample1 setImage: self.editImage forState:normal];
                appDelegate.editStatus1 = YES;
                appDelegate.usedEdit = YES;
            }
        }
        // Change image back to play image if no editing
        else
        {
            [self.sample1 setImage: self.playImage forState:normal];
            appDelegate.editStatus1 = NO;
            appDelegate.usedEdit = NO;
        }
    }
    // If in play mode, select button to play
    else
    {
        [self.sample1 setImage: self.playImage forState:normal];
        appDelegate.editStatus1 = NO;
        appDelegate.usedEdit = NO;
        
        // Playback audio
        [appDelegate.audioPlayer startWithCallback:myAudioCallback andUserData: (__bridge void *)(appDelegate.audioData)];
    }
    
}

- (IBAction)sampleButton02:(id)sender {

    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.audioData.afr loadFileWithName:@"Snare.aif" andSampleRate:appDelegate.audioData.srate];
    
    if (appDelegate.status == NO)
    {
        if (appDelegate.editStatus2 == NO)
        {
            if (appDelegate.usedEdit == NO)
            {
                [self.sample2 setImage: self.editImage forState:normal];
                appDelegate.editStatus2 = YES;
                appDelegate.usedEdit = YES;
            }
        }
        else
        {
            [self.sample2 setImage: self.playImage forState:normal];
            appDelegate.editStatus2 = NO;
            appDelegate.usedEdit = NO;
        }
    }
    else
    {
        [self.sample2 setImage: self.playImage forState:normal];
        appDelegate.editStatus2 = NO;
        appDelegate.usedEdit = NO;
        
        [appDelegate.audioPlayer startWithCallback:myAudioCallback andUserData: (__bridge void *)(appDelegate.audioData)];
    }
}

- (IBAction)sampleButton03:(id)sender {

    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.audioData.afr loadFileWithName:@"08 College.mp3" andSampleRate:appDelegate.audioData.srate];
    
    if (appDelegate.status == NO)
    {
        if (appDelegate.editStatus3 == NO)
        {
            if (appDelegate.usedEdit == NO)
            {
                [self.sample3 setImage: self.editImage forState:normal];
                appDelegate.editStatus3 = YES;
                appDelegate.usedEdit = YES;
            }
        }
        else
        {
            [self.sample3 setImage: self.playImage forState:normal];
            appDelegate.editStatus3 = NO;
            appDelegate.usedEdit = NO;
        }
    }
    else
    {
        [self.sample3 setImage: self.playImage forState:normal];
        appDelegate.editStatus3 = NO;
        appDelegate.usedEdit = NO;

        [appDelegate.audioPlayer startWithCallback:myAudioCallback andUserData: (__bridge void *)(appDelegate.audioData)];
    }
}

- (IBAction)sampleButton04:(id)sender {

    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDelegate.audioData.afr loadFileWithName:@"03 Fertilizer.mp3" andSampleRate:appDelegate.audioData.srate];

    if (appDelegate.status == NO)
    {
        if (appDelegate.editStatus4 == NO)
        {
            if (appDelegate.usedEdit == NO)
            {
                [self.sample4 setImage: self.editImage forState:normal];
                appDelegate.editStatus4 = YES;
                appDelegate.usedEdit = YES;
            }
        }
        else
        {
            [self.sample4 setImage: self.playImage forState:normal];
            appDelegate.editStatus4 = NO;
            appDelegate.usedEdit = NO;
        }
    }
    else
    {
        [self.sample4 setImage: self.playImage forState:normal];
        appDelegate.editStatus4 = NO;
        appDelegate.usedEdit = NO;

        [appDelegate.audioPlayer startWithCallback:myAudioCallback andUserData: (__bridge void *)(appDelegate.audioData)];

    }
}

@end
