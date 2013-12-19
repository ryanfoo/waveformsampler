//
//  AudioData.h
//  AudioRead
//
//  Created by Ryan Foo on 6/28/13.
//  Copyright (c) 2013 New York University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudiOS/AudioFileReader.h>
#import <AudiOS/AudioFileWriter.h>

@interface AudioData : NSObject

@property (assign, nonatomic) Float32 srate;
@property (assign, nonatomic) UInt32 numChannels;
@property (assign, nonatomic) UInt32 bufferSize;
@property (strong, nonatomic) AudioFileReader *afr;
@property (assign, nonatomic) GLfloat *line;

@end
