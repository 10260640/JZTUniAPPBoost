//
//  JZTUNIEngine.m
//  JZTUniBoost
//
//  Created by 张欣 on 2021/3/1.
//

#import "JZTUNIEngine.h"
#import "DCUniMP.h"
#import "JZTUniAppLoadingVC.h"
#import "JZTUniAppManager.h"

@implementation JZTUniAppModel

@end

@interface JZTUNIEngine()<DCUniMPSDKEngineDelegate>
{
    dispatch_group_t group;
    dispatch_queue_t queue;
    dispatch_queue_t squeue;
}
@property (strong,atomic) NSMutableArray<NSURLSessionDataTask*> *taskList;
@property (nonatomic, weak) DCUniMPInstance *uniMPInstance;
@property (nonatomic,strong) JZTUniAppLoadingVC *loadingVC;
@property (nonatomic,strong) NSURLSessionDataTask *cureentTask;
@end

@implementation JZTUNIEngine

+ (instancetype)sharedInstance {
    static JZTUNIEngine * ins = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ins = [[JZTUNIEngine alloc] init];
    });
    return ins;
}

- (instancetype)init
{
    if (self = [super init]) {
        group=dispatch_group_create();
        queue = dispatch_queue_create("com.jztuni.download", DISPATCH_QUEUE_CONCURRENT);
        squeue = dispatch_queue_create("com.jztuni.sdonwload", DISPATCH_QUEUE_SERIAL);
        self.taskList = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)openAppWithModel:(JZTUniAppModel*)model success:(void (^)(void))success
                progress:(void (^)(double downloadProgressValue))progress
                   faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile{
    
    __weak __typeof(self)weakSelf = self;
    BOOL exists = [JZTUniAppManager existsApp:model.downUrl];
    NSString *appID = model.appId;
    if (exists && ![self canUpdate:model])
    {
        [weakSelf openUniMP:appID success:^{
            success();
        } faile:^(NSString *msg, JZTUNIErrorType errorType) {
            faile(msg,errorType);
        }];
    }
    else{
        
        if (self.cureentTask) {
            [self.cureentTask cancel];
            self.cureentTask = nil;
        }
        [self removeDownLoadTask:model.downUrl];
        
        
        if (exists && [self canUpdate:model]) {
            [JZTUniAppManager removeTempFile:model.downUrl];
        }
        
        self.cureentTask = [JZTUniAppManager downloadreUseApp:model.downUrl progress:^(double downloadProgressValue) {
            progress(downloadProgressValue);
        } destination:^(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {

        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
            if (error) {
                faile(@"下载失败",JZTUNIAppDownLoadError);
            }
            else{
                [weakSelf releaseApp:appID];
                [weakSelf openUniMP:appID success:^{
                    success();
                } faile:^(NSString *msg, JZTUNIErrorType errorType) {
                    faile(msg,errorType);
                }];
            }
        }];
    }
}

- (void)openAppWithAppID:(NSString*)appID success:(void (^)(void))success faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile
{
    [self releaseApp:appID];
    [self openUniMP:appID success:^{
        success();
    } faile:^(NSString *msg, JZTUNIErrorType errorType) {
        faile(msg,errorType);
    }];
}

- (BOOL)releaseApp:(NSString*)appID faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile
{
    __weak __typeof(self)weakSelf = self;
    NSString *appResourcePath =[JZTUniAppManager appPath:appID];
    if (![DCUniMPSDKEngine isExistsApp:appID]) {
        if (!appResourcePath) {
            faile(@"资源路径不存在",JZTUNIAppPathError);
            return NO;
        }
        if ([DCUniMPSDKEngine releaseAppResourceToRunPathWithAppid:appID resourceFilePath:appResourcePath]) {
            NSLog(@"应用资源文件部署成功");
        }
        [weakSelf setUniMPMenuItems];
        return YES;
    }
    else{
        [weakSelf setUniMPMenuItems];
        return YES;
    }
}

- (void)releaseApp:(NSString*)appID
{
    NSString *appResourcePath =[JZTUniAppManager appPath:appID];
    if ([DCUniMPSDKEngine releaseAppResourceToRunPathWithAppid:appID resourceFilePath:appResourcePath]) {
        NSLog(@"应用资源文件部署成功");
    }
}

- (void)setUniMPMenuItems {
    
    DCUniMPMenuActionSheetItem *item1 = [[DCUniMPMenuActionSheetItem alloc] initWithTitle:@"将小程序隐藏到后台" identifier:@"enterBackground"];
    DCUniMPMenuActionSheetItem *item2 = [[DCUniMPMenuActionSheetItem alloc] initWithTitle:@"关闭小程序" identifier:@"closeUniMP"];
    // 添加到全局配置
    [DCUniMPSDKEngine setDefaultMenuItems:@[item1,item2]];
    // 设置 delegate
    [DCUniMPSDKEngine setDelegate:self];
}

/// 小程序配置信息
- (DCUniMPConfiguration *)getUniMPConfiguration {
    /// 初始化小程序的配置信息
    DCUniMPConfiguration *configuration = [[DCUniMPConfiguration alloc] init];
    
    // 配置启动小程序时传递的参数（参数可以在小程序中通过 plus.runtime.arguments 获取此参数）
    configuration.arguments = @{ @"arguments":@"Hello uni microprogram" };
    // 配置小程序启动后直接打开的页面路径 例："pages/component/view/view?a=1&b=2"
    configuration.redirectPath = nil;
    // 开启后台运行
    configuration.enableBackground = YES;
    
    return configuration;
}

/// 启动小程序
- (void)openUniMP:(NSString*)appID success:(void (^)(void))success faile:(void (^)(NSString *msg ,JZTUNIErrorType errorType ))faile {
    
    // 获取配置信息
    DCUniMPConfiguration *configuration = [self getUniMPConfiguration];
    __weak __typeof(self)weakSelf = self;
    if ([weakSelf releaseApp:appID faile:^(NSString *msg, JZTUNIErrorType errorType) {
        faile(msg,errorType);
    }])
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [DCUniMPSDKEngine openUniMP:appID configuration:configuration completed:^(DCUniMPInstance * _Nullable uniMPInstance, NSError * _Nullable error) {
                if (uniMPInstance) {
                    weakSelf.uniMPInstance = uniMPInstance;
                    success();
                } else {
                    NSString *msg = [NSString stringWithFormat:@"打开小程序出错：%@",error];
                    faile(msg,JZTUNIAppOpenError);
                }
            }];
        });
    }
}

