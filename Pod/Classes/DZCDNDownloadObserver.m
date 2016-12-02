//
//  DZCDNDownloadObserver.m
//  Pods
//
//  Created by stonedong on 16/5/26.
//
//

#import <AMapSearchKit/AMapSearchKit.h>
#import "DZCDNDownloadObserver.h"
#import "DZObjectProxy.h"

@interface DZCDNDownloadObserver ()
{
    NSRecursiveLock * _observerLock;
}
@end

@implementation DZCDNDownloadObserver

- (instancetype)init {
    self = [super init];
    if (!self) {
        return  self;
    }
    _observerLock = [NSRecursiveLock new];
    _lisenters = [NSMutableArray new];
    return self;
}
- (instancetype) initWithOriginURL:(NSURL*)originURL
{
    self = [self init];
    if (!self) {
        return self;
    }
    _originURL = originURL;
    return self;
}

- (void) addListener:(id<DZCDNActionListener>)lisenter
{
    [_observerLock lock];
    for (id<DZCDNActionListener> value  in _lisenters) {
        if ([value isEqual:lisenter]) {
            return;
        }
    }
    DZWeakProxy * weakProxy = [DZWeakProxy proxyWithTarget:lisenter];
    [_lisenters addObject:weakProxy];
    [_observerLock unlock];
}

- (void) removeListener:(id<DZCDNActionListener>)lisenter
{
    [_observerLock lock];
    NSArray* copyedListeners = [_lisenters copy];
    for (id<DZCDNActionListener> value in copyedListeners) {
        if ([value isEqual:lisenter]) {
            [_lisenters removeObject:value];
        }
    }
    [_observerLock unlock];
}

- (void) onError:(NSError*)error
{
    [_observerLock lock];
    for (id<DZCDNActionListener> listener in _lisenters) {
        if ([listener respondsToSelector:@selector(CDNActionWithURL:didFinishWith:error:)]) {
            [listener CDNActionWithURL:self.originURL didFinishWith:nil error:error];
        }
    }
    [_observerLock unlock];
}

- (void) onSuccessWithLocalFilePath:(NSString*)filePath
{
    [_observerLock lock];
    for (id<DZCDNActionListener> listener in _lisenters) {
        if ([listener respondsToSelector:@selector(CDNActionWithURL:didFinishWith:error:)]) {
            [listener CDNActionWithURL:self.originURL didFinishWith:filePath error:nil];
        }
    }
    [_observerLock unlock];
}
@end
