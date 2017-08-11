//
//  ORKMediaError.m
//  OpenReplayDemo
//
//  Created by 孙泉 on 2017/8/2.
//  Copyright © 2017年 openKit. All rights reserved.
//

#import "ORKMediaError.h"

#define ORKERRORDOMAINFOLDER            (@"Create folder error")
#define ORKERRORCODEFOLDER              (-70001)

#define ORKERRORDOMAINADDINPUT          (@"AVAssetWriter can't add AVAssetWriterInput")
#define ORKERRORCODEADDINPUT            (-70101)

#define ORKERRORDOMAININPUTMOREDATA     (@"AVAssetWriterInput is not ready for more media data")
#define ORKERRORCODEINPUTMOREDATA       (-70102)

#define ORKERRORDOMAINPIXELBUFFER       (@"CVPixelBuffer create return error")
#define ORKERRORCODEPIXELBUFFER         (-70111)

@implementation ORKMediaError

+ (NSError *)folderError
{
    NSError *error = [NSError errorWithDomain:ORKERRORDOMAINFOLDER
                                         code:ORKERRORCODEFOLDER
                                     userInfo:@{}];
    
    return error;
}

+ (NSError *)addInputError
{
    NSError *error = [NSError errorWithDomain:ORKERRORDOMAINADDINPUT
                                         code:ORKERRORCODEADDINPUT
                                     userInfo:@{}];
    
    return error;
}

+ (NSError *)inputMoreDataError
{
    NSError *error = [NSError errorWithDomain:ORKERRORDOMAININPUTMOREDATA
                                         code:ORKERRORCODEINPUTMOREDATA
                                     userInfo:@{}];
    
    return error;
}

+ (NSError *)pixelBufferError
{
    NSError *error = [NSError errorWithDomain:ORKERRORDOMAINPIXELBUFFER
                                         code:ORKERRORCODEPIXELBUFFER
                                     userInfo:@{}];
    
    return error;
}

@end
