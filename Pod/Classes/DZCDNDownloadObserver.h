//
//  DZCDNDownloadObserver.h
//  Pods
//
//  Created by stonedong on 16/5/26.
//
//

#import <Foundation/Foundation.h>
@protocol DZCDNActionListener <NSObject>
- (void) CDNActionWithURL:(NSURL*)url didFinishWith:(NSString*)fileURL error:(NSError*)error;
@end

@interface DZCDNDownloadObserver : NSObject
{
    NSMutableArray* _lisenters;
}
@property (nonatomic, strong, readonly) NSURL* originURL;
- (instancetype) initWithOriginURL:(NSURL*)originURL;
- (void) addListener:(id<DZCDNActionListener>)lisenter;
- (void) removeListener:(id<DZCDNActionListener>)lisenter;
- (void) onError:(NSError*)error;
- (void) onSuccessWithLocalFilePath:(NSString*)filePath;
@end
