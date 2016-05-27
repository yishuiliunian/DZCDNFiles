//
//  DZCDNDownloadObserver.m
//  Pods
//
//  Created by stonedong on 16/5/26.
//
//

#import "DZCDNDownloadObserver.h"

@implementation DZCDNDownloadObserver
- (instancetype) initWithOriginURL:(NSURL*)originURL
{
    self = [super init];
    if (!self) {
        return self;
    }
    _lisenters = [NSMutableArray new];
    return self;
}

- (void) addListener:(id<DZCDNActionListener>)lisenter
{
    for (NSValue* value  in _lisenters) {
        if ([value nonretainedObjectValue] == lisenter) {
            return;
        }
    }
    NSValue* value = [NSValue valueWithNonretainedObject:lisenter];
    [_lisenters addObject:value];
}

- (void) removeListener:(id<DZCDNActionListener>)lisenter
{
    NSArray* copyedListeners = [_lisenters copy];
    for (NSValue* value in copyedListeners) {
        if ([value nonretainedObjectValue] == lisenter) {
            [_lisenters removeObject:value];
        }
    }
}

- (void) onError:(NSError*)error
{
    for (NSValue* value in _lisenters) {
        id<DZCDNActionListener>listener  = [value nonretainedObjectValue];
        if ([listener respondsToSelector:@selector(CDNActionWithURL:didFinishWith:error:)]) {
            [listener CDNActionWithURL:self.originURL didFinishWith:nil error:error];
        }
    }
}

- (void) onSuccessWithLocalFilePath:(NSString*)filePath
{
    for (NSValue* value in _lisenters) {
        id<DZCDNActionListener>listener  = [value nonretainedObjectValue];
        if ([listener respondsToSelector:@selector(CDNActionWithURL:didFinishWith:error:)]) {
            [listener CDNActionWithURL:self.originURL didFinishWith:filePath error:nil];
        }
    }
}
@end
