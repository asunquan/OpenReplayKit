//
//  ORKMediaManager.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ORKMediaManager.h"

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "ORKMediaPath.h"
#import "ORKMediaError.h"

#define ORKFRAMERATE            (30.f)
#define ORKSCREENWIDTH          (UIScreen.mainScreen.bounds.size.width * 2)
#define ORKSCREENHEIGHT         (UIScreen.mainScreen.bounds.size.height * 2)

@interface ORKMediaManager ()

@property (nonatomic, copy) ORKAppendScreensHandler appendScreensHandler;

@property (nonatomic, strong) NSString *screenVideoSavePath;

@property (nonatomic, strong) AVAssetWriter *assetWriter;

@property (nonatomic, strong) AVAssetWriterInput *assetWriterInput;

@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterInputAdaptor;

@end

@implementation ORKMediaManager

#pragma mark - 单例

static ORKMediaManager *manager = nil;

+ (ORKMediaManager *)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        manager = [[[self class] alloc] init];
    });
    
    return manager;
}

#pragma mark - 图片合成视频

- (void)appendScreens:(UIImage *)screen
            timeValue:(NSInteger)timeValue
              handler:(ORKAppendScreensHandler)handler
{
    self.appendScreensHandler = handler;
    
    CMTime presentationTime = CMTimeMake(timeValue, ORKFRAMERATE);
 
    [self assetWriter];
    
    [self assetWriterInput];
    
    [self assetWriterInputAdaptor];
    
    if (self.assetWriterInput.isReadyForMoreMediaData)
    {
        CVPixelBufferRef pixelBuffer = [self pixelBufferFromImage:screen];
        
        if(![self.assetWriterInputAdaptor appendPixelBuffer:pixelBuffer withPresentationTime:presentationTime])
        {
            NSLog(@"Adaptor append pixelBuffer failed : %ld", (long)timeValue);
            
            if (self.assetWriter.error && handler)
                handler(self.assetWriter.error);
        }
        
        CVPixelBufferRelease(pixelBuffer);
    }
    else if (handler)
    {
        handler(ORKMediaError.inputMoreDataError);
    }
}

- (void)endAppendHandler:(ORKEndAppendHandler)handler
{
    [self.assetWriterInput markAsFinished];
    
    [self.assetWriter finishWritingWithCompletionHandler:^
     {
         if (handler)
             handler(nil);
         
         self.assetWriterInputAdaptor = nil;
         self.assetWriterInput = nil;
         self.assetWriter = nil;
         self.screenVideoSavePath = nil;
     }];
}

- (NSString *)screenVideoSavePath
{
    if (!_screenVideoSavePath)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmssSSS";
        NSString *time = [formatter stringFromDate:NSDate.date];
        
        NSString *videoName = [NSString stringWithFormat:@"%@.M4V", time];
        _screenVideoSavePath = [ORKMediaPath.screenVideoSavePath stringByAppendingPathComponent:videoName];
    }
    
    return _screenVideoSavePath;
}

- (AVAssetWriter *)assetWriter
{
    if (!_assetWriter)
    {
        NSError *error;
        
        NSURL *assetURL = [NSURL fileURLWithPath:self.screenVideoSavePath];
        
        // replayKit使用AVFileTypeAppleM4V
        _assetWriter = [AVAssetWriter assetWriterWithURL:assetURL fileType:AVFileTypeAppleM4V error:&error];
        
        if (error && self.appendScreensHandler)
            self.appendScreensHandler(error);
    }
    
    return _assetWriter;
}

- (AVAssetWriterInput *)assetWriterInput
{
    if (!_assetWriterInput)
    {
        NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecH264,
                                         AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill,
                                         AVVideoWidthKey : @(ORKSCREENWIDTH),
                                         AVVideoHeightKey : @(ORKSCREENHEIGHT)};
        
        _assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
        
        _assetWriterInput.expectsMediaDataInRealTime = YES;
    }
    
    return _assetWriterInput;
}

- (AVAssetWriterInputPixelBufferAdaptor *)assetWriterInputAdaptor
{
    if (!_assetWriterInputAdaptor)
    {
        NSString *pixelBufferPixelFormatTypeKey = (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey;
        NSNumber *pixelBufferPixelFormatType = [NSNumber numberWithInt:kCVPixelFormatType_32ARGB];
        NSDictionary *sourcePixelBufferAttributes = @{pixelBufferPixelFormatTypeKey : pixelBufferPixelFormatType};
        
        // AVAssetWriterInputPixelBufferAdaptor提供CVPixelBufferPool实例, 可以使用分配像素缓冲区写入输出文件, 使用提供的像素为缓冲池分配通常是更有效的比添加像素缓冲区分配使用一个单独的池
        _assetWriterInputAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.assetWriterInput sourcePixelBufferAttributes:sourcePixelBufferAttributes];
        
        if (![self.assetWriter canAddInput:self.assetWriterInput])
        {
            if (self.appendScreensHandler)
                self.appendScreensHandler(ORKMediaError.addInputError);
        }
        else
        {
            [self.assetWriter addInput:self.assetWriterInput];
            [self.assetWriter startWriting];
            [self.assetWriter startSessionAtSourceTime:kCMTimeZero];
        }
    }
    
    return _assetWriterInputAdaptor;
}

