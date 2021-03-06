//
//  DZCDNAction.h
//  TimeUI
//
//  Created by stonedong on 14-6-16.
//  Copyright (c) 2014年 Stone Dong. All rights reserved.
//

#import <Foundation/Foundation.h>

//
//  DZCDNAction.m
//  TimeUI
//
//  Created by stonedong on 14-6-16.
//  Copyright (c) 2014年 Stone Dong. All rights reserved.
//

#import "DZCDNAction.h"
#import "DZCDNDownloadObserver.h"

typedef enum {
    DZCDNFileTypeImageJpeg,
    DZCDNFileTypeImagePng,
    DZCDNFileTypeStructXML,
    DZCDNFileTypeStructJSON,
    DZCDNFileTypeImage,
    DZCDNFileTypeData,
    DZCDNFileAudioWAV
}DZCDNFileType;





@interface DZCDNAction : NSOperation
/**
 *  价差更新的时间间隔，以秒为单位
 */
@property (nonatomic, assign) NSTimeInterval checkDuration;

/**
 *  标识改向CDN拉取信息的key
 */
@property (nonatomic, strong, readonly) NSURL* url;
@property (nonatomic, strong, readonly) NSString* localFilePath;
@property (nonatomic, assign, readonly) BOOL isExistLocalData;
@property (nonatomic, strong, readonly) DZCDNDownloadObserver* observer;

+ (DZCDNAction*) CDNActionForFileType:(DZCDNFileType)type
                              WithURL:(NSURL *)url
                        checkDuration:(NSTimeInterval)duration;
+ (NSString*) localFilePathForURL:(NSURL*)url;
+ (BOOL) isDownloadedURL:(NSURL*)url;
- (instancetype) initWithURL:(NSURL*)url checkDuration:(NSTimeInterval)duration;
- (id) decodeCDNFileData:(NSData*)data error:(NSError* __autoreleasing*)error;

@end

