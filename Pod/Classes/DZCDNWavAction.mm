//
//  DZCDNWavAction.m
//  Pods
//
//  Created by stonedong on 16/5/15.
//
//

#import "DZCDNWavAction.h"
#import "EMVoiceConverter.h"
#import <DZFileUtils/DZFileUtils.h>
@implementation DZCDNWavAction
- (id) decodeCDNFileData:(NSData*)data error:(NSError* __autoreleasing*)error
{
    return data;
}

- (void) localized:(NSData *)data decodeObject:(id)object
{
    if ([object isKindOfClass:[NSData class]]) {
        NSString* path = DZTempFilePathWithExtension(@"amr");
        BOOL writeResult = [data writeToFile:self.localFilePath atomically:YES];
    }
}

@end
