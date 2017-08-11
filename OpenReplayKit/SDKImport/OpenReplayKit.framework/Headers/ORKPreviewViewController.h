//
//  ORKPreviewViewController.h
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ORKPreviewViewControllerDelegate;

@interface ORKPreviewViewController : UIViewController

/**
 预览视图控制器代理
 */
@property (nonatomic, weak) id<ORKPreviewViewControllerDelegate>previewControllerDelegate;

@end


@protocol ORKPreviewViewControllerDelegate <NSObject>

@optional

/**
 完成预览回调

 @param previewController 预览视图控制器
 */
- (void)previewControllerDidFinish:(ORKPreviewViewController *)previewController;

- (void)previewController:(ORKPreviewViewController *)previewController didFinishWithActivityTypes:(NSSet <NSString *> *)activityTypes;

@end
