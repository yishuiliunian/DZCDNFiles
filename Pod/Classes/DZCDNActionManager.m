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

@interface DZDowndloadDelegate : NSObject

@property (nonatomic, strong) CDNImageDownloadedBlock finishBlock;
@end

@implementation DZDowndloadDelegate

@end

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
{
    NSMutableDictionary* _ququeMap;
}
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
    _ququeMap = [NSMutableDictionary new];
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

- (void) downloadFile:(NSString*)url type:(DZCDNFileType)type  downloaded:(CDNImageDownloadedBlock)completion
{
    if (!url) {
        NSError* error = [NSError errorWithDomain:@"com.dz.cnd.error" code:-88 userInfo:@{NSLocalizedDescriptionKey:@"URL不能为空"}];
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    //Get Current Download Action
    NSArray* operations = [[NSOperationQueue CDNImageQueue] operations];
    for (DZCDNAction* action in operations) {
        if ([action.url.absoluteString isEqualToString:url]) {
            if (action.actionCompletionBlock == completion) {
                return;
            }
            __weak typeof(action) wAction = action;
            [action setActionCompletionBlock:^(id serverObject, NSError* error){
                
                if (wAction.actionCompletionBlock) {
                    wAction.actionCompletionBlock(serverObject, error);
                }
                if (completion) {
                    completion(serverObject, error);
                }
            }];
            return;
        }
    }
    //
    
    DZCDNAction* action = [DZCDNAction CDNActionForFileType:type WithURL:[NSURL URLWithString:url] checkDuration:60*60*24*30 completion:^(id serverObject, NSError *error) {
        if (completion) {
            completion(serverObject, error);
        }
    }];
    [[NSOperationQueue CDNImageQueue] addOperation:action];
}
- (void) downloadImage:(NSString*)url downloaded:(CDNImageDownloadedBlock)completion
{
    [self downloadFile:url type:DZCDNFileTypeImage downloaded:completion];
}

- (void) downloadData:(NSString*)url downloaded:(CDNImageDownloadedBlock)completion {
    [self downloadFile:url type:DZCDNFileTypeData downloaded:completion];
}

- (void) downloadWAVAudio:(NSString *)url downloaded:(CDNImageDownloadedBlock)completion
{
    [self downloadFile:url type:DZCDNFileAudioWAV downloaded:completion];
}
@end
