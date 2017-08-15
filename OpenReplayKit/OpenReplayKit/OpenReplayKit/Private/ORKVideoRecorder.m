//
//  ORKVideoRecorder.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ORKVideoRecorder.h"

#import <UIKit/UIKit.h>
#import "ORKScreenCapturer.h"
#import "ORKMediaPath.h"
#import "ORKMediaError.h"
#import "ORKMediaManager.h"

#define ORKFRAMERATE            (30.f)
#define ORKTHUMBNAILNAME        (@"thumbnail.png")

@interface ORKVideoRecorder ()

@property (nonatomic, copy) ORKVideoRecorderStartHandler startHandler;

@property (nonatomic, copy) ORKVideoRecorderStopHandler stopHandler;

@property (nonatomic, strong) NSTimer *videoTimer;

@property (nonatomic, assign) NSInteger screensCount;

@property (nonatomic, strong) NSThread *recordThread;

@end

@implementation ORKVideoRecorder

#pragma mark - 单例

static ORKVideoRecorder *recorder = nil;

+ (ORKVideoRecorder *)sharedRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        recorder = [[[self class] alloc] init];
    });
    
    return recorder;
}

#pragma mark - 开始录屏

- (void)startRecordingWithHandler:(ORKVideoRecorderStartHandler)handler
{
    self.startHandler = handler;
    
    // 创建截屏保存路径
    if (![ORKMediaPath createFolderIfNotExist:ORKMediaPath.thumbnailSavePath] || ![ORKMediaPath createFolderIfNotExist:ORKMediaPath.screenVideoSavePath])
    {
        // 创建路径失败
        if (handler)
            handler(ORKMediaError.folderError);
        
        return;
    }
    
    // 开始截屏
   [self startCaptureScreen];
}

- (void)startCaptureScreen
{
   dispatch_queue_t recordQueue = dispatch_queue_create("ORKScreenRecordQueue", 0);
   
   dispatch_async(recordQueue, ^
   {
      [self captureScreen];
      
      [NSRunLoop.currentRunLoop addPort:NSMachPort.port forMode:NSRunLoopCommonModes];
      
      self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:1 / ORKFRAMERATE
                                                         target:self
                                                       selector:@selector(captureScreen)
                                                       userInfo:nil
                                                        repeats:YES];
      
      [NSRunLoop.currentRunLoop run];
   });
}

- (void)captureScreen
{
   dispatch_async(dispatch_get_main_queue(), ^
   {
      self.screensCount++;
      
      NSLog(@"frame : %ld", (long)self.screensCount);
      
      UIImage *screen = ORKScreenCapturer.currentScreen;
      
      if (self.screensCount == 1)
      {
         [self saveImage:screen];
      }
      
      [ORKMediaManager.sharedManager appendScreens:screen
                                         timeValue:self.screensCount
                                           handler:self.startHandler];
   });
}

- (void)saveImage:(UIImage *)image
{
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *filePath = [ORKMediaPath.thumbnailSavePath stringByAppendingPathComponent:ORKTHUMBNAILNAME];
    
    [imageData writeToFile:filePath atomically:YES];
}

#pragma mark - 停止录屏

- (void)stopRecordingWithHandler:(ORKVideoRecorderStopHandler)handler
{
    self.stopHandler = handler;
    
    // 停止截屏
    [self stopCaptureScreen];
    
    // 创建截屏录像保存路径
    if (![ORKMediaPath createFolderIfNotExist:ORKMediaPath.screenVideoSavePath])
    {
        // 创建路径失败
        if (handler)
            handler(ORKMediaError.folderError);
        
        return;
    }
    
    [ORKMediaManager.sharedManager endAppendHandler:^(NSError *error)
    {
        if (handler)
            handler(error);
        
        self.screensCount = 0;
    }];
}

- (void)stopCaptureScreen
{
   [self.videoTimer invalidate];
   
   self.videoTimer = nil;
}

@end
