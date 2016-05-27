//
//  DZCDNActionManager.h
//  TimeUI
//
//  Created by stonedong on 14-6-16.
//  Copyright (c) 2014年 Stone Dong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DZCDNDownloadObserver.h"
@interface DZCDNActionManager : NSObject
+ (DZCDNActionManager*) shareManager;
- (void) downloadImage:(NSString*)url downloadedWithLisenter:(id<DZCDNActionListener>)listener;
+ (NSString*) localFilePathForURL:(NSURL*)url;
+ (BOOL) isDownloadedURL:(NSURL*)url;
- (BOOL) isDownloaingForURL:(NSURL*)url;
- (void) downloadWAVAudio:(NSString *)url downloadedWithLisenter:(id<DZCDNActionListener>)listener;
@end
