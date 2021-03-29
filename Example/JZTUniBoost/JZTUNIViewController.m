//
//  JZTUNIViewController.m
//  JZTUniBoost
//
//  Created by 8772037@qq.com on 03/01/2021.
//  Copyright (c) 2021 8772037@qq.com. All rights reserved.
//

#import "JZTUNIViewController.h"
#import "JZTUniAppManager.h"
#import "JZTUNIEngine.h"
#import <AFNetworking/AFNetworking.h>
#import <YYKit.h>
@interface JZTUNIViewController ()
@property (weak,nonatomic) IBOutlet UILabel *lb;
@end

@implementation JZTUNIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[JZTUNIEngine sharedInstance] configNetWork];
//    [self checkUniMPResource];
//    [self setUniMPMenuItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)click:(id)sender
{
    
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:0];
    AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
    NSString *url = @"http://47.100.28.81:7777/v1/tags/";
    [manger GET:url parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSArray *array = [responseObject valueForKey:@"data"];
        for (NSDictionary *dc in array) {
            [list addObject:[JZTUniAppModel modelWithJSON:dc]];
        }
        [[JZTUNIEngine sharedInstance] backGroundDownload:list queueType:JZTSERIAL];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];

//    JZTUniAppModel *model = [[JZTUniAppModel alloc] init];
//    model.appId = @"__UNI__11E9B73";
//    model.downUrl = @"http://139.199.87.192/resource/__UNI__11E9B73.wgt";
//    model.hasUpdate = true;
//    model.versionCode = 100;
//
//    JZTUniAppModel *model1 = [[JZTUniAppModel alloc] init];
//    model1.appId = @"__uni__97b749b";
//    model1.downUrl = @"http://139.199.87.192/resource/__uni__97b749b.wgt";
//    model1.hasUpdate = true;
//    model1.versionCode = 100;
//
//
//    JZTUniAppModel *model2 = [[JZTUniAppModel alloc] init];
//    model2.appId = @"__UNI__A206148";
//    model2.downUrl = @"http://139.199.87.192/resource/__UNI__A206148.wgt";
//    model2.hasUpdate = true;
//    model2.versionCode = 100;
//
//    JZTUniAppModel *model3 = [[JZTUniAppModel alloc] init];
//    model3.appId = @"__UNI__DE06148";
//    model3.downUrl = @"http://139.199.87.192/resource/__UNI__DE06148.wgt";
//    model3.hasUpdate = true;
//    model3.versionCode = 100;
//
//    [[JZTUNIEngine sharedInstance] backGroundDownload:@[model,model1,model2,model3] queueType:JZTCONCURRENT];
}

- (IBAction)click1:(id)sender
{
    JZTUniAppModel *model = [[JZTUniAppModel alloc] init];
    model.appId = @"__UNI__8908E02";
    model.downUrl = @"http://139.199.87.192/resource/__UNI__8908E02.wgt";
    model.hasUpdate = true;
    model.versionCode = 100;
    
    [[JZTUNIEngine sharedInstance] openAppWithModel:model success:^{
        
    } progress:^(double downloadProgressValue) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lb.text = [NSString stringWithFormat:@"下载进度：%.0f％",downloadProgressValue];
        });
    } faile:^(NSString * _Nonnull msg, JZTUNIErrorType errorType) {
        
    }];
}

- (IBAction)click2:(id)sender
{
    
    [[JZTUNIEngine sharedInstance] testCancel];
}

- (IBAction)click3:(id)sender
{
    [JZTUniAppManager removeAllApps];
    
}

@end
