//
//  ORKAudioRecorder.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ORKAudioRecorder.h"

#import <AVFoundation/AVFoundation.h>
#import "ORKMediaPath.h"

@interface ORKAudioRecorder ()

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@end

@implementation ORKAudioRecorder

#pragma mark - 单例

static ORKAudioRecorder *recorder = nil;

+ (ORKAudioRecorder *)sharedRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        recorder = [[[self class] alloc] init];
    });
    
    return recorder;
}

#pragma mark - 开始录音

- (void)configureAudioSession
{
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [AVAudioSession.sharedInstance setActive:YES error:nil];
}

- (NSString *)audioFilePath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *time = [formatter stringFromDate:NSDate.date];
    
    NSString *audioName = [NSString stringWithFormat:@"%@.wav", time];
    
    return [ORKMediaPath.microphoneAudioSavePath stringByAppendingPathComponent:audioName];
}

- (AVAudioRecorder *)audioRecorder
{
    if (!_audioRecorder)
    {
        [self configureAudioSession];
        
        NSURL *audioURL = [NSURL fileURLWithPath:self.audioFilePath];
        
        NSDictionary *settings = @{AVSampleRateKey : @8000.f,
                                   AVFormatIDKey : @(kAudioFormatLinearPCM),
                                   AVLinearPCMBitDepthKey : @16,
                                   AVNumberOfChannelsKey : @1};
        
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:audioURL settings:settings error:nil];
        
        _audioRecorder.meteringEnabled = YES;
    }
    
    return _audioRecorder;
}

- (void)startRecording
{
    // 创建音频保存路径
    if (![ORKMediaPath createFolderIfNotExist:ORKMediaPath.microphoneAudioSavePath])
    {
        return;
    }
    
    if (self.audioRecorder.prepareToRecord)
    {
        [self.audioRecorder record];
    }
}

#pragma mark - 结束录音

- (void)stopRecording
{
    [self.audioRecorder stop];
}

@end
