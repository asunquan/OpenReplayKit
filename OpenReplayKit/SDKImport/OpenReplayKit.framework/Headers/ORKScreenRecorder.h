//
//  ORKScreenRecorder.h
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ORKPreviewViewController;

@interface ORKScreenRecorder : NSObject

/**
 是否正在录屏
 */
@property (nonatomic, readonly, getter = isRecording) BOOL recording;

/**
 是否使用麦克风录音
 */
@property (nonatomic, getter = isMicrophoneEnabled) BOOL microphoneEnabled;

/**
 生成单例对象

 @return 单例对象
 */
+ (ORKScreenRecorder *)sharedRecorder;

/**
 开始录屏

 @param microphoneEnabled 是否开启麦克风录音
 @param handler 录屏进行中发生错误回调
 */
- (void)startRecordingWithMicrophoneEnabled:(BOOL)microphoneEnabled handler:(void(^)(NSError *error))handler;

/**
 开始录屏(同时开启录音)

 @param handler 录屏进行中发生错误回调
 */
- (void)startRecordingWithHandler:(void(^)(NSError *error))handler;

/**
 结束录屏

 @param handler 录屏结束回调是否有产生错误, 无错误回调预览视图控制器
 */
- (void)stopRecordingWithHandler:(void(^)(ORKPreviewViewController *previewViewController, NSError *error))handler;


@end
