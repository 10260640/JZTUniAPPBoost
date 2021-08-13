//
//  JZTUNIEngine.h
//  JZTUniBoost
//
//  Created by 张欣 on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import "DCUniMP.h"

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
@property (nonatomic) NSInteger downloadStrategy; //下载策略1：不启动后台下载 ，2 ：仅WiFi，  3：所有网络状态

@end

@protocol JZTUNIEngineDelegate <NSObject>
/// 监听小程序发送的事件回调方法
/// @param event 事件
/// @param data 参数
/// @param callback 回调方法，回传数据给小程序
- (void)onUniMPEventReceive:(NSString *)event data:(id)data callback:(DCUniMPKeepAliveCallback)callback;

@end

@interface JZTUNIEngine : NSObject

@property (nonatomic, weak) id <JZTUNIEngineDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)openAppWithModel:(JZTUniAppModel *)model success:(void (^)(void))success
                progress:(void (^)(double downloadProgressValue))progress
                   faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile;
///打开小程序方法
/// @param appID 小程序ID
- (void)openAppWithAppID:(NSString*)appID success:(void (^)(void))success faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile;
///打开小程序方法
/// @param appID 小程序ID
/// @param redirectPath 启动后直接打开的页面路径
/// @param arguments 传入小程序参数
- (void)openAppWithAppID:(NSString *)appID withRedirectPath:(NSString *)redirectPath withArguments:(NSDictionary *)arguments success:(void (^)(void))success faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile;


- (void)backGroundDownload:(NSArray<JZTUniAppModel*>*)downLoadList queueType:(JZTQUEUEType)queueType;

- (void)configNetWork;

- (void)stopDownload;

- (void)reuseDownload;

- (void)testCancel;


@end

NS_ASSUME_NONNULL_END
