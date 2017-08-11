//
//  ViewController.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/7/31.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ViewController.h"

#import <OpenReplayKit/OpenReplayKit.h>

@interface ViewController () <ORKPreviewViewControllerDelegate>

@property (nonatomic, strong) UILabel *timeLB;

@property (nonatomic, assign) BOOL isRecording;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self addTimeLabel];
    
    [self addRecordButton];
}

- (void)addTimeLabel
{
    self.timeLB = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    self.timeLB.center = self.view.center;
    self.timeLB.textColor = UIColor.redColor;
    self.timeLB.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.timeLB];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 / 30
                                                      target:self
                                                    selector:@selector(showTime)
                                                    userInfo:nil
                                                     repeats:YES];
    
    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)showTime
{
    self.timeLB.text = self.nowTime;
}

- (NSString *)nowTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日 HH:mm:ss:SSS";
    
    return [formatter stringFromDate:NSDate.date];
}

- (void)addRecordButton
{
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeSystem];
    recordButton.frame = CGRectMake(40, 100, 80, 40);
    [recordButton setTitle:@"开始录屏" forState:UIControlStateNormal];
    [recordButton addTarget:self action:@selector(recordScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
}

- (void)recordScreen:(UIButton *)button
{
    if (!self.isRecording)
    {
        [ORKScreenRecorder.sharedRecorder startRecordingWithHandler:^(NSError *error)
        {
            
        }];
        
        self.isRecording = YES;
        
        [button setTitle:@"结束录屏" forState:UIControlStateNormal];
    }
    else
    {
        self.isRecording = NO;
        
        button.userInteractionEnabled = NO;
        [button setTitle:@"合成中..." forState:UIControlStateNormal];
        
        [ORKScreenRecorder.sharedRecorder stopRecordingWithHandler:^(ORKPreviewViewController *previewViewController, NSError *error)
        {
            previewViewController.previewControllerDelegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^
            {
                [self presentViewController:previewViewController animated:YES completion:nil];
                
                button.userInteractionEnabled = YES;
                [button setTitle:@"开始录屏" forState:UIControlStateNormal];
            });
        }];
    }
}

#pragma mark - ORKPreviewViewControllerDelegate

- (void)previewControllerDidFinish:(ORKPreviewViewController *)previewController
{
    [previewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