- (CVPixelBufferRef)pixelBuffer
{
    NSString *pixelBufferCGImageCompatibilityKey = (__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey;
    NSString *pixelBufferCGBitmapContextCompatibilityKey = (__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey;
    NSDictionary *pixelBufferAttributes = @{pixelBufferCGImageCompatibilityKey : [NSNumber numberWithBool:YES],
                                            pixelBufferCGBitmapContextCompatibilityKey : [NSNumber numberWithBool:YES]};
    
    CVPixelBufferRef pixelBuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          ORKSCREENWIDTH,
                                          ORKSCREENHEIGHT,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef)pixelBufferAttributes,
                                          &pixelBuffer);
    
    if (status != kCVReturnSuccess || pixelBuffer == NULL)
    {
        if (self.appendScreensHandler)
            self.appendScreensHandler(ORKMediaError.pixelBufferError);
    }
    
    return pixelBuffer;
}

- (CGContextRef)context:(CVPixelBufferRef)pixelBuffer colorSpace:(CGColorSpaceRef)colorSpace
{
    void *pixelData = CVPixelBufferGetBaseAddress(pixelBuffer);
    
    // 当你调用这个函数的时候, Quartz创建一个位图绘制环境, 也就是位图上下文, 当你向上下文中绘制信息时, Quartz把你要绘制的信息作为位图数据绘制到指定的内存块, 一个新的位图上下文的像素格式由三个参数决定: 每个组件的位数, 颜色空间, alpha选项
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 ORKSCREENWIDTH,
                                                 ORKSCREENHEIGHT,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pixelBuffer),
                                                 colorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    // 使用CGContextDrawImage绘制图片, 这里设置不正确的话会导致视频颠倒
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    return context;
}

- (CVPixelBufferRef)pixelBufferFromImage:(UIImage *)image
{
    CVPixelBufferRef pixelBuffer = self.pixelBuffer;
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = [self context:pixelBuffer colorSpace:colorSpace];
    
    // 当通过CGContextDrawImage绘制图片到一个context中时, 如果传入的是UIImage的CGImageRef, 因为UIKit和CG坐标系y轴相反, 所以图片绘制将会上下颠倒
    CGContextDrawImage(context, CGRectMake(0, 0, ORKSCREENWIDTH, ORKSCREENHEIGHT), image.CGImage);
    
    // 释放色彩空间
    CGColorSpaceRelease(colorSpace);
    
    // 释放context
    CGContextRelease(context);
    
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}

#pragma mark - 音视频合成

- (NSString *)mixedVideoFilePath
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    NSString *time = [formatter stringFromDate:NSDate.date];
    
    NSString *videoName = [NSString stringWithFormat:@"%@.M4V", time];
    
    return [ORKMediaPath.mixedVideoSavePath stringByAppendingPathComponent:videoName];
}

- (NSString *)screenVideoFilePath
{
    NSDirectoryEnumerator *enumerator = [NSFileManager.defaultManager enumeratorAtPath:ORKMediaPath.screenVideoSavePath];
    
    NSString *name = enumerator.allObjects.firstObject;
    
    NSString *path = [ORKMediaPath.screenVideoSavePath stringByAppendingPathComponent:name];
   
    return path;
}

- (NSString *)microphoneAudioFilePath
{
    NSDirectoryEnumerator *enumerator = [NSFileManager.defaultManager enumeratorAtPath:ORKMediaPath.microphoneAudioSavePath];
    
    NSString *name = enumerator.allObjects.firstObject;
    
    NSString *path = [ORKMediaPath.microphoneAudioSavePath stringByAppendingPathComponent:name];
    
    return path;
}

- (void)combineAudioAndVideo:(ORKCombinAudioVideoHandler)handler
{
    // 创建音频保存路径
    if (![ORKMediaPath createFolderIfNotExist:ORKMediaPath.mixedVideoSavePath])
    {
        return;
    }
    
    AVMutableComposition *composition = [AVMutableComposition composition];
    
    
    NSURL *videoURL = [NSURL fileURLWithPath:self.screenVideoFilePath];
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    AVMutableCompositionTrack *videoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *videoAssetTrack = [videoAsset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    
    NSURL *audioURL = [NSURL fileURLWithPath:self.microphoneAudioFilePath];
    
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:audioURL options:nil];
    
    CMTimeRange audioTimeRange = CMTimeRangeMake(kCMTimeZero, audioAsset.duration);
    
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVAssetTrack *audioAssetTrack = [audioAsset tracksWithMediaType:AVMediaTypeAudio].firstObject;
    
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    
    NSURL *outputURL = [NSURL fileURLWithPath:self.mixedVideoFilePath];
    
    AVAssetExportSession *assetExport = [AVAssetExportSession exportSessionWithAsset:composition presetName:AVAssetExportPresetHighestQuality];
    
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    assetExport.outputURL = outputURL;
    assetExport.shouldOptimizeForNetworkUse = YES;
    
    [assetExport exportAsynchronouslyWithCompletionHandler:handler];
}

@end
