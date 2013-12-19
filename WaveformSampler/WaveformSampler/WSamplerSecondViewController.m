//
//  WSamplerSecondViewController.m
//  WaveformSampler
//
//  Created by Ryan Foo on 7/1/13.
//  Copyright (c) 2013 New York University. All rights reserved.
//

#import "WSamplerSecondViewController.h"
#import "WSamplerAppDelegate.h"
#import <AudiOS/AudioPlayer.h>

@interface WSamplerSecondViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sampleButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *clearButton;
@property (weak, nonatomic) IBOutlet GLKView *view;
@property (weak, nonatomic) IBOutlet UITextField *startFrameButton;
@property (weak, nonatomic) IBOutlet UITextField *endFrameButton;

@end

@implementation WSamplerSecondViewController

#pragma mark - Audio Callback

// Audio Callback
void myAudioCallback2(Float32 * buffer, UInt32 numFrames, void * userData) {
    
    AudioData *audioData = (__bridge AudioData *)(userData);
    
    Float32 *audioFileBuf = [audioData.afr readSamplesWithBufferSize:numFrames];
    
    memset(buffer, 0, sizeof(Float32) * numFrames * audioData.numChannels);
    
    int af_idx = 0;
    
    for (int i = 0; i < numFrames; i++) {
            
        buffer[audioData.numChannels*i] = 0.5 * audioFileBuf[af_idx++];
        if (audioData.afr.numChannels == 2) {
            buffer[audioData.numChannels*i+1] = 0.5 * audioFileBuf[af_idx++];
        }
    }
}

// No Audio Callback
void noAudioCallback2(Float32 * buffer, UInt32 numFrames, void * userData) {
    
}

#pragma mark - Lazy Instantiation

- (void)setupGraphics
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    //GLKView *view = (GLKView *)self.view;
    self.view.context = self.context;
    self.view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    self.delegate = self;
    
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    // Let's color the line
    self.effect.useConstantColor = GL_TRUE;
    
    // Make the line a cyan color
    self.effect.constantColor = GLKVector4Make(
                                               1.0f, // Red
                                               1.0f, // Green
                                               1.0f, // Blue
                                               1.0f);// Alpha
}

#pragma mark - Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];

    // If edit mode has not been selected
    if (appDelegate.status == YES)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle: @"WARNING"
                                   message: @"Please switch to Edit Mode."
                                  delegate: self
                         cancelButtonTitle: @"OK"
                         otherButtonTitles: nil];
        [alertView show];
        
        // go back to first view
    }
    // If no buttons selected in edit mode
    else
    {
        if (appDelegate.editStatus1 == NO &&
            appDelegate.editStatus2 == NO &&
            appDelegate.editStatus3 == NO &&
            appDelegate.editStatus4 == NO)
        {
            UIAlertView *alertView =
            [[UIAlertView alloc] initWithTitle: @"WARNING"
                                       message: @"Please select a sample to edit."
                                      delegate: self
                             cancelButtonTitle: @"OK"
                             otherButtonTitles: nil];
            [alertView show];
        }
        // go back to first view
    }
    
    // Set Background Color
    self.view.backgroundColor = [UIColor darkGrayColor];
    
    // Default Statuses
    _playStatus = NO;
    _clearStatus = YES;
    _isMoving = NO;
    
    // Default Button Title
    [self.sampleButton setTitle:@"Play"];

    // Setup Open GL
    [self setupGraphics];
    
    _startFrameButton.delegate = self;
    _endFrameButton.delegate = self;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self loadSample];

    int bufferSize = 2048;
    Float32 *audioFileBuf;
    UInt16 fileSize = 0;
    while (!appDelegate.audioData.afr.isFinished) {
        
        audioFileBuf = [appDelegate.audioData.afr readSamplesWithBufferSize: bufferSize];
    
        fileSize += bufferSize;
    }
    
    [self loadSample];
    
    int i = 0;
    int newSize = (fileSize/bufferSize) + bufferSize;
    while (!appDelegate.audioData.afr.isFinished) {
        
        audioFileBuf = [appDelegate.audioData.afr readSamplesWithBufferSize:newSize];

        appDelegate.audioData.line[2*i+1] = audioFileBuf[0] + kYOffset;
        
        i++;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GLKViewControllerDelegate

- (void)glkViewControllerUpdate:(GLKViewController *)controller {
    
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 1.0f, -3.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, 0, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, 0, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // Set Background color
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Prepare the effect for rendering
    [self.effect prepareToDraw];
    
    // Create an handle for a buffer object array
    GLuint bufferObjectNameArray;
    
    // Have OpenGL generate a buffer name and store it in the buffer object array
    glGenBuffers(1, &bufferObjectNameArray);
    
    // Bind the buffer object array to the GL_ARRAY_BUFFER target buffer
    glBindBuffer(GL_ARRAY_BUFFER, bufferObjectNameArray);
    
    // Send the line data over to the target buffer in GPU RAM
    glBufferData(
                 GL_ARRAY_BUFFER,   // the target buffer
                 kFrameSize*sizeof(GLfloat)*2,      // the number of bytes to put into the buffer
                 appDelegate.audioData.line,              // a pointer to the data being copied
                 GL_STATIC_DRAW);   // the usage pattern of the data
    
    // Enable vertex data to be fed down the graphics pipeline to be drawn
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    // Specify how the GPU looks up the data
    glVertexAttribPointer(
                          GLKVertexAttribPosition, // the currently bound buffer holds the data
                          2,                       // number of coordinates per vertex
                          GL_FLOAT,                // the data type of each component
                          GL_FALSE,                // can the data be scaled
                          2*4,                     // how many bytes per vertex (2 floats per vertex)
                          NULL);                   // offset to the first coordinate, in this case 0
    
    glDrawArrays(GL_LINE_STRIP, 0, kFrameSize); // render
}

// Loads sample
- (void)loadSample {
    
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Calls information to see which button has been selected for editing. Looks at status to correspond with audio file
    if (appDelegate.editStatus1 == YES)
    {
        [appDelegate.audioData.afr loadFileWithName:@"Kick.aif" andSampleRate:appDelegate.audioData.srate];
    }
    
    if (appDelegate.editStatus2 == YES)
    {
        [appDelegate.audioData.afr loadFileWithName:@"Snare.aif" andSampleRate:appDelegate.audioData.srate];
    }
    
    if (appDelegate.editStatus3 == YES)
    {
        [appDelegate.audioData.afr loadFileWithName:@"08 College.mp3" andSampleRate:appDelegate.audioData.srate];
    }
    
    if (appDelegate.editStatus4 == YES)
    {
        [appDelegate.audioData.afr loadFileWithName:@"03 Fertilizer.mp3" andSampleRate:appDelegate.audioData.srate];
    }
}

// Clears sample
- (void) clearSample {
    
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];

    [appDelegate.audioData.afr loadFileWithName:NULL andSampleRate:0];
}

