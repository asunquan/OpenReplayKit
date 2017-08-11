//
//  ORKMediaPath.h
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORKMediaPath : NSObject

+ (NSString *)thumbnailSavePath;

+ (NSString *)screenVideoSavePath;

+ (NSString *)microphoneAudioSavePath;

+ (NSString *)mixedVideoSavePath;

+ (BOOL)createFolderIfNotExist:(NSString *)path;

+ (BOOL)removeMainSavePath;

@end
