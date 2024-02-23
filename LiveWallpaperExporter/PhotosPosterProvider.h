//
//  PhotosPosterProvider.h
//  LiveWallpaperExporter
//
//  Created by w30043479 on 2024/2/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotosPosterProvider : NSObject

- (NSArray<NSString *> *)posterIdentifiers;
- (NSURL *)urlWithPosterIdentifier:(NSString *)posterIdentifier;
- (NSURL *)videoBundleURLWithPosterIdentifier:(NSString *)posterIdentifier;

@end

NS_ASSUME_NONNULL_END
