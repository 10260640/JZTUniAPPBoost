//
//  JZTUniAppManager.h
//  JZTUniBoost
//
//  Created by 张欣 on 2021/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JZTUniAppManager : NSObject

+ (NSString*)appPath:(NSString*)appID;

+ (NSString*)appRootPath;

+ (BOOL)existsApp:(NSString*)url;

+ (NSString*)appID:(NSString*)url;

+ (NSURLSessionDownloadTask*)downloadApp:(NSString*)urlStr progress:(void (^)(double downloadProgressValue))progress
                    destination:(void (^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))destination
                       completionHandler:(void (^)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

+ (NSURLSessionDataTask*)downloadreUseApp:(NSString*)urlStr progress:(void (^)(double downloadProgressValue))progress
                    destination:(void (^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))destination
                            completionHandler:(void (^)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler;

+ (void)removeTempFile:(NSString*)urlStr;

@end

NS_ASSUME_NONNULL_END