#pragma mark - IBActions
- (IBAction)sampleButtonPressed:(id)sender {
    
    // Call variables from WSampleAppDelegate
    WSamplerAppDelegate *appDelegate = (WSamplerAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // If play button has not been selected
    if (self.playStatus == NO)
    {
        // Change titles
        [self.sampleButton setTitle:@"Stop"];
        //        self.playStatus = YES;
        
        [self loadSample];
        
        // Clear Button clears selection
        if (self.clearStatus == YES)
        {
            // play entire track
            self.clearStatus = NO;
        }
        // Play from start frame to end frame
        else
        {
            [appDelegate.audioPlayer startWithCallback:myAudioCallback2 andUserData: (__bridge void *)(appDelegate.audioData)];
        }
        
        self.playStatus = YES;
    }
    else
    {
        [self.sampleButton setTitle:@"Play"];
        self.playStatus = NO;
        
        [appDelegate.audioData.afr loadFileWithName:NULL andSampleRate:0];
        [appDelegate.audioPlayer startWithCallback:noAudioCallback2 andUserData: (__bridge void *)(appDelegate.audioData)];
    }
}

- (IBAction)clearButtonPressed:(id)sender {
    
    self.startFrame = 0;
    self.startFrameButton.text = @"Start Frame";
    self.endFrame = 0;
    self.endFrameButton.text = @"End Frame";
}

- (IBAction)startFrame:(id)sender {
    
    NSString *startText = self.startFrameButton.text;
    self.startFrame = [startText intValue];
    [self.startFrameButton resignFirstResponder];
}

- (IBAction)endFrame:(id)sender {
    NSString *endText = self.endFrameButton.text;
    self.endFrame = [endText intValue];
    [self.endFrameButton resignFirstResponder];
}

- (IBAction)panHandler:(UIPanGestureRecognizer *)sender {
 
    // Finds location
    CGPoint loc = [sender locationInView:self.view];

    NSLog(@"x: %f, y: %f", loc.x,loc.y);

    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if ([self.view pointInside:[self.view convertPoint:loc toView: self.view] withEvent:nil])
        {
            self.isMoving = YES;
            self.startFrame = loc.x;
            
            NSLog(@"x: %f, y: %f", loc.x,loc.y);

            // start point
        }
        //if ([self.marshyImage pointInside: [self.view convertPoint:loc toView: self.marshyImage] withEvent:nil]) {
    }
 
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        if (self.isMoving == YES)
        {
            self.view.center = loc;
        }
    }
     
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        self.isMoving = NO;
        self.endFrame = loc.x;
        
    }
    
}

@end
