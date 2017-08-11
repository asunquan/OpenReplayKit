//
//  ORKScreenCapturer.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/1.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ORKScreenCapturer.h"

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@implementation ORKScreenCapturer

+ (UIImage *)currentScreen
{
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    
    CGSize size = CGSizeMake(keyWindow.bounds.size.width, keyWindow.bounds.size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    for (UIWindow *window in UIApplication.sharedApplication.windows)
    {
        CGContextSaveGState(context);
        
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        
        CGContextConcatCTM(context, window.transform);
        
        CGContextTranslateCTM(context, - window.bounds.size.width * window.layer.anchorPoint.x, - window.bounds.size.height * window.layer.anchorPoint.y);
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)])
        {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        }
        else
        {
            [window.layer renderInContext:context];
        }
        
        CGContextRestoreGState(context);
    }
    
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return screenImage;
}

@end
