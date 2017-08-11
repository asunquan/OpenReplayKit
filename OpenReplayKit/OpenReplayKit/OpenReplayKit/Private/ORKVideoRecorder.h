//
//  ORKVideoRecorder.h
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ORKVideoRecorderStartHandler)(NSError *error);

typedef void(^ORKVideoRecorderStopHandler)(NSError *error);

@interface ORKVideoRecorder : NSObject

+ (ORKVideoRecorder *)sharedRecorder;

- (void)startRecordingWithHandler:(ORKVideoRecorderStartHandler)handler;

- (void)stopRecordingWithHandler:(ORKVideoRecorderStopHandler)handler;

@end