- (void)preloadUniMP:(NSString*)appID {
    
    DCUniMPConfiguration *configuration = [self getUniMPConfiguration];
    __weak __typeof(self)weakSelf = self;
    // 预加载小程序
    [DCUniMPSDKEngine preloadUniMP:appID configuration:configuration completed:^(DCUniMPInstance * _Nullable uniMPInstance, NSError * _Nullable error) {
        if (uniMPInstance) {
            weakSelf.uniMPInstance = uniMPInstance;
            // 预加载后打开小程序
            [uniMPInstance showWithCompletion:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"show 小程序失败：%@",error);
                }
            }];
        } else {
            NSLog(@"预加载小程序出错：%@",error);
        }
    }];
}

#pragma mark - DCUniMPSDKEngineDelegate
/// DCUniMPMenuActionSheetItem 点击触发回调方法
- (void)defaultMenuItemClicked:(NSString *)identifier {
    NSLog(@"标识为 %@ 的 item 被点击了", identifier);
    // 将小程序隐藏到后台
    if ([identifier isEqualToString:@"enterBackground"]) {
        __weak __typeof(self)weakSelf = self;
        [self.uniMPInstance hideWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"小程序 %@ 进入后台",weakSelf.uniMPInstance.appid);
            } else {
                NSLog(@"hide 小程序出错：%@",error);
            }
        }];
    }
    // 关闭小程序
    else if ([identifier isEqualToString:@"closeUniMP"]) {
        [self.uniMPInstance closeWithCompletion:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"小程序 closed");
            } else {
                NSLog(@"close 小程序出错：%@",error);
            }
        }];
    }
    // 向小程序发送消息
    else if ([identifier isEqualToString:@"SendUniMPEvent"]) {
        [DCUniMPSDKEngine sendUniMPEvent:@"NativeEvent" data:@{@"msg":@"native message"}];
    }
}

/// 返回打开小程序时的自定义闪屏视图
- (UIView *)splashViewForApp:(NSString *)appid {
    
    if (!self.loadingVC) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"JZTUniStoryboard" bundle:nil];
        self.loadingVC = [storyboard instantiateInitialViewController];
    }
    return self.loadingVC.view;
}

