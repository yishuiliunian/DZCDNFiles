
#import "DZCDNAction.h"
#import "DZCDNJsonAction.h"
#import "DZCDNImageAction.h"
#import "DZCDNWavAction.h"
#import <CommonCrypto/CommonDigest.h>
#import "DZFileUtils.h"
@interface NSString (MD5)

@end

@implementation NSString (MD5)

- (NSString *) MD5Hash {
    
    CC_MD5_CTX md5;
    CC_MD5_Init (&md5);
    CC_MD5_Update (&md5, [self UTF8String], (int)[self length]);
    
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final (digest, &md5);
    NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                   digest[0],  digest[1],
                   digest[2],  digest[3],
                   digest[4],  digest[5],
                   digest[6],  digest[7],
                   digest[8],  digest[9],
                   digest[10], digest[11],
                   digest[12], digest[13],
                   digest[14], digest[15]];
    
    return s;
    
}



@end

static NSString* const kLastUpdateDate = @"kLastUpdateDate";

NSString* DZCDNActionKey(NSString* key, NSString* type) {
    return [NSString stringWithFormat:@"DZCDNFiles-%@-%@", key,type];
}

@interface DZCDNAction ()
{
    NSDate* _lastCheckDate;
    NSString* _fileKey;
}
@end

@implementation DZCDNAction
#pragma mark common tools
+(NSString*) CDNLocalCacheFilesPath
{
    static NSString* documentDirectory= nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        documentDirectory = [paths objectAtIndex:0] ;
        documentDirectory = [documentDirectory stringByAppendingPathComponent:@"com.tentcent.cdn.files"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:documentDirectory]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:documentDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        };
    });
	return documentDirectory;
}

+ (DZCDNAction*) CDNActionForFileType:(DZCDNFileType)type
                              WithURL:(NSURL *)url
                        checkDuration:(NSTimeInterval)duration
{
    switch (type) {
        case DZCDNFileTypeStructJSON:
            return [[DZCDNJsonAction alloc] initWithURL:url checkDuration:duration ];
        case DZCDNFileTypeImagePng:
        case DZCDNFileTypeImage:
            return [[DZCDNImageAction alloc] initWithURL:url checkDuration:duration ];
        case DZCDNFileAudioWAV:
            return [[DZCDNWavAction alloc] initWithURL:url checkDuration:duration ];
        default:
            return [[DZCDNAction alloc] initWithURL:url checkDuration:duration ];
            break;
    }
}
#pragma mark -


#pragma mark init
- (instancetype) initWithURL:(NSURL *)url
               checkDuration:(NSTimeInterval)duration
{
    self = [super init];
    if (!self) {
        return self;
    }
    [self setUrl:url];
    _observer = [[DZCDNDownloadObserver alloc] initWithOriginURL:url];
    _checkDuration = duration;
    return self;
}


#pragma mark -


+ (NSString*) localFilePathForURL:(NSURL*)url
{
    NSString* fileKey = [url.absoluteString MD5Hash];
    NSString* path = [[DZCDNAction CDNLocalCacheFilesPath] stringByAppendingPathComponent:fileKey];
    return path;
}
+ (BOOL) isDownloadedURL:(NSURL*)url
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self localFilePathForURL:url]];
}
- (BOOL) isExistLocalData
{
    NSString* filePaht = self.localFilePath;
    return [[NSFileManager defaultManager] fileExistsAtPath:filePaht];
}

- (NSString*) localFilePath
{
    return [[DZCDNAction CDNLocalCacheFilesPath] stringByAppendingPathComponent:_fileKey];
}

- (void) setUrl:(NSURL *)url
{
    if (_url != url) {
        _url = url;
        _fileKey = [url.absoluteString MD5Hash];
        if (!_fileKey) {
            _fileKey = [url.relativeString MD5Hash];
        }
    }
}

- (NSDate*) lastCheckDate
{
    if (!_lastCheckDate) {
        NSString* key = DZCDNActionKey(_fileKey, kLastUpdateDate);
        NSDate* date =  [[NSUserDefaults standardUserDefaults] objectForKey:key];
        if (date) {
            _lastCheckDate = date;
        } else {
            _lastCheckDate = [NSDate date];
        }
    }
    return _lastCheckDate;
}

- (BOOL) shouldPullData
{
    if (!self.isExistLocalData) {
        return YES;
    }
    NSDate* lastDate = [self lastCheckDate];
    
    if (ABS([lastDate timeIntervalSinceNow]) < _checkDuration) {
        return NO;
    }
    return YES;
}

- (void) setLastCheckDate:(NSDate*)date
{
    NSString* key = DZCDNActionKey(_fileKey, kLastUpdateDate);
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) pullCDNData:(NSError *__autoreleasing*)error
{
    
    __block NSError* localError= nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSURLSessionDownloadTask* task = [[NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]] downloadTaskWithURL:_url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            localError = error;
        } else {
            DZMoveFile(location.path, self.localFilePath, &localError);
        }
        dispatch_semaphore_signal(sem);
    }];
    [task resume];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    if (localError) {
        if (error != NULL) {
            *error = localError;
        }
        return NO;
    }

    return YES;
}

- (id) decodeCDNFileData:(NSData *)data error:(NSError **)error
{
    if (error != NULL) {
        *error = [NSError errorWithDomain:@"com.tencent.cdn" code:-8002 userInfo:@{NSURLLocalizedLabelKey:@"decodeCDNFileData:error 没有实现"}];
    }
    return nil;
}

- (void) onSuccessDecodeObject:(id)object
{
    dispatch_sync(dispatch_get_main_queue(), ^{
    });
}

- (void) onSuccessFile:(NSString*)filePath
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.observer onSuccessWithLocalFilePath:self.localFilePath];
    });
}
- (void) onError:(NSError*)error
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.observer onError:error];
    });
}

- (void) onSuccess
{
    [self onSuccessFile:self.localFilePath];
}
- (void) main
{
    @autoreleasepool {
        if (![self shouldPullData]) {
            [self onSuccess];
        } else {
            NSError* error = nil;
            if(![self pullCDNData:&error]) {
                [self onError:error];
                return;
            }
        }
        //
        NSError* error = nil;
        [self setLastCheckDate:[NSDate date]];
        [self onSuccess];
    }
}
@end
