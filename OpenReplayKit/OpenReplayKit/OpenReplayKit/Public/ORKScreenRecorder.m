//
//  ORKScreenRecorder.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ORKScreenRecorder.h"

#import "ORKMediaPath.h"
#import "ORKVideoRecorder.h"
#import "ORKAudioRecorder.h"
#import "ORKMediaManager.h"
#import "ORKPreviewViewController.h"

@implementation ORKScreenRecorder

static ORKScreenRecorder *recorder = nil;

+ (ORKScreenRecorder *)sharedRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        recorder = [[[self class] alloc] init];
    });
    
    return recorder;
}

- (void)startRecordingWithHandler:(void (^)(NSError *))handler
{
    self.recording = YES;
    self.microphoneEnabled = YES;
    
    [ORKMediaPath removeMainSavePath];
    
    [ORKAudioRecorder.sharedRecorder startRecording];

    [ORKVideoRecorder.sharedRecorder startRecordingWithHandler:^(NSError *error)
    {
        if (handler)
            handler(error);
            
        self.recording = NO;
    }];
}

- (void)startRecordingWithMicrophoneEnabled:(BOOL)microphoneEnabled
                                    handler:(void (^)(NSError *))handler
{
    self.microphoneEnabled = microphoneEnabled;
    self.recording = YES;
    
    [ORKMediaPath removeMainSavePath];
    
    [ORKVideoRecorder.sharedRecorder startRecordingWithHandler:^(NSError *error)
     {
         if (handler)
             handler(error);
         
         self.recording = NO;
     }];
    
    if (self.microphoneEnabled)
    {
        [ORKAudioRecorder.sharedRecorder startRecording];
    }
}

- (void)stopRecordingWithHandler:(void (^)(ORKPreviewViewController *, NSError *))handler
{
    [ORKAudioRecorder.sharedRecorder stopRecording];
    
    [ORKVideoRecorder.sharedRecorder stopRecordingWithHandler:^(NSError *error)
    {
        if (error)
        {
            if (handler)
                handler(nil, error);
        }
        else
        {
            // 合成视频
            [ORKMediaManager.sharedManager combineAudioAndVideo:^
            {
                
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    ORKPreviewViewController *previewVC = [[ORKPreviewViewController alloc] init];
                    
                    if (handler)
                        handler(previewVC, nil);
                });
            }];
        }
        
        self.recording = NO;
    }];
}

- (void)setRecording:(BOOL)recording
{
    _recording = recording;
}

@end
