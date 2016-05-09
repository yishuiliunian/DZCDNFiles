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

- (void) downloadImage:(NSString*)url downloaded:(CDNImageDownloadedBlock)completion
{
    if (!url) {
        NSError* error = [NSError errorWithDomain:@"com.dz.cnd.error" code:-88 userInfo:@{NSLocalizedDescriptionKey:@"URL不能为空"}];
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    
    DZCDNAction* action = [DZCDNAction CDNActionForFileType:DZCDNFileTypeImage WithURL:[NSURL URLWithString:url] checkDuration:60*60*24*30 completion:^(id serverObject, NSError *error) {
        if (completion) {
            completion(serverObject, error);
        }
    }];
    [[NSOperationQueue CDNImageQueue] addOperation:action];
}

- (void) downloadData:(NSString*)url downloaded:(CDNImageDownloadedBlock)completion {
    if (!url) {
        NSError* error = [NSError errorWithDomain:@"com.dz.cnd.error" code:-88 userInfo:@{NSLocalizedDescriptionKey:@"URL不能为空"}];
        if (completion) {
            completion(nil, error);
        }
        return;
    }
    
    DZCDNAction* action = [DZCDNAction CDNActionForFileType:DZCDNFileTypeData WithURL:[NSURL URLWithString:url] checkDuration:60*60*24*30 completion:^(id serverObject, NSError *error) {
        if (completion) {
            completion(serverObject, error);
        }
    }];
    [[NSOperationQueue CDNImageQueue] addOperation:action];
}
@end
