//
//  DZCDNActionManager.m
//  TimeUI
//
//  Created by stonedong on 14-6-16.
//  Copyright (c) 2014年 Stone Dong. All rights reserved.
//

#import "DZCDNActionManager.h"
#import "DZSingletonFactory.h"
#import "DZCDNAction.h"



@interface NSOperationQueue (Image)
+ (NSOperationQueue*) CDNImageQueue;
@end


@implementation NSOperationQueue (Image)

+ (NSOperationQueue*) CDNImageQueue
{
    static NSOperationQueue* queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [NSOperationQueue new];
    });
    return queue;
}

@end

@interface DZCDNActionManager ()
@end

@implementation DZCDNActionManager

 + (DZCDNActionManager*) shareManager
{
    return DZSingleForClass([DZCDNActionManager class]);
}


- (instancetype) init
{
    self = [super init];
    if (!self) {
        return self;
    }
    return self;
}

+ (NSString*) localFilePathForURL:(NSURL *)url
{
    return [DZCDNAction localFilePathForURL:url];
}

+ (BOOL) isDownloadedURL:(NSURL*)url
{
    return [DZCDNAction isDownloadedURL:url];
}

- (void) downloadFile:(NSString*)url type:(DZCDNFileType)type  withListener:(id<DZCDNActionListener>)listener
{
    if (!url) {
        NSError* error = [NSError errorWithDomain:@"com.dz.cnd.error" code:-88 userInfo:@{NSLocalizedDescriptionKey:@"URL不能为空"}];
        
        return;
    }
    //Get Current Download Action
    NSArray* operations = [[NSOperationQueue CDNImageQueue] operations];
    for (DZCDNAction* action in operations) {
        if ([action.url.absoluteString isEqualToString:url]) {
            [action.observer addListener:listener];
            return;
        }
    }
    //
    DZCDNAction* action = [DZCDNAction CDNActionForFileType:type WithURL:[NSURL URLWithString:url] checkDuration:60*60*24*30];
    [action.observer addListener:listener];
    [[NSOperationQueue CDNImageQueue] addOperation:action];
}
- (void) downloadImage:(NSString*)url downloadedWithLisenter:(id)listener
{
    [self downloadFile:url type:DZCDNFileTypeImage withListener:listener];
}

- (void) downloadWAVAudio:(NSString *)url downloadedWithLisenter:(id)listener
{
    [self downloadFile:url type:DZCDNFileAudioWAV withListener:listener];
}

- (BOOL) isDownloaingForURL:(NSURL *)url
{
    NSArray* operations = [[NSOperationQueue CDNImageQueue] operations];
    for (DZCDNAction* action in operations) {
        if ([action.url.absoluteString isEqualToString:url]) {
            return YES;
        }
    }
    return NO;
}
@end
