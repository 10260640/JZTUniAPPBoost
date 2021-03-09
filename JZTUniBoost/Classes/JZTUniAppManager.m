//
//  JZTUniAppManager.m
//  JZTUniBoost
//
//  Created by 张欣 on 2021/3/1.
//

#import "JZTUniAppManager.h"
#import "DCUniMP.h"
#import <AFNetworking/AFURLSessionManager.h>


@interface JZTUniAppManager()

@end

@implementation JZTUniAppManager

+ (NSString*)appPath:(NSString*)appID
{
    NSString *path = [self appRootPath];
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wgt",appID]];
    return filePath;
}

+ (NSString*)appRootPath
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/apps"];
    return path;
}

+ (BOOL)existsApp:(NSString*)url
{
    NSString *filePath = [[self appRootPath] stringByAppendingPathComponent:[url lastPathComponent]];
    NSLog(@"%@",filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        return YES;
    }
    return NO;
}

+ (NSString*)appID:(NSString*)url
{
    return [[url lastPathComponent] stringByDeletingPathExtension];
}

+ (NSURLSessionDownloadTask*)downloadApp:(NSString*)urlStr progress:(void (^)(double downloadProgressValue))progress
                    destination:(void (^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))destination
                    completionHandler:(void (^)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler

{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSString *path = [[urlStr lastPathComponent] stringByDeletingPathExtension];
    NSString *filePath = [self appPath:path];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        double downloadProgressValue = downloadProgress.fractionCompleted * 100;
        NSLog(@"下载进度：%.0f％", downloadProgressValue);
        progress(downloadProgressValue);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            destination(targetPath,response);
        });
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
         NSLog(@"下载完成");
        completionHandler(response,filePath,error);
    }];
    [downloadTask resume];
    
    return downloadTask;
}

+ (NSURLSessionDataTask*)downloadreUseApp:(NSString*)urlStr progress:(void (^)(double downloadProgressValue))progress
                    destination:(void (^)(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response))destination
                    completionHandler:(void (^)(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error))completionHandler
                    


{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:urlStr.lastPathComponent];
    
    NSString *fileName = [[urlStr lastPathComponent] stringByDeletingPathExtension];
    NSString *savePath = [self appPath:fileName];
    
    __block NSFileHandle *fileHandle = nil;
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    __block NSInteger currentLength = [self fileLengthForPath:path];
    
    // 设置HTTP请求头中的Range
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", currentLength];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *downloadTask = [manager dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
      
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        NSLog(@"%ld",httpResponse.statusCode);
        
    }];
    
    [manager setTaskDidCompleteBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSError * _Nullable error) {
        if (!error) {
            NSFileManager *fileManager = [[NSFileManager alloc] init];
//            [fileManager removeItemAtPath:savePath error:nil];
//            [fileManager copyItemAtPath:path toPath:savePath error:nil];
//            [fileManager removeItemAtPath:path error:nil];
            [fileManager replaceItemAtURL:[NSURL URLWithString:savePath] withItemAtURL:[NSURL URLWithString:path] backupItemName:nil options:NSFileManagerItemReplacementUsingNewMetadataOnly resultingItemURL:nil error:nil];
            
            NSLog(@"下载完成");
        }
        else{
            NSLog(@"中断");
        }
        completionHandler(task.response,nil,error);
    }];
    __block NSInteger fileLength;
    [manager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        
        fileLength = response.expectedContentLength + currentLength;
        
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:urlStr.lastPathComponent];
        NSFileManager *manager = [NSFileManager defaultManager];
        if (![manager fileExistsAtPath:path]) {
            [manager createFileAtPath:path contents:nil attributes:nil];
        }
        fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        return NSURLSessionResponseAllow;
    }];
    
    [manager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:data];
        currentLength += data.length;
        double downloadProgressValue = 100.0 * currentLength / fileLength;
        progress(downloadProgressValue);
        NSLog(@"下载进度：%.0f％", downloadProgressValue);
        
    }];
    [downloadTask resume];
    return downloadTask;
}

+ (NSInteger)fileLengthForPath:(NSString *)path {
    NSInteger fileLength = 0;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileLength = [fileDict fileSize];
        }
    }
    return fileLength;
}

+ (void)removeTempFile:(NSString*)urlStr
{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:urlStr.lastPathComponent];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:path error:nil];
}


+ (void)removeAllApps
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/apps"];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:path error:nil];
}


@end
