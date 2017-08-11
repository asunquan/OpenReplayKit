//
//  ORKMediaError.h
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/2.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORKMediaError : NSObject

+ (NSError *)folderError;

+ (NSError *)addInputError;

+ (NSError *)inputMoreDataError;

+ (NSError *)pixelBufferError;

@end
