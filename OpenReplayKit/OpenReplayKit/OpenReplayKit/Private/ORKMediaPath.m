//
//  ORKMediaPath.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ORKMediaPath.h"

#define ORKMAINSAVEPATH                 (@"ORKRecorder")

#define ORKTHUMBNAILSAVEPATH            (@"ORKThumbnail")

#define ORKSCREENVIDEOSAVEPATH          (@"ORKScreenVideo")

#define ORKMICROPHONEAUDIOSAVEPATH      (@"ORKMicrophoneAudio")

#define ORKMIXEDVIDEOSAVEPATH           (@"ORKMixedVideo")

@implementation ORKMediaPath

+ (NSString *)documentPath
{
    NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    return paths.firstObject;
}

+ (NSString *)mainSavePath
{
    NSString *mainPath = [self.documentPath stringByAppendingPathComponent:ORKMAINSAVEPATH];
    
    return mainPath;
}

+ (NSString *)thumbnailSavePath
{
    NSString *thumbnailPath = [self.mainSavePath stringByAppendingPathComponent:ORKTHUMBNAILSAVEPATH];
    
    return thumbnailPath;
}

+ (NSString *)screenVideoSavePath
{
    NSString *screenVideoPath = [self.mainSavePath stringByAppendingPathComponent:ORKSCREENVIDEOSAVEPATH];
    
    return screenVideoPath;
}

+ (NSString *)microphoneAudioSavePath
{
    NSString *microphoneAudioPath = [self.mainSavePath stringByAppendingPathComponent:ORKMICROPHONEAUDIOSAVEPATH];
    
    return microphoneAudioPath;
}

+ (NSString *)mixedVideoSavePath
{
    NSString *mixedVideoPath = [self.mainSavePath stringByAppendingPathComponent:ORKMIXEDVIDEOSAVEPATH];
    
    return mixedVideoPath;
}

+ (BOOL)createFolderIfNotExist:(NSString *)path
{
    if (![NSFileManager.defaultManager fileExistsAtPath:path])
    {
        return [NSFileManager.defaultManager createDirectoryAtPath:path
                                       withIntermediateDirectories:YES
                                                        attributes:nil
                                                             error:nil];
    }
    
    return YES;
}

+ (BOOL)removeMainSavePath
{
    return [NSFileManager.defaultManager removeItemAtPath:self.mainSavePath error:nil];
}

@end
