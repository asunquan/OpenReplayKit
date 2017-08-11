# OpenReplayKit
OpenReplayKit是一个仿照Apple的ReplayKit的一个录屏插件, 向下拓展支持iOS 7.0及以上版本.

## 原理##

开始录屏, 以每秒30帧的速度截取当前屏幕内容帧, 保存第一帧作为预览视图控制器的预览图, 使用AVFoundation中的方法将每一帧屏幕内容拼接为M4V格式的视频, 在开始的同时, 根据是否使用麦克风判断是否需要录制音频, 在结束录屏时, 将拼接好的屏幕视频和录制的音频进行合成, 合成完成后回调一个预览视图控制器, 在预览视图控制器中可以将该视频保存到本地或通过系统控件进行分享或观看录制的视频.

## 使用##

* 使用时需要在工程中导入录屏SDKframework:

  * OpenReplayKit.framework

* 使用时需要在工程中导入如下系统framework:

  * AssetsLibrary.framework
  * AVFoundation.framework
  * AVKit.framework
  * CoreMedia.framework
  * Foundation.framework
  * MediaPlayer.framework
  * UIKit.framework

* ORKScreenRecorder 录屏类

  * 获取单例对象

    ```objective-c
    /**
     生成单例对象

     @return 单例对象
     */
    + (ORKScreenRecorder *)sharedRecorder;
    ```

  * 对象属性

    ```objective-c
    /**
     是否正在录屏
     */
    @property (nonatomic, readonly, getter = isRecording) BOOL recording;

    /**
     是否使用麦克风录音
     */
    @property (nonatomic, getter = isMicrophoneEnabled) BOOL microphoneEnabled;
    ```

  - 开始录屏

    ```objective-c
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
    ```

    二者的区别只是第一个方法可以选择不开启麦克风

  - 结束录屏

    ```objective-c
    /**
     结束录屏

     @param handler 录屏结束回调是否有产生错误, 无错误回调预览视图控制器
     */
    - (void)stopRecordingWithHandler:(void(^)(ORKPreviewViewController *previewViewController, NSError *error))handler;
    ```

* ORKPreviewViewController 录屏预览视图控制器

  * 需要签订的代理

    ```objective-c
    /**
     预览视图控制器代理
     */
    @property (nonatomic, weak) id<ORKPreviewViewControllerDelegate>previewControllerDelegate;
    ```

  * ORKPreviewViewControllerDelegate代理

    * 完成预览回调

      ```objective-c

      /**
       完成预览回调

       @param previewController 预览视图控制器
       */
      - (void)previewControllerDidFinish:(ORKPreviewViewController *)previewController;
      ```

* 具体使用示例可以参考OpenReplayDemo.

  ​


Copyright © 2017年 openKit.SunQuan All rights reserved. 