/// 小程序关闭回调方法
- (void)uniMPOnClose:(NSString *)appid {
    NSLog(@"小程序 %@ 被关闭了",appid);
    self.uniMPInstance = nil;
    // 可以在这个时机再次打开小程序
//    [self openUniMP:nil];
}

/// 监听小程序发送的事件回调方法
/// @param event 事件
/// @param data 参数
/// @param callback 回调方法，回传数据给小程序
- (void)onUniMPEventReceive:(NSString *)event data:(id)data callback:(DCUniMPKeepAliveCallback)callback {
    
    NSLog(@"Receive UniMP event: %@ data: %@",event,data);
    // 回传数据给小程序
    // DCUniMPKeepAliveCallback 用法请查看定义说明
    if (callback) {
        callback(@"native callback message",NO);
    }
}

- (void)removeAllTask
{
    if (self.taskList && self.taskList.count) {
        for (NSURLSessionDataTask *task in self.taskList) {
            [task cancel];
        }
        [self.taskList removeAllObjects];
        self.taskList = nil;
    }
    self.taskList = [NSMutableArray arrayWithCapacity:0];
}

- (NSArray<JZTUniAppModel*>*)getDownLoadList:(NSArray<JZTUniAppModel*>*)downLoadList
{
    NSMutableArray *modelList = [NSMutableArray arrayWithCapacity:0];
    for (JZTUniAppModel *model in downLoadList)
    {
        if ([self canDownLoad:model]) {
            [JZTUniAppManager removeTempFile:model.downUrl];
            [modelList addObject:model];
        }
    }
    return modelList;
}

- (void)backGroundDownload:(NSArray<JZTUniAppModel*>*)downLoadList queueType:(JZTQUEUEType)queueType;
{
    NSArray<JZTUniAppModel*> *modelList = [self getDownLoadList:downLoadList];
    if (!modelList.count) {
        return;
    }
    __weak __typeof(self)weakSelf = self;
    
    if (queueType == JZTCONCURRENT) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(modelList.count==1?1:2);
        for (JZTUniAppModel *model in modelList) {
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                __strong __typeof(self) strongSelf = weakSelf;
                NSURLSessionDataTask *task = [JZTUniAppManager downloadreUseApp:model.downUrl progress:^(double downloadProgressValue) {
                    
                } destination:^(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    dispatch_group_leave(strongSelf->group);
                    dispatch_semaphore_signal(semaphore);
                }];
                [self.taskList addObject:task];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            });
        }
    }
    else{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //线程队列下载
        for (JZTUniAppModel *model in modelList) {
            dispatch_group_async(group, squeue, ^{
                NSURLSessionDataTask *task = [JZTUniAppManager downloadreUseApp:model.downUrl progress:^(double downloadProgressValue) {
                    
                } destination:^(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                    
                } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                    dispatch_semaphore_signal(semaphore);
                }];
                [self.taskList addObject:task];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            });
        }
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [weakSelf removeAllTask];
    });
}

- (void)removeDownLoadTask:(NSString*)url
{
    for (NSURLSessionDataTask *task in self.taskList) {
        if ([task.currentRequest.URL.absoluteString isEqualToString:url]) {
            [task cancel];
            [self.taskList removeObject:task];
            break;
        }
    }
}

- (NSArray<JZTUniAppModel*>*)getCurrentAppList
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentDir = [JZTUniAppManager appRootPath];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    return fileList;
}

- (BOOL)canDownLoad:(JZTUniAppModel*)model
{
    NSArray *list = [self getCurrentAppList];
    for (NSString *appID in list) {
        if ([appID.stringByDeletingPathExtension isEqualToString:model.appId]) {
            if ([self canUpdate:model]) {
                return YES;
            }
            return NO;
        }
    }
    return YES;
}

- (BOOL)canUpdate:(JZTUniAppModel*)model
{
    NSDictionary *versiondc = [DCUniMPSDKEngine getUniMPVersionInfoWithAppid:model.appId];
    if (versiondc) {
//        NSString *name =  [versiondc valueForKey:@"name"];  // 应用版本名称
        NSInteger code = [[versiondc valueForKey:@"code"] integerValue]; // 应用版本号
        if (code == model.versionCode) {
            return NO;
        }
        return YES;
    }
    return NO;
}


- (void)stopDownload
{
    for (NSURLSessionDataTask *task in self.taskList) {
        [task suspend];
    }
}

- (void)reuseDownload
{
    for (NSURLSessionDataTask *task in self.taskList) {
        [task resume];
    }
}

@end
