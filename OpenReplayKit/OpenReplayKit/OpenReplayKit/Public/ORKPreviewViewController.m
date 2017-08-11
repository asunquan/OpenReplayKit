//
//  ORKPreviewViewController.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ORKPreviewViewController.h"

#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ORKMediaPath.h"
#import "ORKVideoRecorder.h"

@interface ORKPreviewViewController ()

@property (nonatomic, strong) UIImageView *previewIV;

@property (nonatomic, strong) UIControl *hideCT;

@property (nonatomic, strong) MPMoviePlayerController *moviePlayer;

@property (nonatomic, strong) UINavigationItem *topItem;

@property (nonatomic, strong) UINavigationBar *topBar;

@property (nonatomic, strong) UINavigationItem *bottomItem;

@property (nonatomic, strong) UINavigationBar *bottomBar;

@property (nonatomic, strong) UIActivityViewController *activityVC;

@property (nonatomic, assign) BOOL isHidden;

@end

@implementation ORKPreviewViewController

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        [self addAllObservers];
        
        [self initPreviewImageView];
        
        [self initTopNavigationBar];
        
        [self initBottomNavigationBar];
    }
    
    return self;
}

- (void)layoutSubviews
{
    self.previewIV.frame = self.view.bounds;
    
    self.hideCT.frame = self.previewIV.bounds;
    
    self.topBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 64);
    
    self.bottomBar.frame = CGRectMake(0, self.view.bounds.size.height - 44, self.view.bounds.size.width, 44);
    
    [self.view addSubview:self.previewIV];
    
    [self.previewIV addSubview:self.hideCT];
    
    [self.view addSubview:self.topBar];
    
    [self.view addSubview:self.bottomBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self layoutSubviews];
}

- (void)addAllObservers
{
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(movieDidFinishPlay) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

- (void)movieDidFinishPlay
{
    [self.moviePlayer.view removeFromSuperview];
}

- (void)initPreviewImageView
{
    self.previewIV = [[UIImageView alloc] init];
    self.previewIV.backgroundColor = UIColor.redColor;
    self.previewIV.image = self.thumbnail;
    self.previewIV.userInteractionEnabled = YES;
    
    self.hideCT = [[UIControl alloc] init];
    [self.hideCT addTarget:self action:@selector(hideAllBars) forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideAllBars
{
    self.topBar.hidden = !self.isHidden;
    self.bottomBar.hidden = !self.isHidden;
    self.isHidden = !self.isHidden;
}

- (void)initTopNavigationBar
{
    self.topItem = [[UINavigationItem alloc] initWithTitle:self.bundleName];
    self.topItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    self.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"存储" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonClicked)];
    
    self.topBar = [[UINavigationBar alloc] init];
    self.topBar.items = @[self.topItem];
}

- (void)cancelButtonClicked
{
    if ([self.previewControllerDelegate respondsToSelector:@selector(previewControllerDidFinish:)])
    {
        [self.previewControllerDelegate previewControllerDidFinish:self];
    }
}

- (void)saveButtonClicked
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:self.mixedVideoURL
                                completionBlock:^(NSURL *assetURL, NSError *error)
    {
        if ([self.previewControllerDelegate respondsToSelector:@selector(previewControllerDidFinish:)])
        {
            [self.previewControllerDelegate previewControllerDidFinish:self];
        }
    }];
}

- (void)initBottomNavigationBar
{
    self.bottomItem = [[UINavigationItem alloc] init];
    self.bottomItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(systemItemActionButtonClicked)];
    self.bottomItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playMovieButtonClicked)];
    
    self.bottomBar = [[UINavigationBar alloc] init];
    self.bottomBar.items = @[self.bottomItem];
}

- (void)systemItemActionButtonClicked
{
    self.topItem.leftBarButtonItem.title = @"完成";
    self.topItem.leftBarButtonItem.style = UIBarButtonItemStyleDone;
    
    [self presentViewController:self.activityVC animated:YES completion:nil];
}

- (void)playMovieButtonClicked
{
    [self.view addSubview:self.moviePlayer.view];
    self.moviePlayer.contentURL = self.mixedVideoURL;
    
    [self.moviePlayer play];
}

#pragma mark - getter

- (UIImage *)thumbnail
{
    return [UIImage imageWithContentsOfFile:self.thumbnailPath];
}

- (NSString *)thumbnailPath
{
    NSDirectoryEnumerator *enumerator = [NSFileManager.defaultManager enumeratorAtPath:ORKMediaPath.thumbnailSavePath];
    
    NSString *name = enumerator.allObjects.firstObject;
    
    return [ORKMediaPath.thumbnailSavePath stringByAppendingPathComponent:name];
}

- (UIActivityViewController *)activityVC
{
    if (!_activityVC)
    {
        _activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.mixedVideoURL] applicationActivities:nil];
    }
    
    return _activityVC;
}

- (NSString *)bundleName
{
    NSString *key = (__bridge_transfer NSString *)kCFBundleNameKey;
    
    return NSBundle.mainBundle.infoDictionary[key];
}

- (MPMoviePlayerController *)moviePlayer
{
    if (!_moviePlayer)
    {
        _moviePlayer = [[MPMoviePlayerController alloc] init];
        _moviePlayer.backgroundView.backgroundColor = UIColor.whiteColor;
        _moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
        _moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        _moviePlayer.view.frame = self.view.bounds;
        _moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [_moviePlayer prepareToPlay];
    }
    
    return _moviePlayer;
}

- (NSURL *)mixedVideoURL
{
    NSDirectoryEnumerator *enumerator = [NSFileManager.defaultManager enumeratorAtPath:ORKMediaPath.mixedVideoSavePath];
    
    NSString *name = enumerator.allObjects.firstObject;
    
    NSString *path = [ORKMediaPath.mixedVideoSavePath stringByAppendingPathComponent:name];
    
    return [NSURL fileURLWithPath:path];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
