//
//  ORKAudioRecorder.h
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORKAudioRecorder : NSObject

+ (ORKAudioRecorder *)sharedRecorder;

- (void)startRecording;

- (void)stopRecording;

@end
