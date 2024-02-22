//
//  PhotosPosterProvider.m
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

#import "PhotosPosterProvider.h"

#import <objc/runtime.h>

#import "MCMContainer.h"
#import "MCMContainerManager.h"

#define kMCMContainerTypeBundle "MCMAppContainer"
#define kMCMContainerTypeData "MCMAppDataContainer"
#define kMCMContainerTypeGroup "MCMSharedDataContainer"
#define kMCMContainerTypePlugin "MCMPluginKitPluginDataContainer"
#define kMCMContainerTypeSystem "MCMSystemDataContainer"
#define kMCMContainerTypeSystemGroup "MCMSharedSystemDataContainer"

static NSURL *MCMGetContainerURL(NSString *containerType, NSString *identifier,
                                 NSError *__autoreleasing _Nullable *_Nullable error) {
    return [[objc_getClass(containerType.UTF8String) containerWithIdentifier:identifier error:error] url];
}

@implementation PhotosPosterProvider {
    NSString *_containerPath;
    NSString *_dataStorePath;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _containerPath = [MCMGetContainerURL(@kMCMContainerTypeData, @"com.apple.PosterBoard", nil) path];
        _dataStorePath = [_containerPath stringByAppendingPathComponent:@"Library/Application Support/PRBPosterExtensionDataStore"];
        
        NSArray<NSString *> *dsContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_dataStorePath error:nil];
        NSAssert(dsContents.count > 0, @"empty data store");
        
        _dataStorePath = [_dataStorePath stringByAppendingPathComponent:[dsContents firstObject]];
        _dataStorePath = [_dataStorePath stringByAppendingPathComponent:@"Extensions/com.apple.PhotosUIPrivate.PhotosPosterProvider/configurations"];
        
        BOOL isValidDataStore = NO;
        BOOL isDataStoreExists = [[NSFileManager defaultManager] fileExistsAtPath:_dataStorePath isDirectory:&isValidDataStore];
        NSAssert(isValidDataStore && isDataStoreExists, @"invalid data store");
    }
    return self;
}

- (NSArray<NSString *> *)photoIdentifiers {
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_dataStorePath error:nil];
}

@end
