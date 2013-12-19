//
//  WSamplerAppDelegate.m
//  WaveformSampler
//
//  Created by Ryan Foo on 7/1/13.
//  Copyright (c) 2013 New York University. All rights reserved.
//

#import "WSamplerAppDelegate.h"

@implementation WSamplerAppDelegate

#pragma mark - View Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Lazy Instantiation

- (AudioPlayer*)audioPlayer {
    
    
    if (!_audioPlayer) {
        _audioPlayer = [[AudioPlayer alloc] initWithSampleRate:self.audioData.srate
                                                     frameSize:self.audioData.bufferSize
                                                andNumChannels:self.audioData.numChannels];
    }
    return _audioPlayer;
}


- (AudioData*)audioData {
    
    if (!_audioData) {
        _audioData = [[AudioData alloc] init];
        _audioData.srate = 44100;
        _audioData.numChannels = 2;
        _audioData.bufferSize = kFrameSize;
        _audioData.afr = [[AudioFileReader alloc] init];
        _audioData.line = (GLfloat*)malloc(kFrameSize*sizeof(GLfloat)*2);
        for (int i = 0; i < kFrameSize; i++) {
            _audioData.line[2*i] = ((i - kFrameSize) / (GLfloat)kFrameSize + 0.5f) * 1.5f;      //even is x
            _audioData.line[2*i + 1] = kYOffset;                                                //odd is y
        }
        
    }
    return _audioData;
}

@end
