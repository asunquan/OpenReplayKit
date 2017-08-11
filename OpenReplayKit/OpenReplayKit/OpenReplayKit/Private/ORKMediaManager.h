//
//  ORKMediaManager.h
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

typedef void(^ORKAppendScreensHandler)(NSError *error);
typedef void(^ORKEndAppendHandler)(NSError *error);
typedef void(^ORKCombinAudioVideoHandler)(void);

@interface ORKMediaManager : NSObject

+ (ORKMediaManager *)sharedManager;

- (void)appendScreens:(UIImage *)screen
            timeValue:(NSInteger)timeValue
              handler:(ORKAppendScreensHandler)handler;

- (void)endAppendHandler:(ORKEndAppendHandler)handler;

- (void)combineAudioAndVideo:(ORKCombinAudioVideoHandler)handler;

@end
