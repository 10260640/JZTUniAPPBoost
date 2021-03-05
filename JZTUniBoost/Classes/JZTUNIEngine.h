//
//  JZTUNIEngine.h
//  JZTUniBoost
//
//  Created by 张欣 on 2021/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    JZTUNIAppPathError, //文件不存在错误
    JZTUNIAppDownLoadError, //下载错误
    JZTUNIAppOpenError, //小程序内部错误
} JZTUNIErrorType;

typedef enum : NSUInteger {
    JZTSERIAL, //串行
    JZTCONCURRENT, //并行
} JZTQUEUEType;


typedef enum :NSUInteger
{
    JZTUniNetWorkStatusUnknown,
    JZTUniNetWorkStatusNotReachable,
    JZTUNiNetWorkStatusReachable3G4G,
    JZTUNiNetWorkStatusReachableViaWiFi,
}
JZTUniNetWorkState;

@interface JZTUniAppModel : NSObject

@property (strong,nonatomic) NSString *appId;
@property (nonatomic) BOOL hasUpdate;
@property (strong,nonatomic) NSString *versionName;
@property (nonatomic) NSInteger versionCode;
@property (strong,nonatomic) NSString *downUrl;
@property (strong,nonatomic) NSString *md5;

@end

@interface JZTUNIEngine : NSObject

+ (instancetype)sharedInstance;

- (void)openAppWithModel:(JZTUniAppModel*)model success:(void (^)(void))success
                progress:(void (^)(double downloadProgressValue))progress
                   faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile;

- (void)openAppWithAppID:(NSString*)appID success:(void (^)(void))success faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile;

- (void)backGroundDownload:(NSArray<JZTUniAppModel*>*)downLoadList queueType:(JZTQUEUEType)queueType;

- (void)stopDownload;

- (void)reuseDownload;


@end

NS_ASSUME_NONNULL_END
